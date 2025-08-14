import SwiftUI

struct Practice: Hashable, Codable, Identifiable {
    let id: Int
    let name: String
    let isLeftHand: Bool
    let note: String
    
    var handImage: Image {
        Image("hand_" + note)
    }
    var noteImage: Image {
        Image("note_" + note )
    }
}
