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
    
    struct Section {
        let uuid: String
        let title: String?
        var cells: [Cell]
        
        init(uuid: String, title: String?, cells: [Cell]) {
            self.uuid = uuid
            self.title = title
            self.cells = cells
        }
    }
    
    @Published var sections: [Section] = []
    @Published var showAlert: Bool = false
    @Published var alertType: AlertType = .notEnoughMoney
    
    private let bag = Bag()
    
    // Input
    private let balanaceRepository: CurrencyBalanceRepositoryProtocol
    private let currencyRepository: CurrencyRepositoryProtocol
    private let currencyConverter: CurrencyCoverterProtocol
    
    init(balanaceRepository: CurrencyBalanceRepositoryProtocol,
         currencyRepository: CurrencyRepositoryProtocol,
         currencyConverter: CurrencyCoverterProtocol) {
        self.balanaceRepository = balanaceRepository
        self.currencyRepository = currencyRepository
        self.currencyConverter = currencyConverter
        subscribeToNotifications()
        sections = createSections()
    }
    
    private var sellAmountCellVM: ExchangeCurrencyVM?
    private var buyAmountCellVM: ExchangeCurrencyVM?
    
    private var fetchedBalanace: [CurrencyBalance]?
}

// MARK: Public

extension ConverterSceneVM {
    func onExchangeCurrencyTapped() {
        guard let sellVM = sellAmountCellVM else {
            return
        }
        guard let buyVM = buyAmountCellVM else {
            return
        }
        
        // TODO: Buy and sell not just sell
        guard let sellCurrency = sellVM.selectedCurrency else {
            return
        }
        guard let buyCurrency = buyVM.selectedCurrency else {
            return
        }
        guard let balance = balanaceRepository.getBalance(forCurrency: sellCurrency) else {
            return
        }
        let rates = currencyRepository.getRates()
        
        do {
            let result = try currencyConverter.convert(fromCurrency: sellCurrency, toCurrency: buyCurrency,
                                                       amount: sellVM.amount, balance: balance.balance, rates: rates)
            print(result)
            // Update db with new balance
            if let previousBuyCurrency: CurrencyBalance = balanaceRepository.getBalance(forCurrency: buyCurrency) {
                balanaceRepository.addOrUpdate(currencyBalance: [result.from,  .init(id: result.to.id, balance: result.to.balance + previousBuyCurrency.balance)])
            } else {
                balanaceRepository.addOrUpdate(currencyBalance: [result.from, result.to])
            }
            
            
        } catch (let err) {
            let error = err as! CurrencyConversionError
            switch error {
            case .notEnough:
                alertType = .notEnoughMoney
            case .cannotExchangeSameCurrency:
                alertType = .cannotExchangeSameCurrency
            case .rateUnknown:
                alertType = .unknownRate
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
        bag.balanceHandle = balanaceRepository.observeBalance().sink { [unowned self] balance in
            // TODO: Update section only better
            let animate: Bool = fetchedBalanace != nil
            fetchedBalanace = balance
            guard let sectionIndex = sections.firstIndex(where: {$0.uuid == SectionIdentifiers.myBallances.rawValue}) else {
                return
            }
            var temp = sections
            temp.remove(at: sectionIndex)
            let newSection =  createMyBalanceSection(items: balance)
            temp.insert(newSection, at: sectionIndex)
            
            // Update UI
            if animate {
                withAnimation {
                    sections = temp
                }
            } else {
                sections = temp
            }
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [unowned self] in
//            self.balanaceRepository.setBalance([.init(id: "EUR", balance: 1000)])
//        }
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
        let buyVM = ExchangeCurrencyVM(option: .buy, amount: 0, currencyRepository: currencyRepository)
        self.buyAmountCellVM = buyVM

        let cells: [Cell] = [
            .exchangeCurrency(sellVM),
            .exchangeCurrency(buyVM),
            .performExchange
        ]
        return Section(uuid: SectionIdentifiers.currencyExchange.rawValue, title: "CURRENCY EXCHANGE", cells: cells)
    }
}
