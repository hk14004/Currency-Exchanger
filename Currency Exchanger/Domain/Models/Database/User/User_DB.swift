//
//  User.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import Foundation
import DevTools
import RealmSwift
import DevToolsRealm
import DevTools

class User_DB: Object {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var surname: String
    
    // Archivable
    var isArchived: Bool = false
    
}

extension User_DB: Archivable {
    func archive(_ archive: Bool) {
        isArchived = archive
    }
}
