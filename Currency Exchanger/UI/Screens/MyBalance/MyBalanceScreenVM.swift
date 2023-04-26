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

class MyBalanceScreenVM: ObservableObject {
    
    // MARK: Types
    
    enum SectionIdentifiers: String {
        case currencyExchange
        case myBalances
    }
    
    enum AlertType {
        case notEnoughMoney
        case cannotExchangeSameCurrency
        case unknownRate
        case providePositiveNumber
        case conversionSuccesful(message: String)
    }
    
    enum Cell: Hashable {
        case walletPlacehoder
        case emptyWallet
        case currencyAmount(CurrencyBalance)
        case exchangeCurrency(ExchangeCurrencyVM)
        case performExchange
    }
    
    class Bag {
        var balanceHandle: AnyCancellable?
        var rateHandle: AnyCancellable?
    }
    
    class Cache {
        var fetchedBalanace: [CurrencyBalance]?
        var fetchedRates: [CurrencyID: Decimal]?
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
    @Published var exchangeInProgress: Bool = false
    
    // Input
    private let balanaceRepository: CurrencyBalanceRepositoryProtocol
    private let currencyRepository: CurrencyRepositoryProtocol
    private let currencyExchangeService: CurrencyExchangeServiceProtocol
    
    // Other
    private let cache = Cache()
    private lazy var sellAmountCellVM: ExchangeCurrencyVM = {
        let sellVM = ExchangeCurrencyVM(option: .sell, amount: 0, currencyRepository: currencyRepository)
        sellVM.delegate = self
        return sellVM
    }()
    private lazy var buyAmountCellVM: ExchangeCurrencyVM = {
        let buyVM = ExchangeCurrencyVM(option: .buy, amount: 0, currencyRepository: currencyRepository)
        buyVM.delegate = self
        return buyVM
    }()
    private let bag = Bag()
    
    // MARK: Init
    
    init(balanaceRepository: CurrencyBalanceRepositoryProtocol,
         currencyRepository: CurrencyRepositoryProtocol,
         currencyConverter: CurrencyExchangeServiceProtocol) {
        self.balanaceRepository = balanaceRepository
        self.currencyRepository = currencyRepository
        self.currencyExchangeService = currencyConverter
        startup()
    }
    
}

// MARK: Public

extension MyBalanceScreenVM {
    func onExchangeCurrencyTapped() {
        guard !exchangeInProgress else {
            return
        }
        exchangeInProgress = true
        Task {
            do {
                // Check selected currencies
                guard
                    let sellCurrency = sellAmountCellVM.selectedCurrency,
                    let buyCurrency = buyAmountCellVM.selectedCurrency
                else {
                    throw CurrencyExchangeServiceError.currencyNotFound
                }
                
                // Make sure rates are fetched
                guard let rates = cache.fetchedRates else {
                    throw CurrencyExchangeServiceError.rateUnknown
                }
                
                // Make sure balance can be found for selling currency
                guard let balanceItem = await balanaceRepository.getBalance(forCurrency: sellCurrency) else {
                    throw CurrencyExchangeServiceError.notEnough
                }
                
                try await performExchangeOperation(fromCurrency: sellCurrency, toCurrency: buyCurrency,
                                                   amount: sellAmountCellVM.amountInput, balance: balanceItem.balance, rates: rates)
                let message = makeConversionMessage(fromAmount: sellAmountCellVM.amountInput, fromCurrency: sellCurrency,
                                                    toAmount: buyAmountCellVM.amountInput, toCurrency: buyCurrency)
                DispatchQueue.main.async {
                    self.alertType = .conversionSuccesful(message: message)
                    self.showAlert = true
                    self.exchangeInProgress = false
                }
            } catch (let err) {
                DispatchQueue.main.async {
                    let error = err as! CurrencyExchangeServiceError
                    switch error {
                    case .notEnough:
                        self.alertType = .notEnoughMoney
                    case .cannotExchangeSameCurrency:
                        self.alertType = .cannotExchangeSameCurrency
                    case .rateUnknown, .currencyNotFound:
                        self.alertType = .unknownRate
                    case .amountMustBePositive:
                        self.alertType = .providePositiveNumber
                    }
                    self.showAlert = true
                    self.exchangeInProgress = false
                }
            }
        }
    }
}

// MARK: Private

extension MyBalanceScreenVM {
    
    private func startup() {
        Task {
            // TODO: Optionally fetch data in sync mode before creating sections
            // Create placeholder sections
            sections = makeSections()
            // Observe and get data, then update sections
            observe()
            await refreshRemoteData()
        }
    }
    
    private func makeSections() -> [Section] {
        var sections: [Section] = []
        sections.append(createCurrencyExchangeSection())
        sections.append(createMyBalanceSection(items: cache.fetchedBalanace))
        return sections
    }
    
