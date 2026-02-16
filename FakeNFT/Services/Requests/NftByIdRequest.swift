import Foundation

struct NFTRequest: NetworkRequest {
    let id: String

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(id)")
    }

<<<<<<< HEAD
    var httpMethod: HttpMethod { .get }

    var parameters: [String: String]? { nil }

    var dto: Dto? { nil }
=======
    var cachePolicy: RequestCachePolicy {
        .ttl(300)
    }
}

struct CartOrderRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
}

struct CurrencyRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/currencies")
    }

    var cachePolicy: RequestCachePolicy {
        .ttl(300)
    }
}

struct SetOrderPaymentCurrencyRequest: NetworkRequest {
    let currencyID: String

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1/payment/\(currencyID)")
    }
}

struct CompleteOrderRequest: NetworkRequest {
    let nftIDs: [String]
    var httpMethod: HttpMethod { .post }
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }

    var contentType: String? { "application/x-www-form-urlencoded" }

    var body: Data? {
        formBody(for: nftIDs)
    }
}

struct UpdateCartOrderRequest: NetworkRequest {
    let nftIDs: [String]

    var httpMethod: HttpMethod { .put }
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }

    var contentType: String? { "application/x-www-form-urlencoded" }

    var body: Data? {
        formBody(for: nftIDs)
    }
}

private func formBody(for nftIDs: [String]) -> Data {
    let bodyString = nftIDs
        .map { "nfts=\($0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0)" }
        .joined(separator: "&")
    return Data(bodyString.utf8)
>>>>>>> develop
}

