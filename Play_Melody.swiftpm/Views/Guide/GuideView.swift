//
//  SwiftUIView.swift
//  Melody Practice
//
//  Created by 이신원 on 8/4/25.
//

import SwiftUI

struct GuideView: View {
    @Environment(ModelData.self) var modelData
    @Binding var selection: ContentView.Tab

    var body: some View {
        BottomButtonView(
            buttonTitle: "Practice",
            buttonIcon: "target",
            buttonAction: {
                selection = .practice
            }
        ) {
            ScrollView(showsIndicators: false) {
                infoCard(
                    title: "Gesture Guide for Sheet Music",
                    subTitle:"You can practice moving your fingers to play notes from Do to High Do in real time.",
                    message: "Start by practicing Do, Re, Mi, and Fa with your left hand.\nThen, practice Sol, La, Si, and High Do with your right hand.\nFinally, test yourself by playing all the notes from Do to High Do using both hands together."
                )
                
                HStack {
                    ForEach(modelData.practices.filter { $0.isLeftHand }) { practice in
                        handScoreCard(practice: practice)
                    }
                }
                
                HStack {
                    ForEach(modelData.practices.filter { !$0.isLeftHand }) { practice in
                        handScoreCard(practice: practice)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    func infoCard(title: String, subTitle: String, message: String) -> some View {
        VStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
            
            Text(subTitle)
                .font(.title3)
                .fontWeight(.semibold)
                
            Text(message)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
    
    func handScoreCard(practice: Practice) -> some View {
        VStack {
            Text(practice.name)
                .font(.title2)
                .fontWeight(.bold)
            
            
            Text(practice.isLeftHand ? "✋🏻 Left ✋🏾" : "🤚🏻 Right 🤚🏾")
                .padding()
                .padding(.top, -15)
            
            practice.noteImage
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 30)
                .padding()
            
            practice.handImage
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 240)
                .padding()
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 300)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        guard let first = self.first else { return self }
        return first.uppercased() + self.dropFirst()
    }
}

#Preview {
    GuideView(selection: .constant(.practice))
}
