//
//  CurrencyBalanceItemView.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import SwiftUI

struct CurrencyBalanceItemView: View {
    
    @ObservedObject var viewModel: CurrencyBalanceItemVM
    
    var body: some View {
        HStack {
            Text(viewModel.getBalanceString())
            Text(viewModel.currencyBalanceItem.id)
        }
    }
}

struct CurrencyBalanceItemView_Previews: PreviewProvider {
    static var previews: some View {
        let balance: CurrencyBalance = {
           let b = CurrencyBalance()
            b.balance = 666
            b.id = "EUR"
            return b
        }()
        CurrencyBalanceItemView(viewModel: .init(currencyBalanceItem: balance))
    }
}
