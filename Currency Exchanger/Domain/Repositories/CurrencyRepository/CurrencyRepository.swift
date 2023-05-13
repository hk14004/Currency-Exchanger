//
//  CurrencyRepository.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 13/05/2023.
//

import DevToolsCore
import Combine

protocol CurrencyRepository {
    // Remote data
    func refreshCurrencies() async
    func refreshCurrencyRate() async
    
    // Local data
    func observeCurrencies() -> AnyPublisher<[Currency], Never>
    func getCurrencies() async -> [Currency]
    func getRates() async -> [CurrencyRate]
    func observeRates() -> AnyPublisher<[CurrencyRate], Never>
}
