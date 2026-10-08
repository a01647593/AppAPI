//
//  BookViewModel.swift
//  AppAPI
//
//  Created by kreb on 10/7/26.
//
import SwiftUI

// VIEWMODEL: Handles API data, loading, and errors
@MainActor
class BookViewModel: ObservableObject {

    @Published var books: [Book] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Get featured books when the app opens
    func loadFeaturedBooks() async {
        guard let url = URL(string:
            "https://openlibrary.org/subjects/fiction.json?limit=20"
        ) else {
            errorMessage = "Invalid URL."
            return
        }

        await fetchBooks(from: url, isSearch: false)
    }

    // Search books by title or author.
    func searchBooks(query: String) async {
        var components = URLComponents(
            string: "https://openlibrary.org/search.json"
        )

        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: "30")
        ]

        guard let url = components?.url else {
            errorMessage = "Invalid search URL."
            return
        }

        await fetchBooks(from: url, isSearch: true)
    }

    // Clean Code: one function for both API requests
    private func fetchBooks(from url: URL, isSearch: Bool) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let (data, response) = try await URLSession.shared.data(
                from: url
            )

            guard let response = response as? HTTPURLResponse else {
                throw BookError.invalidResponse
            }

            guard (200...299).contains(response.statusCode) else {
                throw BookError.serverError(response.statusCode)
            }

            let decoder = JSONDecoder()

            if isSearch {
                let result = try decoder.decode(
                    SearchResponse.self, from: data
                )
                books = result.docs.map { $0.toBook() }
            } else {
                let result = try decoder.decode(
                    FeaturedResponse.self, from: data
                )
                books = result.works.map { $0.toBook() }
            }

        } catch {
            books = []

            if let networkError = error as? URLError {
                switch networkError.code {
                case .notConnectedToInternet, .networkConnectionLost:
                    errorMessage = "No internet connection. Please try again."
                case .timedOut:
                    errorMessage = "The request timed out. Please try again."
                default:
                    errorMessage = networkError.localizedDescription
                }
            } else {
                errorMessage = error.localizedDescription
            }
        }
    }
}

// Readable errors when the API fails
enum BookError: LocalizedError {
    case invalidResponse
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from the server."
        case .serverError(let code):
            return "Server error \(code). Please try again."
        }
    }
}

