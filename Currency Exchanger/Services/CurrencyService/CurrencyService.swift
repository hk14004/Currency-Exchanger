//
//  CurrencyService.swift
//  Currency Exchanger
//
//  Created by Cube on 31/01/2023.
//

import Foundation
import DevTools
import Moya
import DevToolsNetworking

//http://api.apilayer.com/exchangerates_data/latest

protocol CurrencyServiceProtocol {
    func fetchCurrencies(completion: @escaping (Result<CurrencyResponse, Error>)->())
    func fetchExchangeRatesData(completion: @escaping (Result<ExchangeRatesDataResponse, Error>)->())
}

class CurrencyService {
    
    private let provider: MoyaProvider<CurrencyAPITarget>
    private let requestManager: RequestManager<CurrencyAPITarget>
    
    // MARK: Init
    
    init(provider: MoyaProvider<CurrencyAPITarget>, requestManager: RequestManager<CurrencyAPITarget>) {
        self.provider = provider
        self.requestManager = requestManager
    }
}

extension CurrencyService: CurrencyServiceProtocol {
    func fetchExchangeRatesData(completion: @escaping (Result<ExchangeRatesDataResponse, Error>) -> ()) {
        let target = CurrencyAPITarget(endpoint: .getRates, headers: ["apiKey":"i1PMfVUbzM×WJlyZ80NvqnjbdMZnbKYF"])
        let launched = requestManager.launchSingleUniqueRequest(requestID: target.defaultUUID, target: target,
                                                                provider: provider, hookRunning: true,
                                                                retryMethod: .default) { result in
            switch result {
            case .success(let success):
                do {
                    let delete = try? success.mapJSON()
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
        // TODO: Network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let result = self!.loadCurrenciesJson(fileName: "currencies") else {
                completion(.failure(APP_Errors.networkRequestDataIssue))
                return
            }
            completion(.success(result))
        }
    }
}

// MARK: Private

extension CurrencyService {
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

struct CurrencyResponse: Codable {
    let currencies: [Currency]
    
    struct Currency: Codable {
        let id: String
    }
}

struct ExchangeRatesDataResponse: Codable {
    let rates: [String: Double]
    let base: String
    let date: String
}
