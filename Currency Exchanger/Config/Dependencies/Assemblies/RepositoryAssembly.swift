//
//  RepositoryAssembly.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 13/05/2023.
//

import Foundation
import Swinject
import DevToolsCore
import DevToolsRealm

class RepositoryAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(CurrencyRepository.self) { resolver in
            CurrencyRepositoryImpl(currencyStore: resolver.resolve(BasePersistedLayerInterface<Currency>.self)!,
                                   currencyAPIService: resolver.resolve(CurrencyProvider.self)!,
                                   currencyRateStore: resolver.resolve(BasePersistedLayerInterface<CurrencyRate>.self)!,
                                   currencyRateResponseMapper: resolver.resolve(CurrencyRateResponseMapper.self)!,
                                   currencyResponseMapper: resolver.resolve(CurrencyResponseMapper.self)!)
        }.inObjectScope(.container)
        
        container.register(CurrencyBalanceRepository.self) { resolver in
            CurrencyBalanceRepositoryImpl(currencyBalanceStore: resolver.resolve(BasePersistedLayerInterface<CurrencyBalance>.self)!)
        }.inObjectScope(.container)
        
        container.register(UserRepository.self) { resolver in
            UserRepositoryImpl(userStore: resolver.resolve(BasePersistedLayerInterface<User>.self)!)
        }.inObjectScope(.container)
    }
    
}
