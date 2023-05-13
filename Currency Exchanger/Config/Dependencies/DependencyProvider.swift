//
//  DependencyProvider.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 13/05/2023.
//

import Foundation
import Swinject

let DI = DependencyProvider()

class DependencyProvider {
    
    let container = Container()
    let assembler: Assembler
    
    init() {
        assembler = Assembler(
            [
                DomainAssembly(),
                DataMapperAssembly(),
                DataProviderAssambly(),
                PersistentRealmStoreAssembly(),
                RepositoryAssembly(),
            ],
            container: container
        )
    }
}
