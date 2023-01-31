//
//  UserRepository.swift
//  User Exchanger
//
//  Created by Cube on 31/01/2023.
//

import DevTools
import DevToolsRealm
import RealmSwift
import Combine

protocol UserRepositoryProtocol {
    func getUser(id: String) -> User?
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
        return userStore.getSingle(id: id)
    }
}
