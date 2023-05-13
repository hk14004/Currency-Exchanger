//
//  MainButtonStyle.swift
//  Currency Exchanger
//
//  Created by Hardijs Ķirsis on 09/01/2023.
//

import SwiftUI

struct MainButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(AppColors.mainAccent)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.linear(duration: 0.2), value: configuration.isPressed)
            .brightness(configuration.isPressed ? -0.05 : 0)
            
    }
}

struct MainButton: View {
    var body: some View {
        Button("Submit", action: {})
            .buttonStyle(MainButtonStyle())
    }
}

struct MainButton_Previews: PreviewProvider {
    static var previews: some View {
        MainButton()
    }
}
