//
//  PlayView.swift
//  Play Melody
//
//  Created by 이신원 on 8/11/25.
//

import SwiftUI

struct PlayView: View {
    @State var currentPage = 0
    @State var currentNoteIndex = 0
    @State private var phase: PlayPhase = .onboarding
    
    private enum PlayPhase: Equatable {
        case onboarding
        case practicing
        case finished
    }
    
    var item: Play
    
    var body: some View {
        VStack {
            switch phase {
            case .onboarding:
                onboard
            case .practicing:
                practice()
            case .finished:
                SuccessView()
            }
        }
        .onAppear {
            phase = .onboarding
        }
        .animation(.easeInOut(duration: 0.25), value: phase)
    }
    
    private var onboard: some View {
        VStack {
            VStack {
                Rectangle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 250, height: 50)
                    .cornerRadius(10)
                
                HStack {
                    Image("hand_left").resizable().scaledToFit()
                    Image("hand_right").resizable().scaledToFit()
                }
            }
                .frame(height: 200)
            Spacer().frame(height: 40)
            Text("Show both hands to the camera.").font(.title2)
            Text("Starting automatically in 2 seconds.").foregroundStyle(.secondary)
        }
        .task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            phase = .practicing
        }
    }
    
    private func practice() -> some View {
        ZStack {
            HandTrackingView { side, detectedNote in
                guard let target = item.scoreList?[currentPage][currentNoteIndex] else { return }
                guard detectedNote == target else { return }

                advance()
            }
            .id("hand-tracking") 
            
            if let _ = item.totalPage {
                VStack {
                    ScoreCard(
                        item: item,
                        currentPage: currentPage,
                        currentNoteIndex: currentNoteIndex
                    )
                    .frame(width: 800, height: 210)
                    
                    Spacer()
                }
                .padding(.vertical, 100)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private func advance() {
        guard let pages = item.scoreList, currentPage < pages.count else {
            phase = .finished
            return
        }
        let notes = pages[currentPage]
        
        if currentNoteIndex + 1 < notes.count {
            currentNoteIndex += 1
            return
        }
        
        if currentPage + 1 < pages.count {
            currentPage += 1
            currentNoteIndex = 0
        } else {
            phase = .finished
        }
    }
    
}
