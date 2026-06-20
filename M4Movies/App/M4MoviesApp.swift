//
//  M4MoviesApp.swift
//  M4Movies
//
//  Created by Miss-Hub on 19/06/26.
//

import SwiftUI

@main
struct M4MoviesApp: App {

    @State private var favoritesStore = FavoritesStore()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .environment(favoritesStore)

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
