//
//  CurrencyBalanceRepository.swift
//  CurrencyBalance Exchanger
//
//  Created by Hardijs on 31/01/2023.
//

import DevToolsCore
import DevToolsRealm
import RealmSwift
import Combine

protocol CurrencyBalanceRepositoryProtocol {
    func setBalance(_ balance: [CurrencyBalance])
    func observeBalance() -> AnyPublisher<[CurrencyBalance], Never>
    func getBalance() -> [CurrencyBalance]
    func getBalance(forCurrency: Currency) -> CurrencyBalance?
    func addOrUpdate(currencyBalance: [CurrencyBalance])
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
    func addOrUpdate(currencyBalance: [CurrencyBalance]) {
        currencyBalanceStore.addOrUpdate(currencyBalance)
    }
    
    func getBalance(forCurrency: Currency) -> CurrencyBalance? {
        guard let cBalance = currencyBalanceStore.getSingle(id: forCurrency.id) else {
            return nil
        }
        guard cBalance.balance > 0 else {
            return nil
        }
        return cBalance
    }
    
    func getBalance() -> [CurrencyBalance] {
        currencyBalanceStore.getList(predicate: .init(format: "balance > 0"))
    }
    
    func setBalance(_ balance: [CurrencyBalance]) {
        currencyBalanceStore.replace(with: balance)
    }
    
    func observeBalance() -> AnyPublisher<[CurrencyBalance], Never> {
        currencyBalanceStore.observeList(predicate: .init(format: "balance > 0"))
    }
}
