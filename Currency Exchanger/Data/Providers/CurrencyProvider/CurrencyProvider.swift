//
//  CurrencyProvider.swift
//  Currency Exchanger
//
//  Created by Cube on 31/01/2023.
//

import Foundation
import DevToolsCore
import Moya
import DevToolsNetworking

//http://api.apilayer.com/exchangerates_data/latest

protocol CurrencyProviderProtocol {
    func fetchCurrencies(completion: @escaping (Result<CurrencyResponse, Error>)->())
    func fetchExchangeRatesData(completion: @escaping (Result<ExchangeRatesDataResponse, Error>)->())
}

class CurrencyProvider {
    
    private let provider: MoyaProvider<CurrencyAPITarget>
    private let requestManager: RequestManager<CurrencyAPITarget>
    
    // MARK: Init
    
    init(provider: MoyaProvider<CurrencyAPITarget>, requestManager: RequestManager<CurrencyAPITarget>) {
        self.provider = provider
        self.requestManager = requestManager
    }
}

extension CurrencyProvider: CurrencyProviderProtocol {
    func fetchExchangeRatesData(completion: @escaping (Result<ExchangeRatesDataResponse, Error>) -> ()) {
        let target = CurrencyAPITarget(endpoint: .getRates, headers: ["apiKey":"Klj35WgKR2kP7rexFaHmVEig0ozzt2bv"])
        let launched = requestManager.launchSingleUniqueRequest(requestID: target.defaultUUID, target: target,
                                                                provider: provider, hookRunning: true,
                                                                retryMethod: .default) { result in
            switch result {
            case .success(let success):
                do {
                    let response = try JSONDecoder().decode(ExchangeRatesDataResponse.self, from: success.data)
                    completion(.success(response))
                } catch (let decodeError) {
                    completion(.failure(decodeError))
                }
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
        
        if !launched {
            completion(.failure(APP_Errors.networkRequestAlreadyRunning))
        }
    }
    
    func fetchCurrencies(completion: @escaping (Result<CurrencyResponse, Error>) -> ()) {
        guard let result = loadCurrenciesJson(fileName: "supported_currencies") else {
            completion(.failure(APP_Errors.networkRequestDataIssue))
            return
        }
        completion(.success(result))
    }
}

// MARK: Private

extension CurrencyProvider {
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
