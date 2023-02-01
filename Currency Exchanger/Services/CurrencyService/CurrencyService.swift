//
//  CurrencyService.swift
//  Currency Exchanger
//
//  Created by Cube on 31/01/2023.
//

import Foundation

protocol CurrencyServiceProtocol {
    func fetchCurrencies(completion: (Result<[Currency], Error>)->())
}

class CurrencyService {
    
}

extension CurrencyService: CurrencyServiceProtocol {
    func fetchCurrencies(completion: (Result<[Currency], Error>) -> ()) {
        // TODO: Network request
        let result = loadCurrenciesJson(fileName: "currencies")
        completion(.success(result))
    }
}

// MARK: Private

extension CurrencyService {
    private func loadCurrenciesJson(fileName: String) -> [Currency] {
        let decoder = JSONDecoder()
        guard
            let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let parsed = try? decoder.decode([Currency].self, from: data)
        else {
            return []
        }
        
        return parsed
    }
}
