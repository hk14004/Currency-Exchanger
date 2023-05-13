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

class CurrencyBalanceRepositoryImpl {
    
    // MARK: Properties
    
    private var currencyBalanceStore: BasePersistedLayerInterface<CurrencyBalance>
    
    // MARK: Init
    
    init(currencyBalanceStore: BasePersistedLayerInterface<CurrencyBalance>) {
        self.currencyBalanceStore = currencyBalanceStore
    }

}

extension CurrencyBalanceRepositoryImpl: CurrencyBalanceRepository {
    func addOrUpdate(currencyBalance: [CurrencyBalance]) async {
        await currencyBalanceStore.addOrUpdate(currencyBalance)
    }
    
    func getBalance(forCurrency: Currency) async -> CurrencyBalance? {
        guard let cBalance = await currencyBalanceStore.getSingle(id: forCurrency.id) else {
            return nil
        }
        guard cBalance.balance > 0 else {
            return nil
        }
        return cBalance
    }
    
    func getBalance() async -> [CurrencyBalance] {
        await currencyBalanceStore.getList(predicate: .init(format: "balance > 0"))
    }
    
    func setBalance(_ balance: [CurrencyBalance]) async {
        await currencyBalanceStore.replace(with: balance)
    }
    
    func observeBalance() -> AnyPublisher<[CurrencyBalance], Never> {
        currencyBalanceStore.observeList(predicate: .init(format: "balance > 0"))
    }
}
