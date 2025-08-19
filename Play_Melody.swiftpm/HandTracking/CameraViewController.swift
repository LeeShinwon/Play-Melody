//
//  CameraViewController.swift
//  Melody Practice
//
//  Created by 이신원 on 8/5/25.
//

import AVFoundation
import UIKit

class CameraViewController: UIViewController {
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var cameraFeedSession: AVCaptureSession?


    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try setupAVSession()
        } catch {
            print("Camera setup failed: \(error)")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewWillDisappear(animated)
    }


    private func setupAVSession() throws {
        // 1. Select the front-facing camera
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video,
                                                        position: .front) else {
            throw NSError(domain: "Camera", code: -1)
        }
        
        // 2. Create an input from the camera
        let deviceInput = try AVCaptureDeviceInput(device: videoDevice)
        
        // 3. Create a capture session
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = .high
        
        // 4. Add the input to the session
        guard session.canAddInput(deviceInput) else { return }
        session.addInput(deviceInput)
        
        // 5. Create a preview layer and attach it to the view
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
        
        // 6. Commit configuration and start the session
        session.commitConfiguration()
        session.startRunning()
        cameraFeedSession = session
    }
    
}
