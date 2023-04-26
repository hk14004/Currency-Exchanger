//
//  User + PersistableDomainModelProtocol.swift
//  Currency Exchanger
//
//  Created by Cube on 31/01/2023.
//

import DevToolsCore

extension User: PersistableDomainModelProtocol {
    typealias StoreType = User_DB
}
