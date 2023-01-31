//
//  CurrencyService.swift
//  Currency Exchanger
//
//  Created by Cube on 31/01/2023.
//

import Foundation

protocol CurrencyServiceProtocol {
    func fetchCurrencies(completion: (Result<Currency, Error>)->())
}

class CurrencyService {
    
}

extension CurrencyService: CurrencyServiceProtocol {
    func fetchCurrencies(completion: (Result<Currency, Error>) -> ()) {
        // TODO: Network request
        completion(.success(.init(id: "1234")))
    }
}
