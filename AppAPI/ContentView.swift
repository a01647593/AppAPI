//
//  ContentView.swift
//  AppAPI
//
//  Created by kreb on 10/7/26.
//


import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = BookViewModel()
    @State private var searchText = ""
    @State private var currentSearch = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.gray)

                    TextField("Search books or authors", text: $searchText)
                        .autocorrectionDisabled()
                        .onSubmit {
                            searchBooks()
                        }

                    if !searchText.isEmpty {
                        Button {
                            clearSearch()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.gray)
                        }
                        .disabled(viewModel.isLoading)
                    }

                    Button("Search") {
                        searchBooks()
                    }
                    .disabled(
                        searchText.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty || viewModel.isLoading
                    )
                }
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding()

                // Loading state
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading books...")
                    Spacer()

                // API or network error
                } else if let error = viewModel.errorMessage {
                    Spacer()

                    VStack(spacing: 15) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.largeTitle)

                        Text(error)
                            .multilineTextAlignment(.center)

                        Button("Try Again") {
                            Task {
                                await loadBooks()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()

                    Spacer()

                // No results
                } else if viewModel.books.isEmpty {
                    Spacer()

                    ContentUnavailableView(
                        "No Books Found",
                        systemImage: "books.vertical",
                        description: Text("Try searching for another book.")
                    )

                    Spacer()

                // List of books
                } else {
                    List(viewModel.books) { book in
                        NavigationLink {
                            BookDetailView(book: book)
                        } label: {
                            BookRowView(book: book)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(
                currentSearch.isEmpty ? "Book Explorer" : "Search Results"
            )
            .task {
                await viewModel.loadFeaturedBooks()
            }
        }
    }

    // Search using the API
    private func searchBooks() {
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !query.isEmpty, !viewModel.isLoading else {
            return
        }

        currentSearch = query

        Task {
            await viewModel.searchBooks(query: query)
        }
    }

    // Return to the featured books
    private func clearSearch() {
        guard !viewModel.isLoading else { return }

        searchText = ""
        currentSearch = ""

        Task {
            await viewModel.loadFeaturedBooks()
        }
    }

    // Retry whichever request failed
    private func loadBooks() async {
        if currentSearch.isEmpty {
            await viewModel.loadFeaturedBooks()
        } else {
            await viewModel.searchBooks(query: currentSearch)
        }
    }
}

// Reusable row for every book
struct BookRowView: View {

    let book: Book

    var body: some View {
        HStack(spacing: 15) {

            AsyncImage(url: book.coverURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()

                case .failure:
                    Image(systemName: "book.closed")
                        .foregroundStyle(.gray)

                @unknown default:
                    Image(systemName: "book.closed")
                }
            }
            .frame(width: 65, height: 95)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 6) {

                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(book.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                if let year = book.year {
                    Text("Published: \(year)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    ContentView()
}


