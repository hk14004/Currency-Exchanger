//
//  PersistentRealmStoreAssembly.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 13/05/2023.
//

import Swinject
import DevToolsCore
import DevToolsRealm
import RealmSwift

// Optionaly run realm
class PersistentRealmStoreAssembly: Assembly {

    func assemble(container: Container) {
        // MARK: Realm stack

        container.register(Realm.Configuration.self) { resolver in
            Realm.Configuration()
        }

        // MARK: Entities

        container.register(BasePersistedLayerInterface<User>.self) { resolver in
            PersistentRealmStore<User>(dbConfig: resolver.resolve(Realm.Configuration.self)!)
        }.inObjectScope(.container)
        
        container.register(BasePersistedLayerInterface<Currency>.self) { resolver in
            PersistentRealmStore<Currency>(dbConfig: resolver.resolve(Realm.Configuration.self)!)
        }.inObjectScope(.container)
        
        container.register(BasePersistedLayerInterface<CurrencyRate>.self) { resolver in
            PersistentRealmStore<CurrencyRate>(dbConfig: resolver.resolve(Realm.Configuration.self)!)
        }.inObjectScope(.container)
        
        container.register(BasePersistedLayerInterface<CurrencyBalance>.self) { resolver in
            PersistentRealmStore<CurrencyBalance>(dbConfig: resolver.resolve(Realm.Configuration.self)!)
        }.inObjectScope(.container)
    }
    
}
