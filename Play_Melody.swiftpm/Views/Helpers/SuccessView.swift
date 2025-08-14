//
//  SuccessView.swift
//  Play Melody
//
//  Created by 이신원 on 8/12/25.
//
import SwiftUI

struct SuccessView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isAnimationActive = false
    
    private let messages = ["Great Job", "Excellent", "Perfect"]
    private let images = ["great","excellent", "perfect"]
    private var randomIndex:Int {
        return Int.random(in: 0...2)
    }
    
    var body: some View {
        VStack {
            Image(images[randomIndex])
                .resizable()
                .scaledToFit()
                .frame(width:300)
            
            HStack {
                Image(systemName: "music.note")
                
                Text(messages[randomIndex])
                
                Image(systemName: "music.note")
                
            }
            .symbolEffect(.bounce, options: .repeating, value: isAnimationActive)
            .font(.largeTitle)
            .foregroundStyle(.green)
        }
        .onAppear() {
            isAnimationActive = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                dismiss()
            }
        }
    }
}

#Preview {
    SuccessView()
}
