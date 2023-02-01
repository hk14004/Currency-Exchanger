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
    func setBalance(_ balance: [CurrencyBalance])
    func observeBalance() -> AnyPublisher<[CurrencyBalance], Never>
    func getBalance() -> [CurrencyBalance]
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
    func getBalance() -> [CurrencyBalance] {
        currencyBalanceStore.getList()
    }
    
    func setBalance(_ balance: [CurrencyBalance]) {
        currencyBalanceStore.replace(with: balance)
    }
    
    func observeBalance() -> AnyPublisher<[CurrencyBalance], Never> {
        currencyBalanceStore.observeList()
    }
}
