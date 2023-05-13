//
//  DataMapperAssembly.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 13/05/2023.
//

import Foundation
import Swinject
import DevToolsCore

class DataMapperAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(CurrencyResponseMapper.self) { resolver in
            CurrencyResponseMapperImpl()
        }
        container.register(CurrencyRateResponseMapper.self) { resolver in
            CurrencyRateResponseMapperImpl()
        }
    }
    
}
