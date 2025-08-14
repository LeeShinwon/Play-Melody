import CoreGraphics
import Vision

class HandGestureProcessor {
    enum State {
        case possiblePinch
        case pinched(finger: VNHumanHandPoseObservation.JointName)
        case possibleApart
        case apart
        case unknown
    }

    private(set) var state: State = .unknown

    private let pinchMaxDistance: CGFloat
    private let evidenceCounterStateTrigger: Int
    private var pinchEvidenceCounter = 0
    private var apartEvidenceCounter = 0

    init(pinchMaxDistance: CGFloat = 40, evidenceCounterStateTrigger: Int = 3) {
        self.pinchMaxDistance = pinchMaxDistance
        self.evidenceCounterStateTrigger = evidenceCounterStateTrigger
    }

    func reset() {
        state = .unknown
        pinchEvidenceCounter = 0
        apartEvidenceCounter = 0
    }

    /// Process distances between thumb and multiple fingers
    func processThumbAndFingers(thumb: CGPoint, fingerPoints: [(VNHumanHandPoseObservation.JointName, CGPoint)]) {

        let (minName, minDistance) = fingerPoints
            .map { ($0.0, thumb.distance(from: $0.1)) }
            .min(by: { $0.1 < $1.1 }) ?? (.indexTip, .infinity)

        if minDistance < pinchMaxDistance {
            pinchEvidenceCounter += 1
            apartEvidenceCounter = 0
            state = pinchEvidenceCounter >= evidenceCounterStateTrigger ? .pinched(finger: minName) : .possiblePinch
        } else {
            apartEvidenceCounter += 1
            pinchEvidenceCounter = 0
            state = apartEvidenceCounter >= evidenceCounterStateTrigger ? .apart : .possibleApart
        }
    }

    var isPinched: Bool {
        if case .pinched = state { true } else { false }
    }

    var pinchedFinger: VNHumanHandPoseObservation.JointName? {
        if case .pinched(let finger) = state {
            return finger
        }
        return nil
    }
    
    var pinchedFingerIndex: Int? {
        guard case .pinched(let joint) = state else { return nil }
        switch joint {
        case .indexTip: return 1
        case .middleTip: return 2
        case .ringTip: return 3
        case .littleTip: return 4
        default: return nil
        }
    }
}


// MARK: - CGPoint helpers

extension CGPoint {

    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }
}

