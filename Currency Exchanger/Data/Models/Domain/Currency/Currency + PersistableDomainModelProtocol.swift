//
//  Currency + PersistableDomainModelProtocol.swift
//  Currency Exchanger
//
//  Created by Cube on 31/01/2023.
//

import DevTools

extension Currency: PersistableDomainModelProtocol {
    typealias StoreType = Currency_DB
}
