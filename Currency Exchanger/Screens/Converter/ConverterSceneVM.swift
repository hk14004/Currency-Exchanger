//
//  ConverterSceneVM.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import SwiftUI
import RealmSwift
import DevTools

class ConverterSceneVM: ObservableObject {
    
    // MARK: Types
    
    enum SectionIdentifiers: String {
        case currencyExchange
        case myBallances
    }
    
    enum AlertType {
        case notEnoughMoney
    }
    
    enum Cell: Hashable {
        case currencyAmount(CurrencyBalance) // Preferably store VM of a cell
        case exchangeCurrency(ExchangeCurrencyVM)
        case performExchange
    }
    
    class Bag {
//        var itemsHandle: NotificationToken?
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
    
//    let database: Realm
//    private let user: User_DB
    
    private let bag = Bag()
    
    
    init(userID: String) {
//        self.database = database
//        self.user = user
        sections = createSections()
        subscribeToNotifications()
    }
    
    private var sellAmountCellVM: ExchangeCurrencyVM?
    private var buyAmountCellVM: ExchangeCurrencyVM?
    
}

// MARK: Private

extension ConverterSceneVM {
    func onExchangeCurrencyTapped() {
//        guard let sellAmountCellVM = sellAmountCellVM, let buyAmountCellVM = buyAmountCellVM else {
//            return
//        }
//        guard user.hasEnoughCurrency(currencyID: sellAmountCellVM.selectedCurrency.id, amount: sellAmountCellVM.amount) else {
//            // Show alert
//            alertType = .notEnoughMoney
//            showAlert = true
//            return
//        }
//
//        user.exchange(fromCurrencyID: sellAmountCellVM.selectedCurrency.id, amount: sellAmountCellVM.amount, toCurrencyID: buyAmountCellVM.selectedCurrency.id)
//        print(sellAmountCellVM.amount, sellAmountCellVM.selectedCurrency.id)
//        print(buyAmountCellVM.amount, buyAmountCellVM.selectedCurrency.id)
        
        //dddddddddddddd
//        database.bulkWrite(writeOperation: {
////            let item = database.object(ofType: CurrencyBalance.self, forPrimaryKey: "EUR")
////            item?.balance = 1001
////
//            let new = CurrencyBalance()
//            new.id = "USD"
//            new.balance = 451
//            user.currencyBalance.append(objectsIn: [new])
//
////            user.currencyBalance.remove(at: 1)
//        })
    }
}

// MARK: Private

extension ConverterSceneVM {
    private func subscribeToNotifications() {
//        bag.itemsHandle = user.observe(fields: .init([.currencyBalance]), closure: { [unowned self] change in
//            switch change {
//            case .change:
//                guard let sectionIndex = sections.firstIndex(where: {$0.uuid == SectionIdentifiers.myBallances.rawValue}) else {
//                    return
//                }
//                var temp = sections
//                temp.remove(at: sectionIndex)
//                let newSection =  createMyBalanceSection(items: Array(user.currencyBalance))
//                temp.insert(newSection, at: sectionIndex)
//                withAnimation {
//                    sections = temp
//                }
//            case .error(let error):
//                print("An error occurred: \(error)")
//            case .deleted:
//                print("The object was deleted.")
//            }
//        })
    }
    
    private func createSections() -> [Section] {
        [
            //createCurrencyExchangeSection(),
//            createMyBalanceSection(items: Array(user.currencyBalance)),
        ]
    }
    
    private func createMyBalanceSection(items: [CurrencyBalance]) -> Section {
        let cells: [Cell] = items.compactMap { balance -> Cell? in
            if balance.balance <= 0 {
                return nil
            }
            return Cell.currencyAmount(balance)
        }
        return Section(uuid: SectionIdentifiers.myBallances.rawValue, title: "MY BALANCES", cells: cells)
    }
    
    private func createCurrencyExchangeSection() -> Section {
//        let sellVM = ExchangeCurrencyVM(option: .sell, amount: 0, database: database)
//        self.sellAmountCellVM = sellVM
//        let buyVM = ExchangeCurrencyVM(option: .buy, amount: 0, database: database)
//        self.buyAmountCellVM = buyVM
//
//        let cells: [Cell] = [
//            .exchangeCurrency(sellVM),
//            .exchangeCurrency(buyVM),
//            .performExchange
//        ]
        return Section(uuid: SectionIdentifiers.currencyExchange.rawValue, title: "CURRENCY EXCHANGE", cells: [])
    }
}
