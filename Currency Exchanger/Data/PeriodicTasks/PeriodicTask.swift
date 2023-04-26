//
//  PeriodicTask.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 26/04/2023.
//

import Foundation
import DevToolsCore

enum PeriodicTask: String, PeriodTaskTypeProtocol {
    case refreshCurrencyRates
}
