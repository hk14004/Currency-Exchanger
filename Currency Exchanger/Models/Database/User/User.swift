//
//  User.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import Foundation
import DevTools
import RealmSwift

class User: Object {
    
    @Persisted(primaryKey: true) var id: String
    @Persisted var currencyBalance = List<CurrencyBalance>()
    
    // Archivable
    var isArchived: Bool = false
    
}

extension User: Archivable {
    func archive(_ archive: Bool) {
        isArchived = archive
    }
}

extension User: PartialyUpdateable {
    
    enum Field: String, MappedField, OservableField {
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
                let list = data.map({ CurrencyBalance(json: $0, fields: .init(CurrencyBalance.Field.allCases), updateOnlyWhenFieldDataExists: false)})
                currencyBalance.append(objectsIn: list)
            }
        }
    }
}

extension User: PartialyObservable {
    typealias FieldType = Field
}
