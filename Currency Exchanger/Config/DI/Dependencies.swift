//
//  Dependencies.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 26/04/2023.
//

import Foundation
import Swinject
import RealmSwift
import DevToolsCore
import DevToolsNetworking
import DevToolsRealm
import Moya

let DI: Container = {
    let container = Container()
    container.register(Realm.self) { _ in try! Realm() }
    container.register(User.self) { _ in
        User(id: "MAIN", name: "James", surname: "Bond")
    }
    container.register(Realm.Configuration.self) { resolver in
        Realm.Configuration()
    }
    container.register(PersistentRealmStore<User>.self) { resolver in
        PersistentRealmStore(dbConfig: resolver.resolve(Realm.Configuration.self)!)
    }
    container.register(UserRepositoryProtocol.self) { resolver in
        UserRepository(userStore: resolver.resolve(PersistentRealmStore<User>.self)!)
    }
    container.register(PersistentRealmStore<CurrencyBalance>.self) { resolver in
        PersistentRealmStore(dbConfig: resolver.resolve(Realm.Configuration.self)!)
    }
    container.register(CurrencyBalanceRepositoryProtocol.self) { resolver in
        CurrencyBalanceRepository(currencyBalanceStore: resolver.resolve(PersistentRealmStore<CurrencyBalance>.self)!)
    }
    container.register(PersistentRealmStore<CurrencyRate>.self) { resolver in
        PersistentRealmStore(dbConfig: resolver.resolve(Realm.Configuration.self)!)
    }
    container.register(PersistentRealmStore<Currency>.self) { resolver in
        PersistentRealmStore(dbConfig: resolver.resolve(Realm.Configuration.self)!)
    }
    container.register(MoyaProvider<CurrencyAPITarget>.self) { resolver in
        MoyaProvider<CurrencyAPITarget>()
    }
    container.register(RequestManager<CurrencyAPITarget>.self) { resolver in
        RequestManager<CurrencyAPITarget>()
    }
    container.register(CurrencyProviderProtocol.self) { resolver in
        CurrencyProvider(provider: resolver.resolve(MoyaProvider<CurrencyAPITarget>.self)!,
                        requestManager: resolver.resolve(RequestManager<CurrencyAPITarget>.self)!)
    }
    container.register(CurrencyRepositoryProtocol.self) { resolver in
        CurrencyRepository(currencyStore: resolver.resolve(PersistentRealmStore<Currency>.self)!,
                           currencyAPIService: resolver.resolve(CurrencyProviderProtocol.self)!,
                           currencyRateStore: resolver.resolve(PersistentRealmStore<CurrencyRate>.self)!)
    }
    container.register(CurrencyCoverterProtocol.self) { resolver in
        CurrencyCoverter()
    }
    
    return container
}()
