//
//  SwiftUIView.swift
//  Melody Practice
//
//  Created by 이신원 on 8/4/25.
//

import SwiftUI
import UIKit

struct WelcomeView: View {
    @Binding var selection: ContentView.Tab
    @State private var isAnimationActive = false
    
    var welcomeImage: some View {
        Image("welcome")
            .resizable()
            .scaledToFit()
            .frame(width:220, height:220)
    }
    
    var welcomeTitle: some View {
        HStack {
            Text("Welome to")
            
            HStack {
                Text("Melody")
                Image(systemName: "music.note")
            }
            .symbolEffect(.bounce ,options: .repeat(5), value: isAnimationActive)
            .foregroundColor(.green)
            .frame(minWidth: 100)
        }
        .font(.title)
        .fontWeight(.bold)
        .padding()
        
    }
    
    var body: some View {
        BottomButtonView(
            buttonTitle: "Guide",
            buttonIcon: "info.circle",
            buttonAction: {
                selection = .guide
            }
        ) {
            VStack {
                
                Spacer()
                
                welcomeImage
                welcomeTitle
                
                Spacer()

                
                infoCard(title: "Educational Insight", message: "'Melody' makes it easy and engaging for beginners to learn melodies, offering a step into the world of music.")
                
                infoCard(title: "Motor & Brain Boost", message: "Through the coordination of eyes and hands, one can expect the development of fine motor skills and enhancement of cognitive abilities.")
                
                infoCard(title: "Creative Freedom", message: "Craft your own music with your fingers. 'Melody' offers the freedom to express your musical creativity uniquely.")
                
                Spacer()

            }
        }
        .onAppear {
            isAnimationActive = true
        }
    }

    func infoCard(title: String, message: String) -> some View {
        VStack(alignment: .center) {
            Text(title)
                .fontWeight(.semibold)
            Text(message)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    WelcomeView(selection: .constant(.guide))
}
