//
//  CurrencyService.swift
//  Currency Exchanger
//
//  Created by Cube on 31/01/2023.
//

import Foundation
import DevTools

protocol CurrencyServiceProtocol {
    func fetchCurrencies(completion: @escaping (Result<[Currency], Error>)->())
}

class CurrencyService {
    
}

extension CurrencyService: CurrencyServiceProtocol {
    func fetchCurrencies(completion: @escaping (Result<[Currency], Error>) -> ()) {
        // TODO: Network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            let result = self!.loadCurrenciesJson(fileName: "currencies")
            completion(.success(result))
        }
    }
}

// MARK: Private

extension CurrencyService {
    private func loadCurrenciesJson(fileName: String) -> [Currency] {
        let decoder = JSONDecoder()
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let parsed = try decoder.decode(CurrencyResponse.self, from: data)
            return parsed.currencies
        } catch( let err) {
            printError(err)
            return []
        }
    }
}

struct CurrencyResponse: Codable {
    let currencies: [Currency]
}
