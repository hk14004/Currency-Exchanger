//
//  CurrencyRateResponseMapper.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 26/04/2023.
//

import Foundation

protocol CurrencyRateResponseMapperProtocol {
    func map(response: ExchangeRatesDataResponse) -> [CurrencyRate]
}

class CurrencyRateResponseMapper {
    
}

extension CurrencyRateResponseMapper: CurrencyRateResponseMapperProtocol {
    func map(response: ExchangeRatesDataResponse) -> [CurrencyRate] {
        response.rates.map { rateAPI in
                .init(id: rateAPI.key, rate: rateAPI.value)
        }
    }
}
