//
//  CurrencyBalance.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import Foundation
import DevTools
import RealmSwift

class CurrencyBalance: Object {
    
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

extension CurrencyBalance: Archivable {
    func archive(_ archive: Bool) {
        isArchived = archive
    }
}

extension CurrencyBalance: PartialyUpdateable {
    
    enum Field: MappedField {
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
