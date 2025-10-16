//
//  View+CustomAlert.swift
//  LastDance
//
//  Created by donghee on 10/16/25.
//

import SwiftUI

extension View {
    func customAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        buttonText: String,
        action: @escaping () -> Void
    ) -> some View {
        modifier(CustomAlertModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            buttonText: buttonText,
            action: action
        ))
    }
}
