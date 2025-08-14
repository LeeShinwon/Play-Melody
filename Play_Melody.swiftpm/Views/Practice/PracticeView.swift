//
//  PracticeView.swift
//  Play Melody
//
//  Created by 이신원 on 8/11/25.
//

import SwiftUI
import Vision

struct PracticeView: View {
    @Environment(ModelData.self) var model
    
    @State private var leftIndex = 0
    @State private var rightIndex = 0
    @State private var bothIndex = 0
    @State private var phase: PracticePhase = .onboarding(.left)
    
    
    private enum HandType { case left, right, both }
    
    private enum PracticePhase: Equatable {
        case onboarding(HandType)
        case practicing(HandType)
        case finished
    }

    private var currentSinglePractice: Practice? {
        switch phase {
        case .practicing(.left):
            return leftIndex < model.leftHandPractices.count
                ? model.leftHandPractices[leftIndex] : nil
        case .practicing(.right):
            return rightIndex < model.rightHandPractices.count
                ? model.rightHandPractices[rightIndex] : nil
        default: return nil
        }
    }
    
    private var currentBothPractice: Play {
        model.bothHandPractice
    }
    
    private func currentTargetNote(for phase: PracticePhase) -> String? {
        switch phase {
        case .practicing(.left), .practicing(.right):
            return currentSinglePractice?.note
        case .practicing(.both):
            guard let notes = currentBothPractice.scoreList?.first,
                  bothIndex < notes.count else { return nil }
            return notes[bothIndex]
        default:
            return nil
        }
    }

    var body: some View {
        VStack {
            switch phase {
            case .onboarding(let hand):
                onboard(hand: hand)
            case .practicing(let hand):
                practice(hand: hand)
            case .finished:
                SuccessView()
            }
        }
        .onAppear {
            phase = .onboarding(.left)
        }
        .animation(.easeInOut(duration: 0.25), value: phase)
    }

    private func onboard(hand: PracticeView.HandType) -> some View {
        VStack {
            onboardingImage(for: hand)
                .frame(height: 200)
            Spacer().frame(height: 40)
            Text(onboardingPrompt(for: hand)).font(.title2)
            Text("Starting automatically in 2 seconds.").foregroundStyle(.secondary)
        }
        .task(id: hand) {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            if case .onboarding(let h) = phase, h == hand {
                phase = .practicing(hand)
            }
        }
    }
    
    private func onboardingPrompt(for hand: PracticeView.HandType) -> String {
        switch hand {
        case .left:  return "Show your left hand to the camera."
        case .right: return "Show your right hand to the camera."
        case .both:  return " Show both hands to the camera."
        }
    }
    
    @ViewBuilder
    private func onboardingImage(for hand: PracticeView.HandType) -> some View {
        switch hand {
        case .left:
            HStack {
                Image("hand_left").resizable().scaledToFit()
                
                Rectangle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 150)
                    .cornerRadius(10)
            }

        case .right:
            HStack {
                Rectangle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 150)
                    .cornerRadius(10)
                
                Image("hand_right").resizable().scaledToFit()
            }

        case .both:
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
        }
    }
    
    private func singlePractice<Content: View>(
        hand: HandType,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack {
            if hand == .left {
                Color.clear.frame(maxWidth: .infinity)

                VStack(spacing: 50) { content() }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

            } else {
                VStack(spacing: 50) { content() }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                Color.clear.frame(maxWidth: .infinity)
            }
        }
    }
    
    private func practice(hand: PracticeView.HandType) -> some View {
        ZStack {
            HandTrackingView { side, detectedNote in
                guard let target = currentTargetNote(for: phase) else { return }
                
                switch phase {
                case .practicing(.left):
                    if side == .left && detectedNote == target { advance(for: .left) }
                case .practicing(.right):
                    if side == .right && detectedNote == target { advance(for: .right) }
                case .practicing(.both):
                    if detectedNote == target { advance(for: .both) }
                default:
                    break
                }
            }
            
            VStack {
                if (hand == .left || hand == .right), let item = currentSinglePractice {
                    singlePractice(hand: hand) {
                        Text(item.name)
                            .font(.title)
                            .fontWeight(.bold)
                     
                        item.noteImage
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 80)

                        item.handImage
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                    
                        Text("Pinch with the indicated finger to play the note.")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            
                    }
                }

                if hand == .both {
                    ScoreCard(
                        item: currentBothPractice,
                        currentPage: ((currentBothPractice.totalPage ?? 1) - 1),
                        currentNoteIndex: bothIndex
                    )
                    .frame(width: 600, height: 210)
                    
                    Spacer()
                }
            }
            .padding(.vertical, 100)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Flow
    private func advance(for hand: HandType) {
        switch hand {
        case .left:
            leftIndex += 1
            if leftIndex >= model.leftHandPractices.count {
                phase = .onboarding(.right)
            }
        case .right:
            rightIndex += 1
            if rightIndex >= model.rightHandPractices.count {
                phase = .onboarding(.both)
            }
        case .both:
            bothIndex += 1
        
            if let notes = currentBothPractice.scoreList?.first,
               bothIndex >= notes.count {
                phase = .finished
            }
        }
    }
}
