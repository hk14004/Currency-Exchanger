//
//  SellCurrencyView.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import SwiftUI
import RealmSwift
import Swinject

struct ExchangeCurrencyView: View {
    
    @ObservedObject var viewModel: ExchangeCurrencyVM
    
    var body: some View {
        HStack {
            BuySellIndicatorView(option: .init(rawValue: viewModel.option.rawValue)!)
            Text(viewModel.option == .buy ? "Buy" : "Sell")
            TextField("Enter amount", value: $viewModel.amountInput, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.plain)
            Picker("", selection: $viewModel.selectedCurrency) {
                ForEach(viewModel.availableCurrencies, id: \.id) { item in
                    Text(item.id).tag(item as Currency?)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
        .frame(height: 44)
    }
}

//struct SellCurrencyView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExchangeCurrencyView(viewModel: .init(option: .sell, amount: 0, database: try! Realm()))
//    }
//}
