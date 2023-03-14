//
//  CurrencyBalance.swift
//  Currency Exchanger
//
//  Created by Cube on 31/01/2023.
//

import Foundation

struct CurrencyBalance {
    let id: String
    let balance: Double
}

extension CurrencyBalance: Equatable, Hashable {}
