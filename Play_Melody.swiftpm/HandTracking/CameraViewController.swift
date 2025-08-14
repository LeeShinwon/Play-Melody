//
//  CameraViewController.swift
//  Melody Practice
//
//  Created by 이신원 on 8/5/25.
//

import AVFoundation
import UIKit
import Vision

enum AppError: Error {
    case camera
    case vision
    
    var alertDescription: String {
        switch self {
        case .camera:
            return "Failed to access the camera. Please try again."
        case .vision:
            return "Hand tracking failed. Please try again."
        }
    }
}

enum HandSide: String, Equatable {
    case unknown
    case left
    case right
}

struct HandPoints: Equatable {
    let side: HandSide
    let points: [CGPoint]
}

class CameraViewController: UIViewController {
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?
    var onHandPointsDetected: (([HandPoints]) -> Void)?


    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try setupAVSession()
        } catch let error as AppError {
            showErrorAlert(error)
        } catch {
            showErrorAlert(.camera)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds

        if let orientation = UIDevice.current.videoRotationAngle,
           let connection = previewLayer?.connection,
           connection.isVideoRotationAngleSupported(orientation) {
            connection.videoRotationAngle = orientation
        }
    }


    func setupAVSession() throws {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            throw AppError.camera
        }

        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            throw AppError.camera
        }

        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = .high

        guard session.canAddInput(deviceInput) else { throw AppError.camera }
        session.addInput(deviceInput)

        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw AppError.camera
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resize //.resizeAspectFill
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.bounds
        
        self.previewLayer = previewLayer

        session.commitConfiguration()
        session.startRunning()
        cameraFeedSession = session
    }
    
    private func showErrorAlert(_ error: AppError) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        let handJoints: [VNHumanHandPoseObservation.JointName] = [
            .thumbTip, .indexTip, .middleTip, .ringTip, .littleTip,
                .thumbMP, .littleMCP
        ]
        
        let cgOrientation: CGImagePropertyOrientation = DispatchQueue.main.sync {
            if let ori = CGImagePropertyOrientation(orientation: UIDevice.current.orientation) {
                return ori
            } else {
                return .up
            }
        }
            
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: cgOrientation, options: [:]) // .up
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 2

        do {
            try handler.perform([handPoseRequest])
            guard let observations = handPoseRequest.results, !observations.isEmpty else { return }

            // extract points based on Vision coordinate system in the background
            var rawHandResults: [[CGPoint]] = []

            for observation in observations {
                var visionPoints: [CGPoint] = []

                for joint in handJoints {
                    if let point = try? observation.recognizedPoint(joint),
                       point.confidence > 0.3 {
                        visionPoints.append(point.location)
                    }
                }

                rawHandResults.append(visionPoints)
            }
            
            // coordinate conversion and hand classification on the main thread
            DispatchQueue.main.async {
                var finalResults: [HandPoints] = []

                for points in rawHandResults {
                    let side = self.classifyHandSide(by: points)
                    let converted = points.prefix(5).map { self.convertHandPoints($0) }
                    finalResults.append(HandPoints(side: side, points: converted))
                }

                self.onHandPointsDetected?(finalResults)
            }

        } catch {
            DispatchQueue.main.async {
                self.showErrorAlert(.vision)
            }
            print("Hand tracking failed: \(error)")
        }
    }
    
    // Convert Vision coordinate system to SwiftUI coordinate system
    @MainActor
    private func convertHandPoints(_ point: CGPoint) -> CGPoint {
        guard let previewLayer = self.previewLayer else { return .zero }

        let layerSize = previewLayer.bounds.size
        let orientation = UIDevice.current.orientation

        switch orientation {
        case .landscapeLeft, .landscapeRight:
            return CGPoint(x: point.x * layerSize.width,
                           y: point.y * layerSize.height)
        default:
            return CGPoint(x: (1 - point.x) * layerSize.width,
                           y: (1 - point.y) * layerSize.height)
        }
    }
    
    @MainActor
    private func classifyHandSide(by points: [CGPoint]) -> HandSide {
        guard points.count > 6 else { return .unknown }

        let thumbMP = points[5]
        let littleMCP = points[6]
        return (thumbMP.x < littleMCP.x) ? .left : .right
    }
}

extension CGImagePropertyOrientation {
    init?(orientation: UIDeviceOrientation) {
        switch orientation {
        case .landscapeLeft: self = .up
        case .landscapeRight: self = .down
        case .portrait: self = .right
        case .portraitUpsideDown: self = .left
        default: return nil
        }
    }
}

extension UIDevice {
    var videoRotationAngle: CGFloat? {
        switch self.orientation {
        case .landscapeLeft: return 180
        case .landscapeRight: return 0
        case .portrait: return 90
        case .portraitUpsideDown: return 270
        default: return nil
        }
    }
}
