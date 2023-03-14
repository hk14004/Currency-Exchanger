//
//  ConverterSceneVM.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import SwiftUI
import RealmSwift
import DevTools
import Combine
import DevToolsUI

class ConverterSceneVM: ObservableObject {
    
    // MARK: Types
    
    enum SectionIdentifiers: String {
        case currencyExchange
        case myBallances
    }
    
    enum AlertType {
        case notEnoughMoney
        case cannotExchangeSameCurrency
        case unknownRate
        case providePositiveNumber
        case conversionSuccesful(message: String)
    }
    
    enum Cell: Hashable {
        case emptyWallet
        case currencyAmount(CurrencyBalance)
        case exchangeCurrency(ExchangeCurrencyVM)
        case performExchange
    }
    
    class Bag {
        var balanceHandle: AnyCancellable?
    }
    
    struct Section: UISectionModelProtocol {
        
        let uuid: String
        var title: String
        var cells: [Cell]
        
        init(uuid: String, title: String, cells: [Cell]) {
            self.uuid = uuid
            self.title = title
            self.cells = cells
        }
    }
    
    // MARK: Properties
    
    // Output
    @Published var sections: [Section] = []
    @Published var showAlert: Bool = false
    @Published var alertType: AlertType = .notEnoughMoney
    
    // Input
    private let balanaceRepository: CurrencyBalanceRepositoryProtocol
    private let currencyRepository: CurrencyRepositoryProtocol
    private let currencyConverter: CurrencyCoverterProtocol
    
    // Other
    private var sellAmountCellVM: ExchangeCurrencyVM?
    private var buyAmountCellVM: ExchangeCurrencyVM?
    private var fetchedBalanace: [CurrencyBalance]?
    private let bag = Bag()
    
    // MARK: Init
    
    init(balanaceRepository: CurrencyBalanceRepositoryProtocol,
         currencyRepository: CurrencyRepositoryProtocol,
         currencyConverter: CurrencyCoverterProtocol) {
        self.balanaceRepository = balanaceRepository
        self.currencyRepository = currencyRepository
        self.currencyConverter = currencyConverter
        subscribeToNotifications()
        sections = createSections()
    }

}

// MARK: Public

extension ConverterSceneVM {
    func onExchangeCurrencyTapped() {
        do {
            guard
                let sellVM = sellAmountCellVM,
                let buyVM = buyAmountCellVM,
                let sellCurrency = sellVM.selectedCurrency,
                let buyCurrency = buyVM.selectedCurrency
            else {
                return
            }

            guard let balance = balanaceRepository.getBalance(forCurrency: sellCurrency) else {
                throw CurrencyConversionError.notEnough
            }
            let rates = currencyRepository.getRates()
            let result = try currencyConverter.convert(fromCurrency: sellCurrency, toCurrency: buyCurrency,
                                                       amount: sellVM.amountInput, balance: balance.balance, rates: rates)
            // Update db with new balance
            if let previousBuyCurrency: CurrencyBalance = balanaceRepository.getBalance(forCurrency: buyCurrency) {
                balanaceRepository.addOrUpdate(currencyBalance: [result.from,  .init(id: result.to.id, balance: result.to.balance + previousBuyCurrency.balance)])
            } else {
                balanaceRepository.addOrUpdate(currencyBalance: [result.from, result.to])
            }
            let message = makeConversionMessage(fromAmount: sellVM.amountInput, fromCurrency: sellCurrency,
                                                toAmount: buyVM.amountInput, toCurrency: buyCurrency)
            alertType = .conversionSuccesful(message: message)
            showAlert = true
        } catch (let err) {
            let error = err as! CurrencyConversionError
            switch error {
            case .notEnough:
                alertType = .notEnoughMoney
            case .cannotExchangeSameCurrency:
                alertType = .cannotExchangeSameCurrency
            case .rateUnknown:
                alertType = .unknownRate
            case .amountMustBePositive:
                alertType = .providePositiveNumber
            }
            showAlert = true
        }
        
    }
}

// MARK: Private

