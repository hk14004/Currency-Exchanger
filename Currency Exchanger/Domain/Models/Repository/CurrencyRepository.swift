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
    func refreshCurrencies(completion: ()->())
    func observeCurrencies() -> AnyPublisher<[Currency], Never>
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
    func refreshCurrencies(completion: () -> ()) {
        currencyAPIService.fetchCurrencies { result in
            switch result {
            case .success(let success):
                // Store into DB
                currencyStore.replace(with: [])
                completion()
            case .failure(let failure):
                completion()
            }
        }
    }
    
    func observeCurrencies() -> AnyPublisher<[Currency], Never> {
        currencyStore.observeList()
    }
}
