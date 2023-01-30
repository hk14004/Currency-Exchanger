//
//  CurrencyPickerView.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import SwiftUI

//enum Currecy {
//    case eur
//}
//
//extension Currecy {
//    func getTitle() -> String {
//        switch self {
//        case .eur:
//            return "EUR"
//        }
//    }
//}
//
//struct CurrencyPickerView: View {
//    
//    @Binding var picked: Currecy
//    @Binding var list: [Currecy]
//    
//    var body: some View {
//        Picker("", selection: $picked) {
//            ForEach(list, id: \.self) {
//                Text($0.getTitle())
//            }
//        }
//        .pickerStyle(.menu)
//    }
//}
//
//struct CurrencyPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        CurrencyPickerView(picked: .constant(.eur), list: .constant([.eur]))
//    }
//}
