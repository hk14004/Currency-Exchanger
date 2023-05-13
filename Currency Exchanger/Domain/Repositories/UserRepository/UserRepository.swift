//
//  UserRepository.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 13/05/2023.
//

import DevToolsCore
import Combine

protocol UserRepository {
    func getUser(id: String) async -> User?
    func getUser(id: String) -> User?
    
    func addOrUpdate(user: User) async
    func addOrUpdate(user: User)
}
