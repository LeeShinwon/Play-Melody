import SwiftUI

struct ContentView: View {
    @State private var selection: Tab = .welcome

    enum Tab: Hashable {
        case welcome
        case guide
        case practice
        case play
    }
    
    var body: some View {
        TabView(selection: $selection) {
            WelcomeView(selection: $selection)
                .tabItem {
                    Label("Welcome", systemImage: "hand.wave")
                }
                .tag(Tab.welcome)

            GuideView(selection: $selection)
                .tabItem {
                    Label("Guide", systemImage: "info.circle")
                }
                .tag(Tab.guide)
            
            PracticeIntroView(selection: $selection)
                .tabItem {
                    Label("Practice", systemImage: "target")
                }
                .tag(Tab.practice)

            PlayIntroView()
                .tabItem {
                    Label("Play", systemImage: "music.note")
                }
                .tag(Tab.play)
        }
        .id(selection)
        .onAppear {
            let appearance = UITabBar.appearance()
            appearance.backgroundColor = .systemBackground
            appearance.barTintColor = .systemBackground
        }
                
    }
}

#Preview {
    ContentView()
        .environment(ModelData())
}
