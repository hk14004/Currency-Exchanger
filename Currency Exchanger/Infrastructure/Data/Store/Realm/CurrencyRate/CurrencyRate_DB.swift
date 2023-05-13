//
//  CurrencyRate.swift
//  Currency Exchanger
//
//  Created by Hardijs on 02/02/2023.
//

import Foundation
import DevToolsRealm
import RealmSwift
import DevToolsCore

class CurrencyRate_DB: Object {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var rate: Decimal128
    
}
