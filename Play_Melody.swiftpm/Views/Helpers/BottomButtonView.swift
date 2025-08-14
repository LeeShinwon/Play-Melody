//
//  ButtonScrollView.swift
//  Melody Practice
//
//  Created by 이신원 on 8/5/25.
//

import SwiftUI

struct BottomButtonView<Content: View>: View {
    let buttonTitle: String
    let buttonIcon: String
    let buttonAction: () -> Void
    let content: Content

    init(
        buttonTitle: String,
        buttonIcon: String,
        buttonAction: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.buttonTitle = buttonTitle
        self.buttonIcon = buttonIcon
        self.buttonAction = buttonAction
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxHeight: .infinity)
                .padding(.horizontal)
                .padding(.top)
            
            Button(action: buttonAction) {
                HStack {
                    Spacer()
                    Image(systemName: buttonIcon)
                    Text(buttonTitle)
                    
                    Spacer()
                    Image(systemName: "arrow.right")
                    
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
    }
}
