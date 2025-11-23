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
        image: String,
        title: LocalizedStringKey,
        message: LocalizedStringKey?,
        buttonText: LocalizedStringKey,
        action: @escaping () -> Void,
        cancelAction: (() -> Void)? = nil
    ) -> some View {
        modifier(
            CustomAlertModifier(
                isPresented: isPresented,
                image: image,
                title: title,
                message: message,
                buttonText: buttonText,
                action: action,
                cancelAction: cancelAction
            ))
    }
}
