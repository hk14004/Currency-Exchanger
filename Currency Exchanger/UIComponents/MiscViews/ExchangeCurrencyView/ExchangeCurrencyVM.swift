//
//  SellCurrencyVM.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import SwiftUI
import Foundation
import RealmSwift

class ExchangeCurrencyVM: ObservableObject {
    
    enum Option: Int {
        case buy
        case sell
    }
    
    class Bag {
        var currenciesHandle: NotificationToken?
    }
    
    let uuid: String = UUID().uuidString
    let option: Option
    private let bag = Bag()
    @Published var amount: Double
    @Published var selectedCurrency: Currency_DB!
    @Published var availableCurrencies: [Currency_DB]
    
    private let database: Realm
    
    private lazy var storedCurrencies: Results<Currency_DB> = {
        return database.objects(Currency_DB.self).filterUnarchived()
    }()
    
    init(option: Option, amount: Double, database: Realm) {
        self.option = option
        self.amount = amount
        self.database = database
        self.availableCurrencies = []
        self.availableCurrencies = Array(storedCurrencies)
        self.selectedCurrency = availableCurrencies.first!
        subscribeToNotifications()
    }
}

extension ExchangeCurrencyVM {
    private func subscribeToNotifications() {
        bag.currenciesHandle = storedCurrencies.observe({ [unowned self] change in
            withAnimation {
                availableCurrencies = Array(storedCurrencies)
            }
        })
    }
}

extension ExchangeCurrencyVM: Hashable {
    static func == (lhs: ExchangeCurrencyVM, rhs: ExchangeCurrencyVM) -> Bool {
        lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
}
