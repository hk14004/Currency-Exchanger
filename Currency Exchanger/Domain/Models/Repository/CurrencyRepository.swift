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
    func refreshCurrencies(completion: @escaping ()->())
    func refreshCurrencyRate(completion: @escaping () -> ())
    func observeCurrencies() -> AnyPublisher<[Currency], Never>
    func getCurrencies() -> [Currency]
}

class CurrencyRepository {
    
    // MARK: Properties
    
    private var currencyStore: PersistentRealmStore<Currency>
    private var currencyAPIService: CurrencyServiceProtocol
    
    // MARK: Init
    
    init(currencyStore: PersistentRealmStore<Currency>, currencyAPIService: CurrencyServiceProtocol) {
        self.currencyStore = currencyStore
        self.currencyAPIService = currencyAPIService
    }

}

extension CurrencyRepository: CurrencyRepositoryProtocol {
    func refreshCurrencyRate(completion: @escaping () -> ()) {
        currencyAPIService.fetchExchangeRatesData { result in
            switch result {
            case .success(let success):
                print(success)
                // TODO: Store rates into DB
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
        currencyAPIService.fetchCurrencies { result in
            switch result {
            case .success(let success):
                print(success)
                // TODO: Add mappers
                self.currencyStore.addOrUpdate([.init(id: "EUR"), .init(id: "USD"), .init(id: "GBP")]) 
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
