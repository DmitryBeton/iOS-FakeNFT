import Foundation

enum NetworkClientError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case parsingError
}

protocol NetworkClient {
    @discardableResult
    func send(request: NetworkRequest,
              onTaskMetrics: ((URLSessionTaskMetrics) -> Void)?,
              completionQueue: DispatchQueue,
              onResponse: @escaping (Result<Data, Error>) -> Void) -> NetworkTask?

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
        let onResponse: (Result<Data, Error>) -> Void = { result in
            completionQueue.async {
                onResponse(result)
            }
        }
        guard let urlRequest = create(request: request) else { return nil }
        if let cachedData = cacheStore.cachedData(for: urlRequest, policy: request.cachePolicy) {
            onResponse(.success(cachedData))
            return nil
        }

        let targetSession = onTaskMetrics == nil ? session : metricsSession
        let task = targetSession.dataTask(with: urlRequest) { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                onResponse(.failure(NetworkClientError.urlSessionError))
                return
            }

            guard 200 ..< 300 ~= response.statusCode else {
                onResponse(.failure(NetworkClientError.httpStatusCode(response.statusCode)))
                return
            }

            if let data = data {
                self.cacheStore.store(data: data, for: urlRequest, policy: request.cachePolicy)
                onResponse(.success(data))
                return
            } else if let error = error {
                onResponse(.failure(NetworkClientError.urlRequestError(error)))
                return
            } else {
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
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }

        return urlRequest
    }

    private func parse<T: Decodable>(data: Data, type _: T.Type, onResponse: @escaping (Result<T, Error>) -> Void) {
        do {
            let response = try decoder.decode(T.self, from: data)
            onResponse(.success(response))
        } catch {
            onResponse(.failure(NetworkClientError.parsingError))
        }
    }
}

private final class ResponseCacheStore {
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
        return entry.data
    }

    func store(data: Data, for request: URLRequest, policy: RequestCachePolicy) {
        guard case .ttl(let ttl) = policy, ttl > 0 else { return }
        let key = makeKey(for: request)
        let expiresAt = Date().addingTimeInterval(ttl)

        lock.lock()
        entries[key] = CacheEntry(data: data, expiresAt: expiresAt)
        lock.unlock()
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
