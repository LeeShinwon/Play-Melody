//
//  SwiftUIView.swift
//  Melody Practice
//
//  Created by 이신원 on 8/4/25.
//

import SwiftUI

struct PracticeIntroView: View {
    @Binding var selection: ContentView.Tab

    var body: some View {
        BottomButtonView(
            buttonTitle: "Play",
            buttonIcon: "music.note",
            buttonAction: {
                selection = .play
            }
        ) {
            VStack (alignment: .center, spacing: 20){
                Image(systemName: "target")
                    .font(.system(size: 100))
                
                Text("You can practice moving your fingers\nto produce sounds from Do to HighDo in real-time.")
                    .multilineTextAlignment(.center)
               
                NavigationLink(destination: PracticeView()) {
                    Text("Practice")
                        .font(.title2)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 40)
                        .background(
                            Capsule()
                                .fill(.white.opacity(0.3))
                        )
                }
                .padding()
                
            }
            .padding(40)
            .foregroundColor(.white)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.green.gradient))
            
        }
    }
}

#Preview {
    PracticeIntroView(selection: .constant(.play))
}