    private func refreshRemoteData() async {
        await withTaskGroup(of: Void.self, body: { group in
            group.addTask {
                await self.currencyRepository.refreshCurrencies()
            }
            group.addTask {
                await self.currencyRepository.refreshCurrencyRate()
            }
        })
    }
    
    private func observe() {
        bag.balanceHandle = balanaceRepository.observeBalance().removeDuplicates().sink { [unowned self] balance in
            cache.fetchedBalanace = balance
            updateMyBalanceSection()
        }
        bag.rateHandle = currencyRepository.observeRates().removeDuplicates().sink { [unowned self] rates in
            cache.fetchedRates = rates.reduce(into: [:]) { (result, object) in
                result[object.id] = object.rate
            }
            onRatesChanged()
        }
    }
    
    private func updateMyBalanceSection(animate: Bool = true) {
        func onUpdateUI() {
            let updatedSection = createMyBalanceSection(items: cache.fetchedBalanace ?? [])
            sections.update(section: updatedSection)
        }
        
        // Update UI
        
        if animate {
            withAnimation {
                onUpdateUI()
            }
        } else {
            onUpdateUI()
        }
    }
    
    private func onRatesChanged() {
        // Update input fields because rates changed
        // TODO: Implement specific methods to do so
        exchangeCurrencyVM(vm: buyAmountCellVM, amountChanged: buyAmountCellVM.amountInput)
        exchangeCurrencyVM(vm: sellAmountCellVM, amountChanged: sellAmountCellVM.amountInput)
    }
    
    private func createMyBalanceSection(items: [CurrencyBalance]?) -> Section {
        let cells: [Cell] = {
            if items == nil {
                return [.walletPlacehoder]
            }
            var balanceCells: [Cell] = items?.compactMap { balance -> Cell? in
                if balance.balance <= 0 {
                    return nil
                }
                return Cell.currencyAmount(balance)
            } ?? []
            if balanceCells.isEmpty {
                balanceCells.append(.emptyWallet)
            }
            
            return balanceCells
        }()
        return Section(uuid: SectionIdentifiers.myBalances.rawValue, title: "MY BALANCES", cells: cells)
    }
    
    private func createCurrencyExchangeSection() -> Section {
        let cells: [Cell] = [
            .exchangeCurrency(sellAmountCellVM),
            .exchangeCurrency(buyAmountCellVM),
            .performExchange
        ]
        return Section(uuid: SectionIdentifiers.currencyExchange.rawValue, title: "CURRENCY EXCHANGE", cells: cells)
    }
    
    private func onEstimateConversion(action: ConversionAction, inputAmount: Money) throws -> CurrencyConversionResult {
        guard
            let sellCurrency = sellAmountCellVM.selectedCurrency,
            let buyCurrency = buyAmountCellVM.selectedCurrency,
            let rates = cache.fetchedRates
        else {
            throw CurrencyExchangeServiceError.rateUnknown
        }
        
        let result = try currencyExchangeService.estimate(sellCurrency: sellCurrency, buyCurrency: buyCurrency,
                                                          action: action, amount: inputAmount, rates: rates)
        return result
    }
    
    private func makeConversionMessage(fromAmount: Money, fromCurrency: Currency,
                                       toAmount: Money, toCurrency: Currency) -> String {
        return "You have converted \(fromAmount) \(fromCurrency.id) to \(toAmount) \(toCurrency.id)"
    }
    
    private func performExchangeOperation(fromCurrency: Currency, toCurrency: Currency,
                                          amount: Money, balance: Money, rates: [CurrencyID: Decimal]) async throws {
        
        // Generate conversion result
        let result = try currencyExchangeService.convert(fromCurrency: fromCurrency, toCurrency: toCurrency,
                                                         amount: amount,
                                                         balance: balance, rates: rates)
        
        let newToBalance: CurrencyBalance = await {
            if let previousBuyCurrency = await balanaceRepository.getBalance(forCurrency: toCurrency) {
                // Add new balance + previous
                let newToBalance = CurrencyBalance(id: result.to.id,
                                                   balance: result.to.balance + previousBuyCurrency.balance)
                return newToBalance
            } else {
                // No previous balance, this conversion is new to balance
                return result.to
            }
        }()
        
        // Update db with new balance
        await balanaceRepository.addOrUpdate(currencyBalance: [result.from,  newToBalance])
    }
}

extension MyBalanceScreenVM: ExchangeCurrencyVMDelegate {
    func exchangeCurrencyVM(vm: ExchangeCurrencyVM, amountChanged amount: Money) {
        let action: ConversionAction = vm.option == .buy ? .buy : .sell
        let estimated = try? onEstimateConversion(action: action, inputAmount: amount)
        let targetVM: ExchangeCurrencyVM? = vm.option == .buy ? sellAmountCellVM : buyAmountCellVM
        targetVM?.onReplaceInput(withPreCalculatedAmount: estimated?.to.balance ?? 0.0)
    }
}
