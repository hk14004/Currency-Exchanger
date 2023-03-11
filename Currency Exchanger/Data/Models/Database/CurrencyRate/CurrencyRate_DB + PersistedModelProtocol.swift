//
//  CurrencyRate.swift
//  Currency Exchanger
//
//  Created by Cube on 02/02/2023.
//

import DevTools

extension CurrencyRate_DB: PersistedModelProtocol {
        
    enum PersistedField: PersistedModelFieldProtocol {
        case rate
    }
    
    func toDomain(fields: Set<PersistedField>) throws -> CurrencyRate {
        return .init(id: self.id, rate: self.rate)
    }
    
    func update(with model: CurrencyRate, fields: Set<PersistedField>) {
        self.id = model.id
        self.rate = model.rate
    }
}
