//
//  CurrencyConverter.swift
//  Currency Exchanger
//
//  Created by Hardijs on 01/02/2023.
//

import Foundation
import DevToolsCore

enum CurrencyExchangeError: Error {
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

protocol CurrencyExchanger {
    func convert(fromCurrency: Currency, toCurrency: Currency, amount: Money,
                 balance: Money, rates: [CurrencyID: Decimal]) throws -> CurrencyConversionResult
    
    

    func estimate(sellCurrency: Currency, buyCurrency: Currency, action: ConversionAction,
                  amount: Money, rates: [CurrencyID: Decimal]) throws -> CurrencyConversionResult
}
