import Foundation
import OSLog

enum NetworkClientError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case parsingError
}

/// Единый сетевой интерфейс для raw- и decodable-запросов.
///
/// Контракт по потокам:
/// - `onResponse` всегда вызывается на `completionQueue`.
/// - Возвращаемый `NetworkTask` можно отменить со стороны вызывающего кода.
protocol NetworkClient {
    /// Выполняет сетевой запрос и возвращает сырые `Data`.
    ///
    /// - Parameters:
    ///   - request: Описание endpoint-а, метода, заголовков, body и cache policy.
    ///   - onTaskMetrics: Опциональный callback метрик URLSessionTask.
    ///   - completionQueue: Очередь, на которой гарантирован вызов `onResponse`.
    ///   - onResponse: Результат запроса:
    ///     - `.success(Data)` при HTTP 2xx и наличии данных;
    ///     - `.failure(NetworkClientError)` при сетевой/HTTP/парсинг ошибке.
    /// - Returns: Отменяемая задача (`NetworkTask`) или `nil`, если запрос завершен синхронно
    ///   (например, cache hit) или если `URLRequest` не удалось собрать.
    @discardableResult
    func send(request: NetworkRequest,
              onTaskMetrics: ((URLSessionTaskMetrics) -> Void)?,
              completionQueue: DispatchQueue,
              onResponse: @escaping (Result<Data, Error>) -> Void) -> NetworkTask?

    /// Выполняет сетевой запрос и декодирует ответ в тип `T`.
    ///
    /// - Important: Декодирование выполняется после получения `Data`; поток callback-а
    ///   контролируется только через `completionQueue`.
    ///
    /// - Parameters:
    ///   - request: Описание endpoint-а, метода, заголовков, body и cache policy.
    ///   - type: Модель декодирования.
    ///   - onTaskMetrics: Опциональный callback метрик URLSessionTask.
    ///   - completionQueue: Очередь, на которой гарантирован вызов `onResponse`.
    ///   - onResponse: Результат:
    ///     - `.success(T)` при HTTP 2xx и успешном декодировании;
    ///     - `.failure(NetworkClientError)` при сетевой/HTTP/парсинг ошибке.
    /// - Returns: Отменяемая задача (`NetworkTask`) или `nil`, если запрос завершен синхронно
    ///   (например, cache hit) или если `URLRequest` не удалось собрать.
    @discardableResult
    func send<T: Decodable>(request: NetworkRequest,
                            type: T.Type,
                            onTaskMetrics: ((URLSessionTaskMetrics) -> Void)?,
                            completionQueue: DispatchQueue,
                            onResponse: @escaping (Result<T, Error>) -> Void) -> NetworkTask?
}

extension NetworkClient {

    @discardableResult
    func send(request: NetworkRequest,
              onResponse: @escaping (Result<Data, Error>) -> Void) -> NetworkTask? {
        send(
            request: request,
            onTaskMetrics: nil,
            completionQueue: .main,
            onResponse: onResponse
        )
    }

    @discardableResult
    func send(
        request: NetworkRequest,
        completionQueue: DispatchQueue,
        onResponse: @escaping (Result<Data, Error>) -> Void
    ) -> NetworkTask? {
        send(
            request: request,
            onTaskMetrics: nil,
            completionQueue: completionQueue,
            onResponse: onResponse
        )
    }

    @discardableResult
    func send<T: Decodable>(request: NetworkRequest,
                            type: T.Type,
                            onResponse: @escaping (Result<T, Error>) -> Void) -> NetworkTask? {
        send(
            request: request,
            type: type,
            onTaskMetrics: nil,
            completionQueue: .main,
            onResponse: onResponse
        )
    }

    @discardableResult
    func send<T: Decodable>(
        request: NetworkRequest,
        type: T.Type,
        completionQueue: DispatchQueue,
        onResponse: @escaping (Result<T, Error>) -> Void
    ) -> NetworkTask? {
        send(
            request: request,
            type: type,
            onTaskMetrics: nil,
            completionQueue: completionQueue,
            onResponse: onResponse
        )
    }
}

final class DefaultNetworkClient: NetworkClient {
    private static let logger = Logger(subsystem: "com.fakenft.app", category: "NetworkClient")
    private static let defaultURLCache = URLCache(
        memoryCapacity: 20 * 1024 * 1024,
        diskCapacity: 100 * 1024 * 1024
    )

    private let session: URLSession
    private let metricsSession: URLSession
    private let metricsCollector: URLSessionMetricsCollector
    private let decoder: JSONDecoder
    private let cacheStore = ResponseCacheStore()

