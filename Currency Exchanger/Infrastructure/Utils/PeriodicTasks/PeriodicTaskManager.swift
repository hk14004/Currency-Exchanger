//
//  PeriodicTaskManager.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 26/04/2023.
//

import Foundation
import DevToolsCore

class AppPeriodicTaskManager: PeriodicTaskManager<PeriodicTask> {
    
    static let shared = AppPeriodicTaskManager()
    
}

// MARK: Public

extension AppPeriodicTaskManager {
    func startup() {
        registerStartupTasks()
    }
}

// MARK: Private

extension AppPeriodicTaskManager {
    private func registerStartupTasks() {
        registerRefreshCurrencyRatesTask()
    }

    private func registerRefreshCurrencyRatesTask() {
        let task = RefreshCurrencyRatesTask(currencyRepository: DI.container.resolve(CurrencyRepository.self)!)
        registerTask(task: task)
    }
}
