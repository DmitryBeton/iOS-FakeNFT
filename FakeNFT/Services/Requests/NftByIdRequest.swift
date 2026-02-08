import Foundation

struct NFTRequest: NetworkRequest {
    let id: String
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(id)")
    }
    var dto: Dto?
}

struct CartOrderRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }

    var dto: Dto?
}

struct CurrencyRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/currencies")
    }

    var dto: Dto?
}

struct SetOrderPaymentCurrencyRequest: NetworkRequest {
    let currencyID: String

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1/payment/\(currencyID)")
    }

    var dto: Dto?
}

struct CompleteOrderRequest: NetworkRequest {
    var httpMethod: HttpMethod { .post }
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
    let dto: Dto?
}

struct CompleteOrderDto: Dto {
    let nftsCSV: String

    func asDictionary() -> [String: String] {
        ["nfts": nftsCSV]
    }
}
