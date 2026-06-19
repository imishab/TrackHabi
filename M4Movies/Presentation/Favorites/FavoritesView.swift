import SwiftUI

struct FavoritesView: View {

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "No Favorites Yet",
                systemImage: "heart",
                description: Text("Movies you mark as favorite will appear here.")
            )
            .navigationTitle("Favorites")
        }
    }
}

#Preview {
    FavoritesView()
}
