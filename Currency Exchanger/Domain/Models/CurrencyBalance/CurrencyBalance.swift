//
//  CurrencyBalance.swift
//  Currency Exchanger
//
//  Created by Hardijs on 31/01/2023.
//

import Foundation
import DevToolsCore

struct CurrencyBalance {
    let id: String
    let balance: Money
}

extension CurrencyBalance: Equatable, Hashable {}
