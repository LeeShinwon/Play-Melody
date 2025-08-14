//
//  ScoreCard.swift
//  Play Melody
//
//  Created by 이신원 on 8/13/25.
//

import SwiftUI

struct ScoreCard: View {
    @State var isSoundPlaying = false
    
    var item: Play
    var currentPage: Int
    var currentNoteIndex: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(item.gradient)
                .shadow(color: Color.black.opacity(0.5), radius: 5, x: 5, y: 5)
            
            VStack {
                HStack {
                    Image(systemName: item.icon)
                        .padding()
                    Text(item.title)
                    
                    Spacer()
                    
                    Text("\(currentPage + 1) / \(item.totalPage ?? 1)")
                        .padding()
                }
                .foregroundStyle(.white)
                .font(.title)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                    
                    VStack {
                        if let imgName = item.scoreImages?[currentPage] {
                            Image(imgName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 400, height:100)
                                .overlay(
                                    Group {
                                        if let pages = item.scorePointPositions,
                                           currentPage < pages.count {
                                            let positions = pages[currentPage]
                                            if positions.indices.contains(currentNoteIndex) {
                                                let x = positions[currentNoteIndex]
                                                Rectangle()
                                                    .fill(item.opacity)
                                                    .frame(width: 25, height: 100)
                                                    .cornerRadius(5)
                                                    .offset(x: CGFloat(x), y: 0)
                                            }
                                        }
                                    },
                                    alignment: .leading
                                )
                                .padding()
                        }
                    }
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 3)
                        .blur(radius: 3)
                        .offset(x: 2, y: 2)
                        .mask(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
}
