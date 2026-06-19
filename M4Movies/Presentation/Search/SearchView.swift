import SwiftUI

struct SearchView: View {

    @State private var query = ""

    var body: some View {
        NavigationStack {
            ContentUnavailableView.search(text: query)
                .navigationTitle("Search")
        }
        .searchable(text: $query, prompt: "Search movies")
    }
}

#Preview {
    SearchView()
}
