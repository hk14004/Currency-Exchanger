//
//  Globals.swift
//  Currency Exchanger
//
//  Created by Hardijs on 11/03/2023.
//

import Foundation
import DevToolsCore

class Globals {
    
    static func prepareTestUser() {
        let container = DI
        let user = container.resolve(User.self)!
        let userRepo = container.resolve(UserRepositoryProtocol.self)!
        guard userRepo.getUser(id: user.id) == nil else {
            // User already created
            return
        }
        // Add main user
        userRepo.addOrUpdate(user: user)
        
        // Add initial balance
        let curBalanceRepo = container.resolve(CurrencyBalanceRepositoryProtocol.self)!
        curBalanceRepo.setBalance([.init(id: "EUR", balance: 1000)])
    }
    
    static func printAppsState() {
        let container = DI
        sanityCheck {
            // Check user
            let user = container.resolve(User.self)!
            let userRepo = container.resolve(UserRepositoryProtocol.self)!
            print("User:")
            print(userRepo.getUser(id: user.id)!)
            
            // Check balance
            let curBalanceRepo = container.resolve(CurrencyBalanceRepositoryProtocol.self)!
            print("Balance:")
            print(curBalanceRepo.getBalance())
            
            // Check currencies
            let currencyRepo = container.resolve(CurrencyRepositoryProtocol.self)!
            print("Currencies:")
            print(currencyRepo.getCurrencies())
            
            // Check rates
            print("Rates:")
            print(currencyRepo.getRates().count)
        }
    }
}
