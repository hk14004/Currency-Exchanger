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

protocol ExchangeCurrencyVMDelegate: AnyObject {
    func exchangeCurrencyVM(vm: ExchangeCurrencyVM, amountChanged amount: Double)
}

class ExchangeCurrencyVM: ObservableObject {
    
    enum Option: Int {
        case buy
        case sell
    }
    
    enum FieldType {
        case inputAmount
        case calculatedAmount // TODO: Implement
    }
    
    class Bag {
        var currenciesHandle: AnyCancellable?
    }
    
    let uuid: String = UUID().uuidString
    let option: Option
    private let bag = Bag()
    @Published var amountInput: Double {
        didSet {
            onAmountInputChanged()
        }
    }
    @Published var selectedCurrency: Currency? {
        didSet {
            onAmountInputChanged()
        }
    }
    @Published var availableCurrencies: [Currency] = []
    @Published var fieldType: FieldType = .inputAmount
    
    private var fetchedCurrencies: [Currency]?
    private let currencyRepository: CurrencyRepositoryProtocol
    private(set) var amountChangedDate: Date?
    weak var delegate: ExchangeCurrencyVMDelegate?
    private var skip = false
    
    init(option: Option, amount: Double, currencyRepository: CurrencyRepositoryProtocol) {
        self.option = option
        self.amountInput = amount
        self.currencyRepository = currencyRepository
        subscribeToNotifications()
    }
}


extension ExchangeCurrencyVM {
    func onReplaceInput(withPreCalculatedAmount amount: Double) {
        fieldType = .calculatedAmount
        skip = true
        amountInput = amount
    }
}

extension ExchangeCurrencyVM {
    private func subscribeToNotifications() {
        bag.currenciesHandle = currencyRepository.observeCurrencies().sink(receiveValue: { [unowned self] currencies in
            fetchedCurrencies = currencies
            availableCurrencies = currencies
            selectedCurrency = currencies.first
        })
    }
    
    private func onAmountInputChanged() {
        amountChangedDate = Date()
        if !skip {
            delegate?.exchangeCurrencyVM(vm: self, amountChanged: amountInput)
        }
        skip = false
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
