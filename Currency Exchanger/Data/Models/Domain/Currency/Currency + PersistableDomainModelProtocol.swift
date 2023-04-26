//
//  Currency + PersistableDomainModelProtocol.swift
//  Currency Exchanger
//
//  Created by Hardijs on 31/01/2023.
//

import DevToolsCore

extension Currency: PersistableDomainModelProtocol {
    typealias StoreType = Currency_DB
}
