//
//  CurrencyRate.swift
//  Currency Exchanger
//
//  Created by Hardijs on 03/02/2023.
//

import Foundation
import DevToolsCore

struct CurrencyRate {
    let id: String
    let rate: Money
}

extension CurrencyRate: Equatable {}
