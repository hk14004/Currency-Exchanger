//
//  CurrencyRepository.swift
//  Currency Exchanger
//
//  Created by Cube on 31/01/2023.
//

import DevTools
import DevToolsRealm
import RealmSwift
import Combine

protocol CurrencyRepositoryProtocol {
    // Remote data
    func refreshCurrencies(completion: @escaping ()->())
    func refreshCurrencyRate(completion: @escaping () -> ())
    
    // Local data
    func observeCurrencies() -> AnyPublisher<[Currency], Never>
    func getCurrencies() -> [Currency]
    func getRates() -> [CurrencyRate]
}

class CurrencyRepository {
    
    // MARK: Properties
    
    private var currencyStore: PersistentRealmStore<Currency>
    private var currencyAPIService: CurrencyServiceProtocol
    private var currencyRateStore: PersistentRealmStore<CurrencyRate>
    
    // MARK: Init
    
    init(currencyStore: PersistentRealmStore<Currency>, currencyAPIService: CurrencyServiceProtocol,
         currencyRateStore: PersistentRealmStore<CurrencyRate>) {
        self.currencyStore = currencyStore
        self.currencyAPIService = currencyAPIService
        self.currencyRateStore = currencyRateStore
    }
    
}

extension CurrencyRepository: CurrencyRepositoryProtocol {
    func getRates() -> [CurrencyRate] {
        currencyRateStore.getList()
    }
    
    func refreshCurrencyRate(completion: @escaping () -> ()) {
        currencyAPIService.fetchExchangeRatesData { [weak self] result in
            switch result {
            case .success(let success):
                // TODO: Mapper
                let rates:[CurrencyRate] = success.rates.map { rateAPI in
                    .init(id: rateAPI.key, rate: rateAPI.value)
                }
                self?.currencyRateStore.replace(with: rates)
                completion()
            case .failure(let failure):
                printError(failure)
                completion()
            }
        }
    }
    
    func getCurrencies() -> [Currency] {
        currencyStore.getList()
    }
    
    func refreshCurrencies(completion: @escaping () -> ()) {
        currencyAPIService.fetchCurrencies { [weak self] result in
            switch result {
            case .success(let success):
                print(success)
                // TODO: Add mappers
                self?.currencyStore.addOrUpdate([.init(id: "EUR"), .init(id: "USD"), .init(id: "GBP")])
                completion()
            case .failure(let failure):
                printError(failure)
                completion()
            }
        }
    }
    
    func observeCurrencies() -> AnyPublisher<[Currency], Never> {
        currencyStore.observeList()
    }
}
