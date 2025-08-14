//
//  CameraView.swift
//  Melody Practice
//
//  Created by 이신원 on 8/5/25.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    @Binding var hands: [HandPoints]

    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraViewController = CameraViewController()
        cameraViewController.onHandPointsDetected = { detectedHands in
            hands = detectedHands
        }
        return cameraViewController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}
