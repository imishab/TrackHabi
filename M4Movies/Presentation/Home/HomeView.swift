import SwiftUI

struct HomeView: View {

    @State private var viewModel = HomeViewModel()

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.movies.isEmpty {
                    MovieGridSkeleton(columns: columns)
                } else if let error = viewModel.errorMessage, viewModel.movies.isEmpty {
                    ErrorView(message: error) {
                        Task { await viewModel.retry() }
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.movies) { movie in
                                MovieCard(movie: movie)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Popular Movies")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await viewModel.loadMovies()
        }
    }
}

// MARK: - Movie Card

private struct MovieCard: View {

    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: movie.posterURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .shimmering()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "film")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(movie.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
                .foregroundStyle(.primary)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(.yellow)

                Text(String(format: "%.1f", movie.voteAverage))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(movie.releaseYear)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Skeleton Loading

private struct MovieGridSkeleton: View {

    let columns: [GridItem]

    private let placeholderCount = 8

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(0..<placeholderCount, id: \.self) { _ in
                    MovieCardSkeleton()
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .scrollDisabled(true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading movies")
    }
}

private struct MovieCardSkeleton: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray5))
                .frame(height: 220)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(height: 14)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.systemGray5))
                .frame(width: 90, height: 14)

            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 44, height: 12)

                Spacer()

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 36, height: 12)
            }
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shimmering()
    }
}

// MARK: - Error View

private struct ErrorView: View {

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

            Button("Retry") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    HomeView()
}
