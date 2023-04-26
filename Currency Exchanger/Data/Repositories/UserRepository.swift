//
//  UserRepository.swift
//  User Exchanger
//
//  Created by Hardijs on 31/01/2023.
//

import DevToolsCore
import DevToolsRealm
import RealmSwift
import Combine

protocol UserRepositoryProtocol {
    func getUser(id: String) async -> User?
    func getUser(id: String) -> User?
    
    func addOrUpdate(user: User) async
    func addOrUpdate(user: User)
}

class UserRepository {
    
    // MARK: Properties
    
    private var userStore: PersistentRealmStore<User>
    
    // MARK: Init
    
    init(userStore: PersistentRealmStore<User>) {
        self.userStore = userStore
    }
    
}

extension UserRepository: UserRepositoryProtocol {
    func getUser(id: String) -> User? {
        userStore.getSingle(id: id)
    }
    
    func addOrUpdate(user: User) {
        userStore.addOrUpdate([user])
    }
    
    func getUser(id: String) async -> User? {
        await userStore.getSingle(id: id)
    }
    
    func addOrUpdate(user: User) async {
        await userStore.addOrUpdate([user])
    }
}