extension ConverterSceneVM {
    private func subscribeToNotifications() {
        currencyRepository.refreshCurrencies {
            print("Refreshed currencies")
        }
        currencyRepository.refreshCurrencyRate {
            print("Refreshed currency rate")
        }
        bag.balanceHandle = balanaceRepository.observeBalance().sink { [weak self] balance in
            self?.onBalanceChanged(balance: balance)
        }
    }
    
    private func onBalanceChanged(balance: [CurrencyBalance]) {
        func onUpdateUI() {
            let updatedSection = createMyBalanceSection(items: balance)
            sections.update(section: updatedSection)
        }
        
        let animate: Bool = fetchedBalanace != nil
        fetchedBalanace = balance
        
        // Update UI
        
        if animate {
            withAnimation {
                onUpdateUI()
            }
        } else {
            onUpdateUI()
        }
    }
    
    private func createSections() -> [Section] {
        var sections: [Section] = []
        sections.append(createCurrencyExchangeSection())
        sections.append(createMyBalanceSection(items: fetchedBalanace ?? []))
        return sections
    }
    
    private func createMyBalanceSection(items: [CurrencyBalance]) -> Section {
        let balanceCells: [Cell] = items.compactMap { balance -> Cell? in
            if balance.balance <= 0 {
                return nil
            }
            return Cell.currencyAmount(balance)
        }
        var cells: [Cell] = []
        if balanceCells.isEmpty {
            cells.append(.emptyWallet)
        } else {
            cells = balanceCells
        }
        return Section(uuid: SectionIdentifiers.myBallances.rawValue, title: "MY BALANCES", cells: cells)
    }
    
    private func createCurrencyExchangeSection() -> Section {
        let sellVM = ExchangeCurrencyVM(option: .sell, amount: 0, currencyRepository: currencyRepository)
        self.sellAmountCellVM = sellVM
        sellVM.delegate = self
        let buyVM = ExchangeCurrencyVM(option: .buy, amount: 0, currencyRepository: currencyRepository)
        self.buyAmountCellVM = buyVM
        buyVM.delegate = self
        
        let cells: [Cell] = [
            .exchangeCurrency(sellVM),
            .exchangeCurrency(buyVM),
            .performExchange
        ]
        return Section(uuid: SectionIdentifiers.currencyExchange.rawValue, title: "CURRENCY EXCHANGE", cells: cells)
    }
    
    private func onSellAmountInputChanged(amount: Double) {
        guard
            let sellVM = sellAmountCellVM,
            let buyVM = buyAmountCellVM,
            let sellCurrency = sellVM.selectedCurrency,
            let buyCurrency = buyVM.selectedCurrency
        else {
            return
        }
        
        let rates = currencyRepository.getRates()
        let result = currencyConverter.estimate(sellCurrency: sellCurrency, buyCurrency: buyCurrency, action: .sell,
                                                amount: amount, rates: rates)
        
        
        buyVM.onReplaceInput(withPreCalculatedAmount: result.to.balance)
    }
    
    private func onBuyAmountInputChanged(amount: Double) {
        guard
            let sellVM = sellAmountCellVM,
            let buyVM = buyAmountCellVM,
            let sellCurrency = sellVM.selectedCurrency,
            let buyCurrency = buyVM.selectedCurrency
        else {
            return
        }
        
        let rates = currencyRepository.getRates()
        let result = currencyConverter.estimate(sellCurrency: sellCurrency, buyCurrency: buyCurrency, action: .buy,
                                                amount: amount, rates: rates)
        
        
        sellVM.onReplaceInput(withPreCalculatedAmount: result.to.balance)
    }
    
    private func makeConversionMessage(fromAmount: Double, fromCurrency: Currency,
                                       toAmount: Double, toCurrency: Currency) -> String {
        return "You have converted \(fromAmount) \(fromCurrency.id) to \(toAmount) \(toCurrency.id)"
    }
}

extension ConverterSceneVM: ExchangeCurrencyVMDelegate {
    func exchangeCurrencyVM(vm: ExchangeCurrencyVM, amountChanged amount: Double) {
        switch vm.option {
        case .buy:
            onBuyAmountInputChanged(amount: amount)
        case .sell:
            onSellAmountInputChanged(amount: amount)
        }
    }
}
