//
//  CurrencyBalance + PersistableDomainModelProtocol.swift
//  Currency Exchanger
//
//  Created by Cube on 01/02/2023.
//

import DevToolsCore

extension CurrencyBalance: PersistableDomainModelProtocol {
    typealias StoreType = CurrencyBalance_DB
}