    init(session: URLSession = URLSession.shared,
         decoder: JSONDecoder = JSONDecoder(),
         encoder: JSONEncoder = JSONEncoder()) {
        let configuration = session.configuration
        if configuration.urlCache == nil {
            configuration.urlCache = Self.defaultURLCache
        }
        configuration.requestCachePolicy = .useProtocolCachePolicy

        self.session = URLSession(configuration: configuration)
        self.metricsCollector = URLSessionMetricsCollector()
        self.metricsSession = URLSession(
            configuration: configuration,
            delegate: metricsCollector,
            delegateQueue: nil
        )
        self.decoder = decoder
        _ = encoder
    }

    @discardableResult
    func send(
        request: NetworkRequest,
        onTaskMetrics: ((URLSessionTaskMetrics) -> Void)?,
        completionQueue: DispatchQueue,
        onResponse: @escaping (Result<Data, Error>) -> Void
    ) -> NetworkTask? {
        // Нормализуем все callback-и ответа на очередь, запрошенную вызывающей стороной.
        // Это делает обновления UI предсказуемыми и исключает случайные UI-операции в фоне.
        let onResponse: (Result<Data, Error>) -> Void = { result in
            completionQueue.async {
                onResponse(result)
            }
        }
        guard let urlRequest = create(request: request) else {
            Self.logger.error("[\(LogTimestamp.current(), privacy: .public)] Failed to build URLRequest. endpoint is empty.")
            return nil
        }

        let method = urlRequest.httpMethod ?? "UNKNOWN"
        let path = urlRequest.url?.path ?? "-"
        Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] Send request started. method=\(method, privacy: .public), path=\(path, privacy: .public)")

        if let cachedData = cacheStore.cachedData(for: urlRequest, policy: request.cachePolicy) {
            // При cache hit результат возвращаем сразу и намеренно не создаем URLSessionTask.
            Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] Response returned from in-memory cache. method=\(method, privacy: .public), path=\(path, privacy: .public), bytes=\(cachedData.count)")
            onResponse(.success(cachedData))
            return nil
        }

        // Для сбора metrics нужна сессия с delegate.
        // Для обычных запросов используем простую сессию, чтобы уменьшить overhead.
        let targetSession = onTaskMetrics == nil ? session : metricsSession
        let task = targetSession.dataTask(with: urlRequest) { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                Self.logger.error("[\(LogTimestamp.current(), privacy: .public)] Invalid URLSession response (not HTTPURLResponse). method=\(method, privacy: .public), path=\(path, privacy: .public)")
                onResponse(.failure(NetworkClientError.urlSessionError))
                return
            }

            guard 200 ..< 300 ~= response.statusCode else {
                Self.logger.error("[\(LogTimestamp.current(), privacy: .public)] HTTP request failed. method=\(method, privacy: .public), path=\(path, privacy: .public), status=\(response.statusCode)")
                onResponse(.failure(NetworkClientError.httpStatusCode(response.statusCode)))
                return
            }

            if let data = data {
                Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] HTTP request succeeded. method=\(method, privacy: .public), path=\(path, privacy: .public), status=\(response.statusCode), bytes=\(data.count)")
                self.cacheStore.store(data: data, for: urlRequest, policy: request.cachePolicy)
                onResponse(.success(data))
                return
            } else if let error = error {
                Self.logger.error("[\(LogTimestamp.current(), privacy: .public)] URLSession request error. method=\(method, privacy: .public), path=\(path, privacy: .public), error=\(String(describing: error), privacy: .public)")
                onResponse(.failure(NetworkClientError.urlRequestError(error)))
                return
            } else {
                Self.logger.fault("[\(LogTimestamp.current(), privacy: .public)] Unexpected URLSession result without data and error. method=\(method, privacy: .public), path=\(path, privacy: .public)")
                assertionFailure("Unexpected condition!")
                return
            }
        }

        if let onTaskMetrics {
            metricsCollector.register(callback: onTaskMetrics, for: task.taskIdentifier)
        }

        task.resume()

        return DefaultNetworkTask(dataTask: task)
    }

    @discardableResult
    func send<T: Decodable>(
        request: NetworkRequest,
        type: T.Type,
        onTaskMetrics: ((URLSessionTaskMetrics) -> Void)?,
        completionQueue: DispatchQueue,
        onResponse: @escaping (Result<T, Error>) -> Void
    ) -> NetworkTask? {
        return send(request: request, onTaskMetrics: onTaskMetrics, completionQueue: completionQueue) { result in
            switch result {
            case let .success(data):
                self.parse(data: data, type: type, onResponse: onResponse)
            case let .failure(error):
                onResponse(.failure(error))
            }
        }
    }

    // MARK: - Private

    private func create(request: NetworkRequest) -> URLRequest? {
        guard let endpoint = request.endpoint else {
            assertionFailure("Empty endpoint")
            return nil
        }

        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = request.httpMethod.rawValue

        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue(RequestConstants.token, forHTTPHeaderField: "X-Practicum-Mobile-Token")

        if let headers = request.headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }

        if let body = request.body {
            urlRequest.httpBody = body
        } else if let dtoDictionary = request.dto?.asDictionary() {
            // Бэкенд ожидает x-www-form-urlencoded для DTO-запросов.
            // Поэтому DTO кодируем как query-строку в HTTP body.
            var urlComponents = URLComponents()
            let queryItems = dtoDictionary.map { field in
                URLQueryItem(
                    name: field.key,
                    value: field.value
                    )
            }
            urlComponents.queryItems = queryItems
            urlRequest.httpBody = urlComponents.query?.data(using: .utf8)
        }

        if let contentType = request.contentType {
            urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        } else if request.body != nil || request.dto != nil {
            // Fallback content type для body/dto-запросов, если request его явно не переопределил.
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }

        return urlRequest
    }

    private func parse<T: Decodable>(data: Data, type _: T.Type, onResponse: @escaping (Result<T, Error>) -> Void) {
        do {
            let response = try decoder.decode(T.self, from: data)
            onResponse(.success(response))
        } catch {
            Self.logger.error("[\(LogTimestamp.current(), privacy: .public)] Decoding failed in NetworkClient. bytes=\(data.count), error=\(String(describing: error), privacy: .public)")
            onResponse(.failure(NetworkClientError.parsingError))
        }
    }
}

