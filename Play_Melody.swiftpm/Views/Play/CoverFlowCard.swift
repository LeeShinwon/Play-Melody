//
//  CoverFlowCard.swift
//  Melody Practice
//
//  Created by 이신원 on 8/5/25.
//

import SwiftUI

struct  CoverFlowCard: View {
    let item: Play

    @State private var isPlayMelodyCameraViewPresented = false
    @State private var showFullScreen = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(item.gradient)
            
            VStack {
                Image(systemName: item.icon)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
                
                Text(item.title)
                    .foregroundStyle(.black)
                    .padding()
                    .fontWeight(.bold)
                    .font(.title2)
                
                Text(item.description)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                
                
                NavigationLink(destination: PlayView(item: item)) {
                    Text("Play")
                        .foregroundStyle(.white)
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
            
        }
    }
}

