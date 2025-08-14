import SwiftUI

struct Play: Codable, Hashable, Identifiable {
    let id: Int
    let title: String
    let icon: String
    let description: String
    let color: String
    var opacity: Color {
        OpacityColor.opacity(from: color)
    }
    var gradient: AnyGradient {
        GradientColor.gradient(from: color)
    }
            
    let totalPage: Int?
    let scoreList: [[String]]?
    let scoreImages: [String]?
    let scorePointPositions: [[Double]]?
    
    enum GradientColor: String, CaseIterable, Codable {
        case yellow
        case red
        case green

        var gradient: AnyGradient {
            switch self {
            case .yellow: return Color.yellow.gradient
            case .red: return Color.red.gradient
            case .green: return Color.green.gradient
            }
        }

        static func gradient(from string: String) -> AnyGradient {
            GradientColor(rawValue: string)?.gradient ?? Color.gray.gradient
        }
    }
    
    enum OpacityColor: String, CaseIterable, Codable {
        case yellow
        case red
        case green

        var opacity: Color {
            switch self {
            case .yellow: return Color.yellow.opacity(0.5)
            case .red: return Color.red.opacity(0.5)
            case .green: return Color.green.opacity(0.5)
            }
        }

        static func opacity(from string: String) -> Color {
            OpacityColor(rawValue: string)?.opacity ?? Color.gray.opacity(0.5)
        }
    }

}
