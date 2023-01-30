//
//  User + CurrencyExchange.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import Foundation

extension User {
    // TODO: Add commission fee
    func hasEnoughCurrency(currencyID: String, amount: Double) -> Bool {
        guard let currencyBalance: CurrencyBalance = currencyBalance.first(where: {$0.id == currencyID}) else {
            return false
        }
        return currencyBalance.balance >= amount
    }
    
    // TODO: Throw error
    func exchange(fromCurrencyID: String, amount: Double, toCurrencyID: String) -> Bool {
        guard hasEnoughCurrency(currencyID: fromCurrencyID, amount: amount) else {
            return false
        }
        guard let foundBalance: CurrencyBalance = currencyBalance.first(where: {$0.id == fromCurrencyID}) else {
            return false
        }
        
        realm?.bulkWrite(writeOperation: {
            if let existingBalance = realm!.object(ofType: CurrencyBalance.self, forPrimaryKey: toCurrencyID) {
                existingBalance.balance += amount * 1
            } else {
                let new = CurrencyBalance()
                new.id = toCurrencyID
                new.balance = Double(amount * 1)
                currencyBalance.append(objectsIn: [new])
            }
            
            foundBalance.balance -= amount
            if foundBalance.balance <= 0 {
                foundBalance.archive(true)
            }
        })
        
        return true
    }
}
