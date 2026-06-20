import SwiftUI

struct HomeView: View {

    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 28) {
                    titleHeader

                    if !viewModel.featuredMovies.isEmpty {
                        HomeHeroSlider(movies: viewModel.featuredMovies)
                    }

                    if viewModel.isLoading && !hasSectionContent {
                        sectionSkeletons
                    } else if let errorMessage = viewModel.errorMessage,
                              !hasSectionContent {
                        ErrorView(message: errorMessage) {
                            Task { await viewModel.retry() }
                        }
                        .frame(minHeight: 320)
                    } else {
                        movieSections
                    }
                }
                .padding(.bottom, 36)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailsView(movie: movie)
            }
            .navigationDestination(for: MovieCategory.self) { category in
                CategoryMoviesView(category: category)
            }
        }
        .task {
            await viewModel.loadContent()
        }
        .alert(
            "Couldn't Refresh",
            isPresented: refreshErrorPresented,
            actions: { Button("OK", role: .cancel) {} },
            message: { Text(viewModel.refreshError ?? "") }
        )
    }

    private var titleHeader: some View {
        Text("M4Movies")
            .font(.largeTitle.bold())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 8)
    }

    private var movieSections: some View {
        VStack(spacing: 30) {
            MovieSection(
                category: .popular,
                movies: viewModel.popularMovies
            )

            MovieSection(
                category: .nowPlaying,
                movies: viewModel.nowPlayingMovies
            )

            MovieSection(
                category: .topRated,
                movies: viewModel.topRatedMovies
            )
        }
    }

    private var sectionSkeletons: some View {
        VStack(spacing: 30) {
            ForEach(MovieCategory.homeSections) { category in
                MovieSectionSkeleton(title: category.title)
            }
        }
    }

    private var hasSectionContent: Bool {
        !viewModel.popularMovies.isEmpty ||
        !viewModel.nowPlayingMovies.isEmpty ||
        !viewModel.topRatedMovies.isEmpty
    }

    private var refreshErrorPresented: Binding<Bool> {
        Binding(
            get: { viewModel.refreshError != nil },
            set: { if !$0 { viewModel.refreshError = nil } }
        )
    }
}

private struct MovieSection: View {

    let category: MovieCategory
    let movies: [Movie]

    private let cardWidth: CGFloat = 154

    var body: some View {
        if !movies.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .top, spacing: 14) {
                        ForEach(movies) { movie in
                            NavigationLink(value: movie) {
                                MovieCard(movie: movie)
                                    .frame(width: cardWidth)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .scrollClipDisabled()
            }
        }
    }

    private var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(category.title)
                .font(.title2.bold())

            Spacer()

            NavigationLink(value: category) {
                HStack(spacing: 4) {
                    Text("View More")
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.accentColor)
            }
        }
        .padding(.horizontal, 16)
    }
}

private struct MovieSectionSkeleton: View {

    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title)
                    .font(.title2.bold())

                Spacer()

                Text("View More")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(0..<4, id: \.self) { _ in
                        MovieCardSkeleton()
                            .frame(width: 154)
                    }
                }
                .padding(.horizontal, 16)
            }
            .scrollDisabled(true)
            .scrollClipDisabled()
        }
    }
}

private extension MovieCategory {

    static let homeSections: [MovieCategory] = [
        .popular,
        .nowPlaying,
        .topRated
    ]
}

struct ErrorView: View {

    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Retry", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    HomeView()
}
