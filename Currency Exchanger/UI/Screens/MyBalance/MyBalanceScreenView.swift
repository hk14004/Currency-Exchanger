//
//  MyBalanceScreenView.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import SwiftUI

struct MyBalanceScreenView: View {
    
    @ObservedObject var viewModel: MyBalanceScreenVM
    
    var body: some View {
        createMyBalancesView()
            .navigationTitle("Currency Converter")
            .alert(isPresented: $viewModel.showAlert) {
                switch viewModel.alertType {
                case .notEnoughMoney:
                    return Alert(title: Text("Not enough money"))
                case .cannotExchangeSameCurrency:
                    return Alert(title: Text("Cannot exchange same currency"))
                case .unknownRate:
                    return Alert(title: Text("Exchange rate unknown"))
                case .providePositiveNumber:
                    return Alert(title: Text("Provide positive number"))
                case .conversionSuccesful(message: let message):
                    return Alert(title: Text(message))
                }
            }
    }
    
}

extension MyBalanceScreenView {
    private func createMyBalancesView() -> some View {
        List(viewModel.sections, id: \.uuid) { section in
            Section {
                ForEach(section.cells, id: \.self) { cell in
                    switch cell {
                    case .currencyAmount(let balance):
                        CurrencyBalanceItemView(viewModel: .init(currencyBalanceItem: balance))
                    case .exchangeCurrency(let vm):
                        ExchangeCurrencyView(viewModel: vm)
                    case .performExchange:
                        Button {
                            viewModel.onExchangeCurrencyTapped()
                        } label: {
                            HStack() {
                                Spacer()
                                Text("SUBMIT")
                                Spacer()
                            }
                        }.buttonStyle(MainButtonStyle())
                    case .emptyWallet:
                        Text("Your wallet is empty")
                    case .walletPlacehoder:
                        Text("Loading wallet ...").redacted(reason: .placeholder)
                    }
                }
            } header: {
                Text(section.title)
            }
        }
    }
}
