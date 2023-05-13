//
//  CurrencyProvider.swift
//  Currency Exchanger
//
//  Created by Hardijs on 31/01/2023.
//

import Foundation

//http://api.apilayer.com/exchangerates_data/latest

enum CurrencyProviderError: Swift.Error {
    case requestAlreadyRunning
    case responseDecodeIssue
    case fetchFailed(code: Int)
    case userError(description: String)
}

protocol CurrencyProvider {
    func fetchCurrencies() async throws -> CurrencyResponse
    func fetchExchangeRatesData() async throws -> ExchangeRatesDataResponse
}
