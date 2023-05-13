//
//  CurrencyConverter.swift
//  Currency Exchanger
//
//  Created by Hardijs on 01/02/2023.
//

import Foundation
import DevToolsCore

enum CurrencyExchangeServiceError: Error {
    case notEnough
    case cannotExchangeSameCurrency
    case rateUnknown
    case amountMustBePositive
    case currencyNotFound
}

struct CurrencyConversionResult {
    let from: CurrencyBalance
    let to: CurrencyBalance
}

enum ConversionAction {
    case buy
    case sell
}

protocol CurrencyExchangeService {
    func convert(fromCurrency: Currency, toCurrency: Currency, amount: Money,
                 balance: Money, rates: [CurrencyID: Decimal]) throws -> CurrencyConversionResult
    
    

    func estimate(sellCurrency: Currency, buyCurrency: Currency, action: ConversionAction,
                  amount: Money, rates: [CurrencyID: Decimal]) throws -> CurrencyConversionResult
}

class CurrencyExchangeServiceImpl {
    
}

extension CurrencyExchangeServiceImpl: CurrencyExchangeService {
    func convert(fromCurrency: Currency, toCurrency: Currency, amount: DevToolsCore.Money, balance: DevToolsCore.Money, rates: [CurrencyID : Decimal]) throws -> CurrencyConversionResult {
        guard amount > 0 else {
            throw CurrencyExchangeServiceError.amountMustBePositive
        }
        guard fromCurrency.id != toCurrency.id else {
            throw CurrencyExchangeServiceError.cannotExchangeSameCurrency
        }
        let left: Money = (balance - amount).rounded()
        guard left >= 0.0 else {
            throw CurrencyExchangeServiceError.notEnough
        }
        guard
            let fromRate = rates[fromCurrency.id],
            let toRate = rates[toCurrency.id]
        else {
            throw CurrencyExchangeServiceError.rateUnknown
        }
        let fromCurrencyBalance: CurrencyBalance = .init(id: fromCurrency.id, balance: left)
        let toBalance: Money = ((amount / fromRate) * toRate).rounded()
        let toCurrencyBalance: CurrencyBalance = .init(id: toCurrency.id, balance: toBalance)
        
        return .init(from: fromCurrencyBalance, to: toCurrencyBalance)
    }
    
    func estimate(sellCurrency: Currency, buyCurrency: Currency, action: ConversionAction, amount: Money, rates: [CurrencyID : Decimal]) throws -> CurrencyConversionResult {
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
        
        let fromCurrency = getFromCurrency()
        let toCurrency = getToCurrency()
        
        guard amount >= 0 else {
            return .init(from: .init(id: fromCurrency.id, balance: 0), to: .init(id: getToCurrency().id, balance: 0))
        }
        guard sellCurrency.id != buyCurrency.id else {
            return .init(from: .init(id: fromCurrency.id, balance: amount), to: .init(id: toCurrency.id, balance: amount))
        }
        
        guard
            let fromRate = rates[fromCurrency.id],
            let toRate = rates[toCurrency.id]
        else {
            throw CurrencyExchangeServiceError.rateUnknown
        }
        
        let fromCurrencyBalance: CurrencyBalance = .init(id: fromCurrency.id, balance: amount)
        let toBalance: Money = ((amount / fromRate) * toRate).rounded()
        let toCurrencyBalance: CurrencyBalance = .init(id: toCurrency.id, balance: toBalance)

        return .init(from: fromCurrencyBalance, to: toCurrencyBalance)
    }
}
