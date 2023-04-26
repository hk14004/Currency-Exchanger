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
        do {
            let response = try await currencyAPIService.fetchExchangeRatesData()
            // TODO: Mapper
            let rates:[CurrencyRate] = response.rates.map { rateAPI in
                    .init(id: rateAPI.key, rate: rateAPI.value)
            }
            await currencyRateStore.replace(with: rates)
        } catch( let err) {
            printError(err)
        }
    }
    
    func getCurrencies() -> [Currency] {
        currencyStore.getList()
    }
    
    func refreshCurrencies() async {
        do {
            let response = try await currencyAPIService.fetchCurrencies()
            // TODO: Mapper
            let mapped: [Currency] = response.currencies.compactMap { responseCurrency in
                    .init(id: responseCurrency.id)
            }
            await currencyStore.addOrUpdate(mapped)
        } catch( let err) {
            printError(err)
        }
    }
    
    func observeCurrencies() -> AnyPublisher<[Currency], Never> {
        currencyStore.observeList()
    }
}
