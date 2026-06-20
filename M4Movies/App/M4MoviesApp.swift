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

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(favoritesStore)
                .preferredColorScheme(.dark)
        }
    }
}
