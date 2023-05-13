//
//  CurrencyRateResponseMapper.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 26/04/2023.
//

import Foundation

protocol CurrencyResponseMapper {
    func map(response: CurrencyResponse) -> [Currency]
}

class CurrencyResponseMapperImpl {
    
}

extension CurrencyResponseMapperImpl: CurrencyResponseMapper {
    func map(response: CurrencyResponse) -> [Currency] {
        response.currencies.compactMap { apiCurrency in
            Currency(id: apiCurrency.id)
        }
    }
}
