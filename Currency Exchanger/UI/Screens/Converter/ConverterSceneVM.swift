//
//  ConverterSceneVM.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import SwiftUI
import RealmSwift
import DevToolsCore
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
        var rateHandle: AnyCancellable?
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
    private var fetchedRates: [CurrencyRate]?
    private let bag = Bag()
//    private var currencyRateRefreshTimer: Timer
    private let currencyRateInterval: TimeInterval = 60
    
    // MARK: Init
    
    init(balanaceRepository: CurrencyBalanceRepositoryProtocol,
         currencyRepository: CurrencyRepositoryProtocol,
         currencyConverter: CurrencyCoverterProtocol) {
        self.balanaceRepository = balanaceRepository
        self.currencyRepository = currencyRepository
        self.currencyConverter = currencyConverter
        startup()
    }

    deinit {
//        currencyRateRefreshTimer.invalidate()
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
                throw CurrencyConversionError.currencyNotFound
            }

            guard let balance = balanaceRepository.getBalance(forCurrency: sellCurrency) else {
                throw CurrencyConversionError.notEnough
            }
            let rates = currencyRepository.getRates()
            let result = try currencyConverter.convert(fromCurrency: sellCurrency, toCurrency: buyCurrency,
                                                       amount: sellVM.amountInput, balance: balance.balance, rates: rates)
            // Update db with new balance
            if let previousBuyCurrency: CurrencyBalance = balanaceRepository.getBalance(forCurrency: buyCurrency) {
                // Add new balance + previous
                let newToBalance: CurrencyBalance = .init(id: result.to.id, balance: result.to.balance + previousBuyCurrency.balance)
                balanaceRepository.addOrUpdate(currencyBalance: [result.from,  newToBalance])
            } else {
                // New balance
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
            case .rateUnknown, .currencyNotFound:
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
    
    private func startup() {
//        currencyRateRefreshTimer = .scheduledTimer(withTimeInterval: currencyRateInterval, repeats: true, block: {_ in
//            currencyRepository.refreshCurrencyRate {}
//        })
        subscribeToNotifications()
        refreshRemoteData()
        sections = createSections()
    }
    
    private func refreshRemoteData() {
        currencyRepository.refreshCurrencies {
            print("Refreshed currencies")
        }
        currencyRepository.refreshCurrencyRate {
            print("Refreshed currency rate")
        }
    }
    
    private func subscribeToNotifications() {
        bag.balanceHandle = balanaceRepository.observeBalance().removeDuplicates().sink { [weak self] balance in
            self?.onBalanceChanged(balance: balance)
        }
        bag.rateHandle = currencyRepository.observeRates().removeDuplicates().sink { [weak self] rates in
            self?.onRatesChanged(rates: rates)
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
    
    private func onRatesChanged(rates: [CurrencyRate]) {
        fetchedRates = rates
        // Update input fields because rates changed
        // TODO: Implement specific methods to do so
        if let buyAmountCellVM = buyAmountCellVM {
            exchangeCurrencyVM(vm: buyAmountCellVM, amountChanged: buyAmountCellVM.amountInput)
        }
        if let sellAmountCellVM = sellAmountCellVM {
            exchangeCurrencyVM(vm: sellAmountCellVM, amountChanged: sellAmountCellVM.amountInput)
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
    
    private func onEstimateConversion(action: ConversionAction, inputAmount: Double) throws -> CurrencyConversionResult {
        guard
            let sellVM = sellAmountCellVM,
            let buyVM = buyAmountCellVM,
            let sellCurrency = sellVM.selectedCurrency,
            let buyCurrency = buyVM.selectedCurrency,
            let rates = fetchedRates
        else {
            throw CurrencyConversionError.rateUnknown
        }
        
        let result = try currencyConverter.estimate(sellCurrency: sellCurrency, buyCurrency: buyCurrency,
                                                     action: action, amount: inputAmount, rates: rates)
        return result
    }
    
    private func makeConversionMessage(fromAmount: Double, fromCurrency: Currency,
                                       toAmount: Double, toCurrency: Currency) -> String {
        return "You have converted \(fromAmount) \(fromCurrency.id) to \(toAmount) \(toCurrency.id)"
    }
}

extension ConverterSceneVM: ExchangeCurrencyVMDelegate {
    func exchangeCurrencyVM(vm: ExchangeCurrencyVM, amountChanged amount: Double) {
        let action: ConversionAction = vm.option == .buy ? .buy : .sell
        let estimated = try? onEstimateConversion(action: action, inputAmount: amount)
        let targetVM: ExchangeCurrencyVM? = vm.option == .buy ? sellAmountCellVM : buyAmountCellVM
        targetVM?.onReplaceInput(withPreCalculatedAmount: estimated?.to.balance ?? 0.0)
    }
}
