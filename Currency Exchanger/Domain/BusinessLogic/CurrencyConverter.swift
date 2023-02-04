//
//  CurrencyConverter.swift
//  Currency Exchanger
//
//  Created by Cube on 01/02/2023.
//

import Foundation

enum CurrencyConversionError: Error {
    case notEnough
    case cannotExchangeSameCurrency
    case rateUnknown
    case amountMustBePositive
}

struct CurrencyConversionResult {
    let from: CurrencyBalance
    let to: CurrencyBalance
}

protocol CurrencyCoverterProtocol {
    func convert(fromCurrency: Currency, toCurrency: Currency, amount: Double,
                 balance: Double, rates: [CurrencyRate]) throws -> CurrencyConversionResult
}

class CurrencyCoverter {
    
}

extension CurrencyCoverter: CurrencyCoverterProtocol {
    func convert(fromCurrency: Currency, toCurrency: Currency, amount: Double, balance: Double, rates: [CurrencyRate]) throws -> CurrencyConversionResult {
        guard amount > 0 else {
            throw CurrencyConversionError.amountMustBePositive
        }
        guard fromCurrency.id != toCurrency.id else {
            throw CurrencyConversionError.cannotExchangeSameCurrency
        }
        
        let left = balance - amount
        guard left >= 0.0 else {
            throw CurrencyConversionError.notEnough
        }
        
        // TODO: Hash map find
        guard let exchangeRateFrom = rates.first(where: { $0.id == fromCurrency.id }) else {
            throw CurrencyConversionError.rateUnknown
        }
        guard let exchangeRateTo = rates.first(where: { $0.id == toCurrency.id }) else {
            throw CurrencyConversionError.rateUnknown
        }
        
        let fromCurrencyBalance: CurrencyBalance = .init(id: fromCurrency.id, balance: left)
        let toCurrencyBalance: CurrencyBalance = .init(id: toCurrency.id, balance: ((amount / exchangeRateFrom.rate) * exchangeRateTo.rate).rounded(toPlaces: 2))
        
        return .init(from: fromCurrencyBalance, to: toCurrencyBalance)
    }
}
