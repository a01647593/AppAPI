//
//  Book.swift
//  AppAPI
//
//  Created by kreb on 10/7/26.
//
import Foundation

// MODEL: Stores book information
struct Book: Identifiable {
    let id: String
    let title: String
    let author: String
    let year: Int?
    let coverID: Int?
    let editionCount: Int?

    // Cover image from Open Library
    var coverURL: URL? {
        guard let coverID else { return nil }
        return URL(string: "https://covers.openlibrary.org/b/id/\(coverID)-M.jpg")
    }

    var largeCoverURL: URL? {
        guard let coverID else { return nil }
        return URL(string: "https://covers.openlibrary.org/b/id/\(coverID)-L.jpg")
    }
}

// JSON for featured books
struct FeaturedResponse: Decodable {
    let works: [FeaturedBook]
}

struct FeaturedBook: Decodable {
    let key: String
    let title: String
    let authors: [BookAuthor]?
    let coverID: Int?
    let firstPublishYear: Int?
    let editionCount: Int?

    enum CodingKeys: String, CodingKey {
        case key, title, authors
        case coverID = "cover_id"
        case firstPublishYear = "first_publish_year"
        case editionCount = "edition_count"
    }

    func toBook() -> Book {
        Book(
            id: key,
            title: title,
            author: authors?.map { $0.name }.joined(separator: ", ") ?? "Unknown author",
            year: firstPublishYear,
            coverID: coverID,
            editionCount: editionCount
        )
    }
}

struct BookAuthor: Decodable {
    let name: String
}

// JSON for searched books
struct SearchResponse: Decodable {
    let docs: [SearchBook]
}

struct SearchBook: Decodable {
    let key: String
    let title: String
    let authorName: [String]?
    let firstPublishYear: Int?
    let coverID: Int?
    let editionCount: Int?

    enum CodingKeys: String, CodingKey {
        case key, title
        case authorName = "author_name"
        case firstPublishYear = "first_publish_year"
        case coverID = "cover_i"
        case editionCount = "edition_count"
    }

    func toBook() -> Book {
        Book(
            id: key,
            title: title,
            author: authorName?.joined(separator: ", ") ?? "Unknown author",
            year: firstPublishYear,
            coverID: coverID,
            editionCount: editionCount
        )
    }
}
