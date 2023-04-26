//
//  CurrencyBalance.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import Foundation
import DevToolsCore
import RealmSwift
import DevToolsRealm

class CurrencyBalance_DB: Object {
    
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var balance: Decimal128
    
    // Archivable
    var isArchived: Bool = false
    
}

extension CurrencyBalance_DB: Archivable {
    func archive(_ archive: Bool) {
        isArchived = archive
    }
}
