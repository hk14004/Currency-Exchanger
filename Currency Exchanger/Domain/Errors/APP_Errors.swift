//
//  APP_Errors.swift
//  Currency Exchanger
//
//  Created by Cube on 02/02/2023.
//

import Foundation

enum APP_Errors: String, Error {
    
    // MARK: Network
    
    case networkRequestAlreadyRunning
    case networkRequestDataIssue
    
    // MARK: General
    
    case unknown
    
}
