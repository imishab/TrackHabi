import SwiftUI

@main
struct TrackHabiApp: App {

    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .preferredColorScheme(.dark)
            .task {
                try? await Task.sleep(for: .seconds(1.8))
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}
