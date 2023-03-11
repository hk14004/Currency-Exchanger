//
//  Currency.swift
//  Currency Exchanger
//
//  Created by Cube on 31/01/2023.
//

import Foundation

struct Currency {
    let id: String
}

extension Currency: Codable {}
extension Currency: Hashable {}
