//
//  CurrencyRate.swift
//  Currency Exchanger
//
//  Created by Cube on 02/02/2023.
//

import Foundation
import DevToolsRealm
import RealmSwift

class CurrencyRate_DB: Object {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var rate: Double
    
}
