//
//  RefreshCurrencyRatesTask.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 26/04/2023.
//

import Foundation
import DevToolsCore

class RefreshCurrencyRatesTask: PeriodicTaskBase<PeriodicTask> {
    
    // MARK: Properties
    
    private var timer: Timer?
    private let currencyRepository: CurrencyRepository
    
    // MARK: Init
    
    init(currencyRepository: CurrencyRepository) {
        self.currencyRepository = currencyRepository
        super.init(taskType: .refreshCurrencyRates)
    }
    
    // MARK: Methods
    
    override func registerTrigger() {
        timer = .scheduledTimer(withTimeInterval: 60, repeats: true, block: { [weak self] _ in
            self?.runWorkFlow()
        })
    }
    
    @objc override func work() async {
        await currencyRepository.refreshCurrencyRate()
    }
    
    deinit {
        timer?.invalidate()
    }
}
