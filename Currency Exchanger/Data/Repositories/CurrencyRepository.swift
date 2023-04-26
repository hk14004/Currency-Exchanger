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
    func getCurrencies() async -> [Currency]
    func getRates() async -> [CurrencyRate]
    func observeRates() -> AnyPublisher<[CurrencyRate], Never>
}

class CurrencyRepository {
    
    // MARK: Properties
    
    private var currencyStore: PersistentRealmStore<Currency>
    private var currencyAPIService: CurrencyProviderProtocol
    private var currencyRateStore: PersistentRealmStore<CurrencyRate>
    private var currencyRateResponseMapper: CurrencyRateResponseMapperProtocol
    private var currencyResponseMapper: CurrencyResponseMapperProtocol
    
    // MARK: Init
    
    init(currencyStore: PersistentRealmStore<Currency>, currencyAPIService: CurrencyProviderProtocol,
         currencyRateStore: PersistentRealmStore<CurrencyRate>,
         currencyRateResponseMapper: CurrencyRateResponseMapperProtocol,
         currencyResponseMapper: CurrencyResponseMapperProtocol) {
        self.currencyStore = currencyStore
        self.currencyAPIService = currencyAPIService
        self.currencyRateStore = currencyRateStore
        self.currencyRateResponseMapper = currencyRateResponseMapper
        self.currencyResponseMapper = currencyResponseMapper
    }
    
}

extension CurrencyRepository: CurrencyRepositoryProtocol {
    func getRates() async -> [CurrencyRate] {
        await currencyRateStore.getList()
    }
    
    func observeRates() -> AnyPublisher<[CurrencyRate], Never> {
        currencyRateStore.observeList()
    }
    
    func refreshCurrencyRate() async {
        do {
            let response = try await currencyAPIService.fetchExchangeRatesData()
            let rates = currencyRateResponseMapper.map(response: response)
            await currencyRateStore.replace(with: rates)
        } catch( let err) {
            printError(err)
        }
    }
    
    func getCurrencies() async -> [Currency] {
        await currencyStore.getList()
    }
    
    func refreshCurrencies() async {
        do {
            let response = try await currencyAPIService.fetchCurrencies()
            let items = currencyResponseMapper.map(response: response)
            await currencyStore.addOrUpdate(items)
        } catch( let err) {
            printError(err)
        }
    }
    
    func observeCurrencies() -> AnyPublisher<[Currency], Never> {
        currencyStore.observeList()
    }
}
