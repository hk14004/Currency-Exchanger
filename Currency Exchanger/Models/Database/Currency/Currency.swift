//
//  Currency.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import Foundation
import DevTools
import RealmSwift

class Currency: Object {
    
    @Persisted(primaryKey: true) var id: String
    
    // Archivable
    @Persisted var isArchived: Bool = false
    
}

extension Currency: Archivable {
    func archive(_ archive: Bool) {
        isArchived = archive
    }
}
