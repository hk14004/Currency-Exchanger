//
//  CurrencyBalanceItemVM.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import SwiftUI
import RealmSwift

class CurrencyBalanceItemVM: ObservableObject {
    
    class Bag {
        var balanceHandle: NotificationToken?
    }
    
    private let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()
    private let bag = Bag()
    
    @Published var currencyBalanceItem: CurrencyBalance
    
    init(currencyBalanceItem: CurrencyBalance) {
        self.currencyBalanceItem = currencyBalanceItem
        subscribeToNotifications()
    }
    
}

// MARK: Public

extension CurrencyBalanceItemVM {
    func getBalanceString() -> String {
        numberFormatter.string(from: currencyBalanceItem.balance as NSNumber)!
    }
}

// MARK: Private

extension CurrencyBalanceItemVM {
    private func subscribeToNotifications() {
//        bag.balanceHandle = currencyBalanceItem.observe({ [unowned self] change in
//            withAnimation {
//                objectWillChange.send()
//            }
//        })
    }
}
