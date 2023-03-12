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

enum ConversionAction {
    case buy
    case sell
}

protocol CurrencyCoverterProtocol {
    func convert(fromCurrency: Currency, toCurrency: Currency, amount: Double,
                 balance: Double, rates: [CurrencyRate]) throws -> CurrencyConversionResult
    func estimate(sellCurrency: Currency, buyCurrency: Currency, action: ConversionAction,
                  amount: Double, rates: [CurrencyRate]) -> CurrencyConversionResult
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
        
        // TODO: Fix rounding
        let fromCurrencyBalance: CurrencyBalance = .init(id: fromCurrency.id, balance: left)
        let toCurrencyBalance: CurrencyBalance = .init(id: toCurrency.id, balance: ((amount / exchangeRateFrom.rate) * exchangeRateTo.rate).rounded(toPlaces: 2))
        
        return .init(from: fromCurrencyBalance, to: toCurrencyBalance)
    }
    
    
    func estimate(sellCurrency: Currency, buyCurrency: Currency, action: ConversionAction, amount: Double, rates: [CurrencyRate]) -> CurrencyConversionResult {
        func getFromCurrency() -> Currency {
            switch action {
            case .buy:
                return buyCurrency
            case .sell:
                return sellCurrency
            }
        }
        func getToCurrency() -> Currency {
            switch action {
            case .buy:
                return sellCurrency
            case .sell:
                return buyCurrency
            }
        }
        guard amount >= 0 else {
            return .init(from: .init(id: getFromCurrency().id, balance: 0), to: .init(id: getToCurrency().id, balance: 0))
        }
        guard sellCurrency.id != buyCurrency.id else {
            return .init(from: .init(id: getFromCurrency().id, balance: amount), to: .init(id: getToCurrency().id, balance: amount))
        }
        
        // TODO: Hash map find
        let exchangeRateFrom = rates.first(where: { $0.id == getFromCurrency().id })!
        let exchangeRateTo = rates.first(where: { $0.id == getToCurrency().id })!
        
        // TODO: Fix rounding
        let fromCurrencyBalance: CurrencyBalance = .init(id: getFromCurrency().id, balance: amount)
        let toCurrencyBalance: CurrencyBalance = .init(id: getToCurrency().id, balance: ((amount / exchangeRateFrom.rate) * exchangeRateTo.rate).rounded(toPlaces: 2))
        
        return .init(from: fromCurrencyBalance, to: toCurrencyBalance)
    }
}
