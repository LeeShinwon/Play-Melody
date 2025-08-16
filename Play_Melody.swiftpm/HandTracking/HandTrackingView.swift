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
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            CameraView(hands: $hands)
            pointsView
        }

    }

    private var pointsView: some View {
        ZStack {
            ForEach(hands.indices, id: \.self) { i in
                let hand = hands[i]
                let side = hand.side
                let points = hand.points
                ForEach(points.indices, id: \.self) { j in
                    let point = points[j]

                    let color: Color = .green
                    
                    Circle()
                        .fill(color)
                        .frame(width: 14)
                        .position(x: point.x, y: point.y)
                }

            }
        }
    }
}


#Preview {
    HandTrackingView ()
}
