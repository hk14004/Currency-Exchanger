//
//  CurrencyRate.swift
//  Currency Exchanger
//
//  Created by Hardijs on 02/02/2023.
//

import DevToolsCore
import Foundation
import RealmSwift

extension CurrencyRate_DB: PersistedModelProtocol {
        
    enum PersistedField: PersistedModelFieldProtocol {
        case rate
    }
    
    func toDomain(fields: Set<PersistedField>) throws -> CurrencyRate {
        return .init(id: self.id, rate: self.rate.decimalValue)
    }
    
    func update(with model: CurrencyRate, fields: Set<PersistedField>) {
        self.id = model.id
        self.rate = Decimal128(number: model.rate as NSNumber)
    }
}

extension CurrencyRate: PersistableDomainModelProtocol {
    typealias StoreType = CurrencyRate_DB
}
