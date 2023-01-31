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
    @Persisted var currencyBalance = List<CurrencyBalance_DB>()
    
    // Archivable
    var isArchived: Bool = false
    
}

extension User_DB: Archivable {
    func archive(_ archive: Bool) {
        isArchived = archive
    }
}

extension User_DB: PartialyJSONUpdateable {
    
    enum Field: String, JSONMappedField, OservableField {
        case currencyBalance
        
        func getKnownJSONKeys() -> [String] {
            switch self {
            case .currencyBalance:
                return ["currencyBalance"]
            }
        }
    }
    
    func updateFields(withJson json: NSDictionary, fields: Set<Field>, updateOnlyWhenFieldDataExists: Bool) {
        fields.forEach { field in
            switch field {
            case .currencyBalance:
                currencyBalance.removeAll()
                let data = field.getFieldValue(fromJSON: json) as? [NSDictionary] ?? []
                let list = data.map({ CurrencyBalance_DB(json: $0, fields: .init(CurrencyBalance_DB.Field.allCases), updateOnlyWhenFieldDataExists: false)})
                currencyBalance.append(objectsIn: list)
            }
        }
    }
}

//extension User_DB: PartialyObservable {
//    typealias FieldType = Field
//}
