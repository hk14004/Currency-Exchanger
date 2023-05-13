//
//  User_DB + PersistedModelProtocol.swift
//  Currency Exchanger
//
//  Created by Hardijs on 31/01/2023.
//

import DevToolsCore

extension User_DB: PersistedModelProtocol {
    enum UserField: PersistedModelFieldProtocol {
        case name
        case surname
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

extension User: PersistableDomainModelProtocol {
    typealias StoreType = User_DB
}
