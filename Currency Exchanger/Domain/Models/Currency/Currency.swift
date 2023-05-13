//
//  Currency.swift
//  Currency Exchanger
//
//  Created by Hardijs on 31/01/2023.
//

import Foundation

typealias CurrencyID = String

struct Currency {
    let id: CurrencyID
}

extension Currency: Codable {}
extension Currency: Hashable {}
