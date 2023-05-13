//
//  DataProviderAssambly.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 13/05/2023.
//

import Foundation
import Swinject
import Moya
import DevToolsNetworking

class DataProviderAssambly: Assembly {
    
    func assemble(container: Container) {
        container.register(MoyaProvider<CurrencyAPITarget>.self) { resolver in
            MoyaProvider()
        }.inObjectScope(.container)
        
        container.register(RequestManager<CurrencyAPITarget>.self) { resolver in
            RequestManager()
        }.inObjectScope(.container)
        
        container.register(CurrencyProvider.self) { resolver in
            CurrencyProviderImpl(provider: resolver.resolve(MoyaProvider<CurrencyAPITarget>.self)!,
                                 requestManager: resolver.resolve(RequestManager<CurrencyAPITarget>.self)!)
        }.inObjectScope(.container)
    }
    
}
