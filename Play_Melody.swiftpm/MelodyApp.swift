import SwiftUI

@main
struct MelodyApp: App {
    @State var modelData = ModelData()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()    
            }
            .environment(modelData)
        }
    }
}
