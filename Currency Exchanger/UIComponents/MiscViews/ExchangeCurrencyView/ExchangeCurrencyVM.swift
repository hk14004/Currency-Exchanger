//
//  SellCurrencyVM.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import SwiftUI
import Foundation
import RealmSwift
import Combine

class ExchangeCurrencyVM: ObservableObject {
    
    enum Option: Int {
        case buy
        case sell
    }
    
    class Bag {
        var currenciesHandle: AnyCancellable?
    }
    
    let uuid: String = UUID().uuidString
    let option: Option
    private let bag = Bag()
    @Published var amount: Double
    @Published var selectedCurrency: Currency?
    @Published var availableCurrencies: [Currency] = []
    
    private var fetchedCurrencies: [Currency]?
    private let currencyRepository: CurrencyRepositoryProtocol
    
    init(option: Option, amount: Double, currencyRepository: CurrencyRepositoryProtocol) {
        self.option = option
        self.amount = amount
        self.currencyRepository = currencyRepository
        subscribeToNotifications()
    }
}

extension ExchangeCurrencyVM {
    private func subscribeToNotifications() {
        bag.currenciesHandle = currencyRepository.observeCurrencies().sink(receiveValue: { [unowned self] currencies in
            let animate = fetchedCurrencies != nil
            fetchedCurrencies = currencies
            
            if animate {
                withAnimation {
                    availableCurrencies = currencies
                    selectedCurrency = currencies.first
                }
            } else {
                availableCurrencies = currencies
                selectedCurrency = currencies.first
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
