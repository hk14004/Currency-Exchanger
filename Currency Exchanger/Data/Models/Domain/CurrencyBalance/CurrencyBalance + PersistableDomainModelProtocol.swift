//
//  CurrencyBalance + PersistableDomainModelProtocol.swift
//  Currency Exchanger
//
//  Created by Cube on 01/02/2023.
//

import DevTools

extension CurrencyBalance: PersistableDomainModelProtocol {
    typealias StoreType = CurrencyBalance_DB
}
