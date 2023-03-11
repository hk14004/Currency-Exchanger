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
        return .init(id: self.id, name: self.name, surname: self.surname)
    }
    
    func update(with model: User, fields: Set<UserField>) {
        self.id = model.id
        self.name = model.name
        self.surname = model.surname
    }
}

