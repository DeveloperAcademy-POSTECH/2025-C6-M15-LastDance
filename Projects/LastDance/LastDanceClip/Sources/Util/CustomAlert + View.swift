//
//  CustomAlert + View.swift
//  LastDance
//
//  Created by 배현진 on 11/26/25.
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
            ClipCustomAlertModifier(
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