private final class ResponseCacheStore {
    private static let logger = Logger(subsystem: "com.fakenft.app", category: "NetworkCache")

    private struct CacheKey: Hashable {
        let method: String
        let url: String
        let bodyDigest: Int
    }

    private struct CacheEntry {
        let data: Data
        let expiresAt: Date
    }

    private let lock = NSLock()
    private var entries: [CacheKey: CacheEntry] = [:]

    func cachedData(for request: URLRequest, policy: RequestCachePolicy) -> Data? {
        guard case .ttl(let ttl) = policy, ttl > 0 else { return nil }
        let key = makeKey(for: request)
        let now = Date()

        lock.lock()
        defer { lock.unlock() }

        removeExpiredEntries(now: now)
        guard let entry = entries[key], entry.expiresAt > now else { return nil }
        Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] Cache hit. method=\(key.method, privacy: .public), url=\(key.url, privacy: .public), bytes=\(entry.data.count)")
        return entry.data
    }

    func store(data: Data, for request: URLRequest, policy: RequestCachePolicy) {
        guard case .ttl(let ttl) = policy, ttl > 0 else { return }
        let key = makeKey(for: request)
        let expiresAt = Date().addingTimeInterval(ttl)

        // Общий изменяемый словарь; lock предотвращает гонки между конкурентными запросами.
        lock.lock()
        entries[key] = CacheEntry(data: data, expiresAt: expiresAt)
        lock.unlock()
        Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] Cache store. method=\(key.method, privacy: .public), url=\(key.url, privacy: .public), ttl=\(ttl, format: .fixed(precision: 0))s, bytes=\(data.count)")
    }

    private func makeKey(for request: URLRequest) -> CacheKey {
        CacheKey(
            method: request.httpMethod ?? "GET",
            url: request.url?.absoluteString ?? "",
            bodyDigest: request.httpBody?.hashValue ?? 0
        )
    }

    private func removeExpiredEntries(now: Date) {
        entries = entries.filter { $0.value.expiresAt > now }
    }
}

private final class URLSessionMetricsCollector: NSObject, URLSessionTaskDelegate {
    private let lock = NSLock()
    private var callbacksByTaskID: [Int: (URLSessionTaskMetrics) -> Void] = [:]

    func register(callback: @escaping (URLSessionTaskMetrics) -> Void, for taskID: Int) {
        // Метрики задачи приходят асинхронно через URLSession delegate.
        // Callback сохраняем по task identifier и удаляем после первой доставки.
        lock.lock()
        callbacksByTaskID[taskID] = callback
        lock.unlock()
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics
    ) {
        lock.lock()
        let callback = callbacksByTaskID.removeValue(forKey: task.taskIdentifier)
        lock.unlock()
        callback?(metrics)
    }
}
