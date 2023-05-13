//
//  CurrencyResponse.swift
//  Currency Exchanger
//
//  Created by Hardijs on 04/02/2023.
//

import Foundation

struct CurrencyResponse: Codable {
    let currencies: [Currency]
    
    struct Currency: Codable {
        let id: String
    }
}
