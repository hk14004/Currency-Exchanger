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

class UserRepositoryImpl {
    
    // MARK: Properties
    
    private var userStore: BasePersistedLayerInterface<User>
    
    // MARK: Init
    
    init(userStore: BasePersistedLayerInterface<User>) {
        self.userStore = userStore
    }
    
}

extension UserRepositoryImpl: UserRepository {
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
