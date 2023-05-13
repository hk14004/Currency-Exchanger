//
//  CurrencyProviderImpl.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 13/05/2023.
//

import Foundation
import DevToolsCore
import Moya
import DevToolsNetworking

class CurrencyProviderImpl {
    
    private let provider: MoyaProvider<CurrencyAPITarget>
    private let requestManager: RequestManager<CurrencyAPITarget>
    
    // MARK: Init
    
    init(provider: MoyaProvider<CurrencyAPITarget>, requestManager: RequestManager<CurrencyAPITarget>) {
        self.provider = provider
        self.requestManager = requestManager
    }
}

extension CurrencyProviderImpl: CurrencyProvider {
    func fetchExchangeRatesData() async throws -> ExchangeRatesDataResponse {
        try await withCheckedThrowingContinuation({ cont in
            let target = CurrencyAPITarget(endpoint: .getRates, headers: ["apiKey": CURRENCY_API_KEY])
            let launched = requestManager.launchSingleUniqueRequest(requestID: target.defaultUUID, target: target,
                                                                    provider: provider, hookRunning: true,
                                                                    retryMethod: .default) { result in
                switch result {
                case .success(let success):
                    do {
                        let response = try JSONDecoder().decode(ExchangeRatesDataResponse.self, from: success.data)
                        cont.resume(returning: response)
                    } catch (let decodeError) {
                        printError(decodeError)
                        cont.resume(throwing: CurrencyProviderError.responseDecodeIssue)
                    }
                case .failure(let failure):
                    cont.resume(throwing: CurrencyProviderError.fetchFailed(code: failure.errorCode))
                }
            }
            
            if !launched {
                cont.resume(throwing: CurrencyProviderError.requestAlreadyRunning)
            }
        })
    }
    
    func fetchCurrencies() async throws -> CurrencyResponse {
        guard let result = loadCurrenciesJson(fileName: "supported_currencies") else {
            throw CurrencyProviderError.userError(description: "Missing JSON in bundle")
        }
        return result
    }
}

// MARK: Private

extension CurrencyProviderImpl {
    private func loadCurrenciesJson(fileName: String) -> CurrencyResponse? {
        let decoder = JSONDecoder()
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let parsed = try decoder.decode(CurrencyResponse.self, from: data)
            return parsed
        } catch( let err) {
            printError(err)
            return nil
        }
    }
}
