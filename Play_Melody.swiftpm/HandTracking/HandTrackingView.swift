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
    @State private var hands: [HandPoints] = []
    @State var leftHandPinched = false
    @State var rightHandPinched = false
    @State var leftPinchedFinger: VNHumanHandPoseObservation.JointName?
    @State var rightPinchedFinger: VNHumanHandPoseObservation.JointName?
    
    private let leftProcessor = HandGestureProcessor()
    private let rightProcessor = HandGestureProcessor()
 
    var body: some View {
        ZStack(alignment: .topLeading) {
            CameraView(hands: $hands)
            pointsView
        }
        .onChange(of: hands) {
            for hand in hands { processHand(hand) }
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

                    let isPinched = (pinchIndex != nil)
                    let color: Color = isPinched ? .green : .red
                    
                    Circle()
                        .fill(color)
                        .frame(width: 14)
                        .position(x: point.x, y: point.y)
                }

            }
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

        let isPinched = processor.isPinched
        let pinchedFinger = processor.pinchedFinger

        if side == .left {
            leftHandPinched = isPinched
            leftPinchedFinger = pinchedFinger
        } else {
            rightHandPinched = isPinched
            rightPinchedFinger = pinchedFinger
        }

    }

}


#Preview {
    HandTrackingView ()
}
