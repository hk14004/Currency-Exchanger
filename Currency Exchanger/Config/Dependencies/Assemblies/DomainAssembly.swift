//
//  DomainAssembly.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 13/05/2023.
//

import Foundation
import Swinject
import DevToolsCore

class DomainAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(User.self) { _ in
            User(id: "007", name: "James", surname: "Bond")
        }
        
        container.register(CurrencyExchanger.self) { resolver in
            CurrencyExchangerImpl()
        }
    }
    
}

