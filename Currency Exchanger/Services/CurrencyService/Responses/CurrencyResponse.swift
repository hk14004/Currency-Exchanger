//
//  CurrencyResponse.swift
//  Currency Exchanger
//
//  Created by Cube on 04/02/2023.
//

import Foundation

struct CurrencyResponse: Codable {
    let currencies: [Currency]
    
    struct Currency: Codable {
        let id: String
    }
}
