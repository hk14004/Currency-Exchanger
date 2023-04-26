//
//  CurrencyRepository.swift
//  Currency Exchanger
//
//  Created by Hardijs on 31/01/2023.
//

import DevToolsCore
import DevToolsRealm
import RealmSwift
import Combine

protocol CurrencyRepositoryProtocol {
    // Remote data
    func refreshCurrencies() async
    func refreshCurrencyRate() async
    
    // Local data
    func observeCurrencies() -> AnyPublisher<[Currency], Never>
    func getCurrencies() -> [Currency]
    func getRates() -> [CurrencyRate]
    func observeRates() ->  AnyPublisher<[CurrencyRate], Never>
}

class CurrencyRepository {
    
    // MARK: Properties
    
    private var currencyStore: PersistentRealmStore<Currency>
    private var currencyAPIService: CurrencyProviderProtocol
    private var currencyRateStore: PersistentRealmStore<CurrencyRate>
    
    // MARK: Init
    
    init(currencyStore: PersistentRealmStore<Currency>, currencyAPIService: CurrencyProviderProtocol,
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
    
    func observeRates() ->  AnyPublisher<[CurrencyRate], Never> {
        currencyRateStore.observeList()
    }
    
    func refreshCurrencyRate() async {
        await withCheckedContinuation { continuation in
            currencyAPIService.fetchExchangeRatesData { [weak self] result in
                switch result {
                case .success(let success):
                    // TODO: Mapper
                    let rates:[CurrencyRate] = success.rates.map { rateAPI in
                            .init(id: rateAPI.key, rate: rateAPI.value)
                    }
                    self?.currencyRateStore.replace(with: rates)
                    continuation.resume()
                case .failure(let failure):
                    printError(failure)
                    continuation.resume()
                }
            }
        }
    }
    
    func getCurrencies() -> [Currency] {
        currencyStore.getList()
    }
    
    func refreshCurrencies() async {
        await withCheckedContinuation { continuation in
            currencyAPIService.fetchCurrencies { [weak self] result in
                switch result {
                case .success(let success):
                    print(success)
                    // TODO: Add mappers
                    let mapped: [Currency] = success.currencies.compactMap { responseCurrency in
                            .init(id: responseCurrency.id)
                    }
                    self?.currencyStore.addOrUpdate(mapped)
                    continuation.resume()
                case .failure(let failure):
                    printError(failure)
                    continuation.resume()
                }
            }
        }
    }
    
    func observeCurrencies() -> AnyPublisher<[Currency], Never> {
        currencyStore.observeList()
    }
}
