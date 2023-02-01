//
//  User_DB + PersistedModelProtocol.swift
//  Currency Exchanger
//
//  Created by Cube on 31/01/2023.
//

import DevTools

extension User_DB: PersistedModelProtocol {
    enum UserField: PersistedModelFieldProtocol {
        case name
    }
    
    func toDomain(fields: Set<UserField>) throws -> User {
        return .init(id: self.id, name: "TODO", surname: "TODO", currencyBalanceIDs: Set<String>())
    }
    
    func update(with model: User, fields: Set<UserField>) {
        
    }
}

