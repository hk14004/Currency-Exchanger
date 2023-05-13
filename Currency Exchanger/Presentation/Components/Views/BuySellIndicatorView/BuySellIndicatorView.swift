//
//  BuySellIndicatorView.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import SwiftUI

struct BuySellIndicatorView: View {
    
    enum Option: Int {
        case buy
        case sell
    }
    
    var option: Option
    var body: some View {
        Circle()
            .fill(getBackgroundColor())
            .overlay(content: {
                Image(systemName: getArrowImageName())
                    .resizable()
                    .foregroundColor(.white)
                    .scaledToFit()
                    .padding(8)
            })
    }
}

extension BuySellIndicatorView {
    private func getBackgroundColor() -> Color {
        switch option {
        case .buy:
            return AppColors.green
        case .sell:
            return AppColors.red
        }
    }
    
    private func getArrowImageName() -> String {
        switch option {
        case .buy:
            return "arrow.down"
        case .sell:
            return "arrow.up"
        }
    }
    
}

struct BuySellIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        BuySellIndicatorView(option: .sell)
    }
}
