//
//  CurrencyAPITarget.swift
//  Currency Exchanger
//
//  Created by Cube on 01/02/2023.
//

import Foundation
import DevToolsCore
import DevToolsNetworking
import Moya

struct CurrencyAPITarget: RequestManagerTarget {
    
    enum Endpoint: String, CaseIterable {
        case getRates
    }
    
    var endpoint: Endpoint
        
    var defaultUUID: String {
        endpoint.rawValue
    }
    
    var resourceIDs: [String]?
    
    var urlParameters: [String : Any]?
    
    var bodyParameters: [String : Any]?
    
    var headerParameter: [String : String]?
    
    var baseURL: URL {
        return URL(string: Hosts.CURRENCY_API_HOST)!
    }
    
    var path: String {
        switch endpoint {
        case .getRates:
            return "/exchangerates_data/latest"
        }
    }
    
    var method: Moya.Method {
        switch endpoint {
        case .getRates:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self.method {
        case .get:
            if let urlParameters = urlParameters {
                return .requestParameters(parameters: urlParameters, encoding: URLEncoding.queryString)
            }
        default:
            if let bodyParameters = bodyParameters {
                return .requestParameters(parameters: bodyParameters, encoding: JSONEncoding.default)
            }
        }
        
        return .requestPlain
    }
    
    var headers: [String : String]?
    
}
