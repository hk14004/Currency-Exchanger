//
//  CurrencyBalance.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import Foundation
import DevTools
import RealmSwift
import DevToolsRealm

class CurrencyBalance_DB: Object {
    
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var balance: Double
    
    // Archivable
    var isArchived: Bool = false
    
    override init() {
        super.init()
    }
    
    init(json: NSDictionary, fields: Set<Field>, updateOnlyWhenFieldDataExists: Bool) {
        super.init()
        let key: String = {
            let v = "\(json.value(forKey: "id") ?? "")"
            return v
        }()
        if !key.isEmpty {
            id = key
        }
        updateFields(withJson: json, fields: fields, updateOnlyWhenFieldDataExists: updateOnlyWhenFieldDataExists)
    }
}

extension CurrencyBalance_DB: Archivable {
    func archive(_ archive: Bool) {
        isArchived = archive
    }
}

extension CurrencyBalance_DB: PartialyJSONUpdateable {
    
    enum Field: JSONMappedField {
        case balance
        
        func getKnownJSONKeys() -> [String] {
            switch self {
            case .balance:
                return ["balance"]
            }
        }
        
    }
    
    func updateFields(withJson json: NSDictionary, fields: Set<Field>, updateOnlyWhenFieldDataExists: Bool) {
        fields.forEach { field in
            switch field {
            case .balance:
                balance = field.getFieldValue(fromJSON: json) as? Double ?? 0
            }
        }
    }
}
