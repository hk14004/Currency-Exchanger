//
//  UserRepository.swift
//  User Exchanger
//
//  Created by Cube on 31/01/2023.
//

import DevToolsCore
import DevToolsRealm
import RealmSwift
import Combine

protocol UserRepositoryProtocol {
    func getUser(id: String) -> User?
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
        return nil
//        return userStore.getSingle(id: id)
    }
    
    func addOrUpdate(user: User) {
//        userStore.addOrUpdate([user])
    }
}
