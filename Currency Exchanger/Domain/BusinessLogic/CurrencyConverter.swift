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
}

struct CurrencyConversionResult {
    let from: CurrencyBalance
    let to: CurrencyBalance
}

protocol CurrencyCoverterProtocol {
    func convert(balance: CurrencyBalance, amount: Double, intoCurrency: Currency, rate: Double) throws -> CurrencyConversionResult
}

class CurrencyCoverter {
    
}

extension CurrencyCoverter: CurrencyCoverterProtocol {
    func convert(balance: CurrencyBalance, amount: Double, intoCurrency: Currency, rate: Double) throws -> CurrencyConversionResult {
        guard balance.id != intoCurrency.id else {
            throw CurrencyConversionError.cannotExchangeSameCurrency
        }
        let left = balance.balance - amount
        guard left >= 0.0 else {
            throw CurrencyConversionError.notEnough
        }
        let updatedFromBalanace: CurrencyBalance = .init(id: balance.id, balance: left)
        let newCurrencyBalance: CurrencyBalance = .init(id: intoCurrency.id, balance: amount * rate)
        
        return .init(from: updatedFromBalanace, to: newCurrencyBalance)
    }
}
