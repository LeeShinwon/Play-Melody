//
//  HandTrackingView.swift
//  Melody Practice
//
//  Created by 이신원 on 8/5/25.
//


import SwiftUI
import AVFoundation
import Vision

struct HandTrackingView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var hands: [HandPoints] = []
    @State var leftHandPinched = false
    @State var rightHandPinched = false
    @State var leftPinchedFinger: VNHumanHandPoseObservation.JointName?
    @State var rightPinchedFinger: VNHumanHandPoseObservation.JointName?
    @State private var leftPinchCooldown: Timer? = nil
    @State private var rightPinchCooldown: Timer? = nil
    
    private let leftProcessor = HandGestureProcessor()
    private let rightProcessor = HandGestureProcessor()
    private let audioManager = AudioManager()
    
    var onPinch: (_ side: HandSide, _ note: String) -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            CameraView(hands: $hands)
            pointsView
            
             backButton
        }
        .navigationBarHidden(true)
        .onChange(of: hands) {
            for hand in hands { processHand(hand) }
        }
    }
    
    private var backButton: some View {
        Button(action: {
            dismiss()
        }) {
            Image(systemName: "chevron.left")
                .font(.title)
                .padding()
        }
    }

    private var pointsView: some View {
        ZStack {
            ForEach(hands.indices, id: \.self) { i in
                let hand = hands[i]
                let side = hand.side
                let points = hand.points
                let processor = (side == .left) ? leftProcessor : rightProcessor
                let pinchIndex = processor.pinchedFingerIndex

                ForEach(points.indices, id: \.self) { j in
                    let point = points[j]

//                    let isThumb = j == 0
                    let isPinched = (pinchIndex != nil)
                    //(isThumb && pinchIndex != nil) || (j == pinchIndex)
                    let color: Color = isPinched ? .green : .red
                    
                    Circle()
                        .fill(color)
                        .frame(width: 14)
                        .position(x: point.x, y: point.y)
                }

            }
        }
    }
    
    private func note(for finger: VNHumanHandPoseObservation.JointName?, side: HandSide) -> String? {
        switch (side, finger) {
        case (.left, .littleTip): return "do"
        case (.left, .ringTip): return "re"
        case (.left, .middleTip): return "mi"
        case (.left, .indexTip): return "fa"
        case (.right, .indexTip): return "sol"
        case (.right, .middleTip): return "ra"
        case (.right, .ringTip): return "si"
        case (.right, .littleTip): return "doHigh"
        default: return nil
        }
    }
    
    private func processHand(_ hand: HandPoints) {
        let side = hand.side
        let points = hand.points
        guard points.count > 4 else { return }

        let thumb = points[0]
        let fingers: [(VNHumanHandPoseObservation.JointName, CGPoint)] = [
            (.indexTip, points[1]),
            (.middleTip, points[2]),
            (.ringTip, points[3]),
            (.littleTip, points[4]),
        ]
        
        let processor = (side == .left) ? leftProcessor : rightProcessor
        processor.processThumbAndFingers(thumb: thumb, fingerPoints: fingers)

        let wasPinched = (side == .left) ? leftHandPinched : rightHandPinched
        let isPinched = processor.isPinched
        let pinchedFinger = processor.pinchedFinger

        if side == .left {
            leftHandPinched = isPinched
            leftPinchedFinger = pinchedFinger
        } else {
            rightHandPinched = isPinched
            rightPinchedFinger = pinchedFinger
        }

        let cooldownTimer = (side == .left) ? leftPinchCooldown : rightPinchCooldown
        if isPinched && !wasPinched && cooldownTimer == nil {
            if let note = note(for: pinchedFinger, side: side) {
                audioManager.play(note: note)
                onPinch(side, note)
                setTimer(side: side)
            }
        } else if !isPinched && wasPinched {
            audioManager.stopCurrent()
        }
    }
    
    private func setTimer(side: HandSide) {
        let newTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            if side == .left {
                leftPinchCooldown = nil
            } else {
                rightPinchCooldown = nil
            }
        }
        if side == .left {
            leftPinchCooldown = newTimer
        } else {
            rightPinchCooldown = newTimer
        }
    }
}


//#Preview {
//    HandTrackingView ()
//}
