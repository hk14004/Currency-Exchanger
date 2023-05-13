//
//  ExchangeRatesDataResponse.swift
//  Currency Exchanger
//
//  Created by Hardijs on 04/02/2023.
//

import Foundation

struct ExchangeRatesDataResponse: Codable {
    let rates: [String: Decimal]
    let base: String
}
