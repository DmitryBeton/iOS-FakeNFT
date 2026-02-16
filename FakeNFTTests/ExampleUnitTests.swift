@testable import FakeNFT
import XCTest

final class MockPaymentServiceTests: XCTestCase {
    func testPaySuccessReturnsSuccessOnMainThread() {
        let service = MockPaymentService()
        service.shouldSucceed = true
        service.delay = 0.01

        let exp = expectation(description: "mock payment success")
        service.pay(currencyID: "1") { result in
            XCTAssertTrue(Thread.isMainThread)
            if case .failure(let error) = result {
                XCTFail("Expected success, got error: \(error)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func testPayFailureReturnsError() {
        let service = MockPaymentService()
        service.shouldSucceed = false
        service.delay = 0.01

        let exp = expectation(description: "mock payment failure")
        service.pay(currencyID: "1") { result in
            if case .success = result {
                XCTFail("Expected failure, got success")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}

final class MockCurrencyServiceTests: XCTestCase {
    func testFetchCurrenciesSuccessReturnsStubOnMainThread() {
        let service = MockCurrencyService()
        service.shouldSucceed = true
        service.delay = 0.01
        service.stubCurrencies = [
            Currency(title: "BTC", name: "Bitcoin", image: "img", id: "5")
        ]

        let exp = expectation(description: "mock currencies success")
        service.fetchCurrencies { result in
            XCTAssertTrue(Thread.isMainThread)
            switch result {
            case .success(let currencies):
                XCTAssertEqual(currencies, service.stubCurrencies)
            case .failure(let error):
                XCTFail("Expected success, got error: \(error)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func testFetchCurrenciesFailureReturnsError() {
        let service = MockCurrencyService()
        service.shouldSucceed = false
        service.delay = 0.01

        let exp = expectation(description: "mock currencies failure")
        service.fetchCurrencies { result in
            if case .success = result {
                XCTFail("Expected failure, got success")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}

final class PaymentServiceTests: XCTestCase {
    func testPaySuccessCallsAllStepsAndCompletesWithSuccess() {
        let network = NetworkClientStub(stubs: [
            .success(PaymentCurrencyBindResponse(success: true, orderId: "order", id: "ETH")),
            .success(CartOrderResponse(nfts: ["nft1", "nft2"], id: "order")),
            .success(CartOrderResponse(nfts: ["nft1", "nft2"], id: "order")),
            .success(CartOrderResponse(nfts: [], id: "order"))
        ])
        let service = PaymentService(networkClient: network)

        let exp = expectation(description: "payment success")
        service.pay(currencyID: "7") { result in
            XCTAssertTrue(Thread.isMainThread)
            if case .failure(let error) = result {
                XCTFail("Expected success, got error: \(error)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(network.requestNames.count, 4)
        XCTAssertEqual(
            network.requestNames,
            ["SetOrderPaymentCurrencyRequest", "CartOrderRequest", "CompleteOrderRequest", "UpdateCartOrderRequest"]
        )
    }

    func testPayReturnsFailureWhenBindCurrencyBusinessFlagIsFalse() {
        let network = NetworkClientStub(stubs: [
            .success(PaymentCurrencyBindResponse(success: false, orderId: "order", id: "ETH"))
        ])
        let service = PaymentService(networkClient: network)

        let exp = expectation(description: "payment bind business failure")
        service.pay(currencyID: "7") { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                guard case PaymentServiceError.paymentNotAllowed = error else {
                    XCTFail("Unexpected error type: \(error)")
                    return
                }
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(network.requestNames, ["SetOrderPaymentCurrencyRequest"])
    }

    func testPayStillCompletesWithSuccessWhenCleanupFails() {
        let network = NetworkClientStub(stubs: [
            .success(PaymentCurrencyBindResponse(success: true, orderId: "order", id: "ETH")),
            .success(CartOrderResponse(nfts: ["nft1"], id: "order")),
            .success(CartOrderResponse(nfts: ["nft1"], id: "order")),
            .failure(NetworkClientStubError.forcedFailure)
        ])
        let service = PaymentService(networkClient: network)

        let exp = expectation(description: "payment success even if cleanup fails")
        service.pay(currencyID: "7") { result in
            if case .failure(let error) = result {
                XCTFail("Expected success, got error: \(error)")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}

final class CurrencyServiceTests: XCTestCase {
    func testFetchCurrenciesReturnsDataOnMainThread() {
        let expected = [
            Currency(title: "Bitcoin", name: "BTC", image: "img", id: "5"),
            Currency(title: "Ethereum", name: "ETH", image: "img", id: "7")
        ]
        let network = NetworkClientStub(stubs: [.success(expected)])
        let service = CurrencyService(networkClient: network)

        let exp = expectation(description: "currency service success")
        DispatchQueue.global(qos: .userInitiated).async {
            service.fetchCurrencies { result in
                XCTAssertTrue(Thread.isMainThread)
                switch result {
                case .success(let currencies):
                    XCTAssertEqual(currencies, expected)
                case .failure(let error):
                    XCTFail("Expected success, got error: \(error)")
                }
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(network.requestNames, ["CurrencyRequest"])
    }

    func testFetchCurrenciesReturnsFailureOnMainThread() {
        let network = NetworkClientStub(stubs: [.failure(NetworkClientStubError.forcedFailure)])
        let service = CurrencyService(networkClient: network)

        let exp = expectation(description: "currency service failure")
        service.fetchCurrencies { result in
            XCTAssertTrue(Thread.isMainThread)
            if case .success = result {
                XCTFail("Expected failure, got success")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}

private enum NetworkClientStubError: Error {
    case noStubProvided
    case typeMismatch(expected: String, got: String)
    case rawRequestsNotSupported
    case forcedFailure
}

private final class NetworkClientStub: NetworkClient {
    enum StubResult {
        case success(Any)
        case failure(Error)
    }

    private let lock = NSLock()
    private var stubs: [StubResult]
    private(set) var requestNames: [String] = []

    init(stubs: [StubResult]) {
        self.stubs = stubs
    }

    @discardableResult
    func send(
        request: NetworkRequest,
        onTaskMetrics _: ((URLSessionTaskMetrics) -> Void)?,
        completionQueue: DispatchQueue,
        onResponse: @escaping (Result<Data, Error>) -> Void
    ) -> NetworkTask? {
        appendRequestName(for: request)
        completionQueue.async {
            onResponse(.failure(NetworkClientStubError.rawRequestsNotSupported))
        }
        return nil
    }

    @discardableResult
    func send<T>(
        request: NetworkRequest,
        type modelType: T.Type,
        onTaskMetrics _: ((URLSessionTaskMetrics) -> Void)?,
        completionQueue: DispatchQueue,
        onResponse: @escaping (Result<T, Error>) -> Void
    ) -> NetworkTask? where T: Decodable {
        appendRequestName(for: request)
        let stub = dequeueStub()

        completionQueue.async {
            switch stub {
            case .success(let value):
                guard let typed = value as? T else {
                    onResponse(
                        .failure(
                            NetworkClientStubError.typeMismatch(
                                expected: String(describing: modelType),
                                got: String(describing: Swift.type(of: value))
                            )
                        )
                    )
                    return
                }
                onResponse(.success(typed))
            case .failure(let error):
                onResponse(.failure(error))
            }
        }

        return nil
    }

    private func appendRequestName(for request: NetworkRequest) {
        lock.lock()
        requestNames.append(String(describing: type(of: request)))
        lock.unlock()
    }

    private func dequeueStub() -> StubResult {
        lock.lock()
        defer { lock.unlock() }

        guard !stubs.isEmpty else {
            return .failure(NetworkClientStubError.noStubProvided)
        }
        return stubs.removeFirst()
    }
}
