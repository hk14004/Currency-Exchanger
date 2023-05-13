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
        let user = DI.container.resolve(User.self)!
        let userRepo = DI.container.resolve(UserRepository.self)!
        guard userRepo.getUser(id: user.id) == nil else {
            // User already created
            return
        }
        // Add main user
        userRepo.addOrUpdate(user: user)
        
        // Add initial balance
        let curBalanceRepo = DI.container.resolve(CurrencyBalanceRepository.self)!
        Task {
            await curBalanceRepo.setBalance([.init(id: "EUR", balance: 1000)])
        }
    }
    
    static func printAppsState() {
        sanityCheck {
            // Check user
            let user = DI.container.resolve(User.self)!
            let userRepo = DI.container.resolve(UserRepository.self)!
            print("User:")
            print(userRepo.getUser(id: user.id)!)
            
            // Check balance
            let curBalanceRepo = DI.container.resolve(CurrencyBalanceRepository.self)!
            Task {
                print("Balance:")
                print(await curBalanceRepo.getBalance())
                
                // Check currencies
                let currencyRepo = DI.container.resolve(CurrencyRepository.self)!
                print("Currencies:")
                print(await currencyRepo.getCurrencies())
                
                // Check rates
                print("Rates:")
                print(await currencyRepo.getRates().count)
            }
        }
    }
}
