//
//  Currency_DB + PersistedModelProtocol.swift
//  Currency Exchanger
//
//  Created by Hardijs on 31/01/2023.
//

import DevToolsCore

extension Currency_DB: PersistedModelProtocol {
        
    enum PersistedField: PersistedModelFieldProtocol {
        case none
    }
    
    func toDomain(fields: Set<PersistedField>) throws -> Currency {
        return .init(id: self.id)
    }
    
    func update(with model: Currency, fields: Set<PersistedField>) {
        self.id = model.id
    }
}
