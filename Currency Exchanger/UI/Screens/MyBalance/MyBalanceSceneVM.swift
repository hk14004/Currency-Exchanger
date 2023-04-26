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

class MyBalanceSceneVM: ObservableObject {
    
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
        var fetchedRates: [CurrencyRate]?
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
    private let currencyExchangeService: CurrencyExchangeServiceProtocol
    
    // Other
    private let cache = Cache()
    private lazy var sellAmountCellVM: ExchangeCurrencyVM = {
        let sellVM = ExchangeCurrencyVM(option: .sell, amount: 0, currencyRepository: currencyRepository)
        self.sellAmountCellVM = sellVM
        sellVM.delegate = self
        return sellVM
    }()
    
    private lazy var buyAmountCellVM: ExchangeCurrencyVM = {
        let buyVM = ExchangeCurrencyVM(option: .buy, amount: 0, currencyRepository: currencyRepository)
        self.buyAmountCellVM = buyVM
        buyVM.delegate = self
        return buyVM
    }()
    
    private let bag = Bag()
//    private var currencyRateRefreshTimer: Timer
//    private let currencyRateInterval: TimeInterval = 60
    
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

extension MyBalanceSceneVM {
    func onExchangeCurrencyTapped() {
        do {
            let sellVM = sellAmountCellVM
            let buyVM = buyAmountCellVM
            
            guard
                let sellCurrency = sellVM.selectedCurrency,
                let buyCurrency = buyVM.selectedCurrency
            else {
                throw CurrencyExchangeServiceError.currencyNotFound
            }

            guard let balance = balanaceRepository.getBalance(forCurrency: sellCurrency) else {
                throw CurrencyExchangeServiceError.notEnough
            }
            let rates = currencyRepository.getRates()
            let result = try currencyExchangeService.convert(fromCurrency: sellCurrency, toCurrency: buyCurrency,
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
            let error = err as! CurrencyExchangeServiceError
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

extension MyBalanceSceneVM {
    
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
        bag.rateHandle = currencyRepository.observeRates().removeDuplicates().sink { [weak self] rates in
            self?.onRatesChanged(rates: rates)
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
    
    private func onRatesChanged(rates: [CurrencyRate]) {
        cache.fetchedRates = rates
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
    
    private func onEstimateConversion(action: ConversionAction, inputAmount: Double) throws -> CurrencyConversionResult {
        let sellVM = sellAmountCellVM
        let buyVM = buyAmountCellVM
        guard
            let sellCurrency = sellVM.selectedCurrency,
            let buyCurrency = buyVM.selectedCurrency,
            let rates = cache.fetchedRates
        else {
            throw CurrencyExchangeServiceError.rateUnknown
        }
        
        let result = try currencyExchangeService.estimate(sellCurrency: sellCurrency, buyCurrency: buyCurrency,
                                                     action: action, amount: inputAmount, rates: rates)
        return result
    }
    
    private func makeConversionMessage(fromAmount: Double, fromCurrency: Currency,
                                       toAmount: Double, toCurrency: Currency) -> String {
        return "You have converted \(fromAmount) \(fromCurrency.id) to \(toAmount) \(toCurrency.id)"
    }
}

extension MyBalanceSceneVM: ExchangeCurrencyVMDelegate {
    func exchangeCurrencyVM(vm: ExchangeCurrencyVM, amountChanged amount: Double) {
        let action: ConversionAction = vm.option == .buy ? .buy : .sell
        let estimated = try? onEstimateConversion(action: action, inputAmount: amount)
        let targetVM: ExchangeCurrencyVM? = vm.option == .buy ? sellAmountCellVM : buyAmountCellVM
        targetVM?.onReplaceInput(withPreCalculatedAmount: estimated?.to.balance ?? 0.0)
    }
}
