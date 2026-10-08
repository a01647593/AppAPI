
import SwiftUI

// Detail screen when a book is selected.
struct BookDetailView: View {

    let book: Book

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Large book cover
                AsyncImage(url: book.largeCoverURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()

                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()

                    case .failure:
                        Image(systemName: "book.closed")
                            .font(.largeTitle)
                            .foregroundStyle(.gray)

                    @unknown default:
                        Image(systemName: "book.closed")
                    }
                }
                .frame(width: 200, height: 280)
                .padding(.top, 20)

                // Book information
                Text(book.title)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)

                Text(book.author)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Divider()

                VStack(alignment: .leading, spacing: 15) {

                    if let year = book.year {
                        Label(
                            "First published: \(year)",
                            systemImage: "calendar"
                        )
                    }

                    if let editions = book.editionCount {
                        Label(
                            "Editions: \(editions)",
                            systemImage: "books.vertical"
                        )
                    }

                    Label(
                        "Information from Open Library",
                        systemImage: "globe"
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .padding()
        }
        .navigationTitle("Book Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
