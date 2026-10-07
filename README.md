# Book Explorer

## What the App Does

Book Explorer is an iOS app built with SwiftUI that allows users to discover and search for books. The home page displays 20 featured fiction books, and the search page lets users find books by title or author. Users can tap on a book to see more information, including its cover, author, publication year, and edition count.

## API Used

The app uses the free Open Library API to fetch real book information.

- Featured Books: https://openlibrary.org/subjects/fiction.json?limit=20
- Search Books: https://openlibrary.org/search.json?q=harry+potter&limit=30
- API Documentation: https://openlibrary.org/developers/api

## How to Run the App

**Steps:**

1. Download or clone the repository.
2. Open `BookExplorer.xcodeproj` in Xcode.
3. Select an iPhone simulator.
4. Press Command + R to build and run the app.
