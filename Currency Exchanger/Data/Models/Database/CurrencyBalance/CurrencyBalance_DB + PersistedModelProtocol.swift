//
//  CurrencyBalance_DB + PersistedModelProtocol.swift
//  Currency Exchanger
//
//  Created by Cube on 01/02/2023.
//

import DevTools

extension CurrencyBalance_DB: PersistedModelProtocol {
        
    enum PersistedField: PersistedModelFieldProtocol {
        case balance
    }
    
    func toDomain(fields: Set<PersistedField>) throws -> CurrencyBalance {
        return .init(id: self.id, balance: self.balance)
    }
    
    func update(with model: CurrencyBalance, fields: Set<PersistedField>) {
        self.id = model.id
        self.balance = model.balance
    }
}
