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
    private let session: URLSession
    private let metricsSession: URLSession
    private let metricsCollector: URLSessionMetricsCollector
    private let decoder: JSONDecoder

    init(session: URLSession = URLSession.shared,
         decoder: JSONDecoder = JSONDecoder(),
         encoder: JSONEncoder = JSONEncoder()) {
        self.session = session
        self.metricsCollector = URLSessionMetricsCollector()
        let configuration = session.configuration
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

        if let dtoDictionary = request.dto?.asDictionary() {
            var urlComponents = URLComponents()
            let queryItems = dtoDictionary.map { field in
                URLQueryItem(
                    name: field.key,
                    value: field.value
                    )
            }
            urlComponents.queryItems = queryItems
            urlRequest.httpBody = urlComponents.query?.data(using: .utf8)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

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
