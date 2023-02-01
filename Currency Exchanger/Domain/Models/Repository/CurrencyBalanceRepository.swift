//
//  CurrencyBalanceRepository.swift
//  CurrencyBalance Exchanger
//
//  Created by Cube on 31/01/2023.
//

import DevTools
import DevToolsRealm
import RealmSwift
import Combine

protocol CurrencyBalanceRepositoryProtocol {
    func refreshBalance(completion: ()->())
    func observeBalance() -> AnyPublisher<[CurrencyBalance], Never>
}

class CurrencyBalanceRepository {
    
    // MARK: Properties
    
    private var currencyBalanceStore: PersistentRealmStore<CurrencyBalance>
    
    // MARK: Init
    
    init(currencyBalanceStore: PersistentRealmStore<CurrencyBalance>) {
        self.currencyBalanceStore = currencyBalanceStore
    }

}

extension CurrencyBalanceRepository: CurrencyBalanceRepositoryProtocol {
    func refreshBalance(completion: () -> ()) {
        completion()
    }
    
    func observeBalance() -> AnyPublisher<[CurrencyBalance], Never> {
        currencyBalanceStore.observeList()
    }
}
