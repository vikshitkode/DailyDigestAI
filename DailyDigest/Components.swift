//
//  Components.swift
//  DailyDigest
//
//  Created by Sai Vikshit Kode on 9/25/25.
//

import SwiftUI

// MARK: - Hero

struct HeroCard: View {
    let article: ArticleUI
    let imageURL: URL
    var tap: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: imageURL) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                Rectangle().fill(.secondary.opacity(0.1))
            }
            .frame(height: 210)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            LinearGradient(colors: [.clear, .black.opacity(0.7)],
                           startPoint: .center, endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .frame(height: 210)

            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .font(.title3).bold().foregroundStyle(.white)
                    .lineLimit(2)
                Button {
                    tap()
                } label: {
                    HStack(spacing: 6) {
                        Text("Learn More")
                    }
                    .bold()
                }
                .buttonStyle(.glass)
                .controlSize(.small).tint(.blue)
            }
            .padding(16)
        }
    }
}

// MARK: - Section header

struct SectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil
    var body: some View {
        HStack {
            Text(title).font(.title3).bold()
            Spacer()
            if let action {
                Button("More", action: action).font(.subheadline)
            }
        }
    }
}

// MARK: - Cards / Rows

struct BreakingCard: View {
    let article: ArticleUI
    var tap: () -> Void

    var body: some View {
        Button(action: tap) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: article.image ?? "")) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    case .empty: Rectangle().fill(.secondary.opacity(0.08))
                    case .failure: Rectangle().fill(.secondary.opacity(0.08))
                    @unknown default: Rectangle().fill(.secondary.opacity(0.08))
                    }
                }
                LinearGradient(colors: [.clear, .black.opacity(0.8)],
                               startPoint: .center, endPoint: .bottom)

                VStack(alignment: .leading) {
                    Spacer()
                    Text(article.title)
                        .font(.headline).bold()
                        .foregroundStyle(.white)
                        .lineLimit(2)
                }
                .padding(12)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct ArticleRow: View {
    let article: ArticleUI
    var ns: Namespace.ID
    var tap: () -> Void

    var body: some View {
        Button(action: tap) {
            HStack(alignment: .top, spacing: 12) {
                Thumb(urlString: article.image)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .matchedGeometryEffect(id: "thumb-\(article.url)", in: ns)

                VStack(alignment: .leading, spacing: 6) {
                    Text(article.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    HStack(spacing: 12) {
                        Label(relative(article.publishedAt), systemImage: "clock")
                        Label("\(pseudoViews(article)) views", systemImage: "eye")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

struct ArticleRowCompact: View {
    let article: ArticleUI
    var ns: Namespace.ID
    var tap: () -> Void

    var body: some View {
        Button(action: tap) {
            HStack(spacing: 12) {
                Thumb(urlString: article.image)
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .matchedGeometryEffect(id: "thumb-\(article.url)", in: ns)

                VStack(alignment: .leading, spacing: 4) {
                    Text(article.title).font(.subheadline).bold().lineLimit(2)
                    HStack(spacing: 10) {
                        Image(systemName: "clock"); Text(relative(article.publishedAt))
                        Image(systemName: "eye"); Text("\(pseudoViews(article))")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Small components

struct SearchBar: View {
    @Binding var text: String
    var onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
            TextField("Search", text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .submitLabel(.search)
                .onSubmit(onSubmit)
            Spacer()
            Button { } label: {
                Image(systemName: "slider.horizontal.3")
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial))
    }
}

struct CategoryTabs: View {
    let categories: [NewsCategory]
    @Binding var selection: NewsCategory

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 18) {
                ForEach(categories, id: \.self) { cat in
                    CategoryTabItem(
                        title: cat.rawValue,
                        isSelected: cat == selection
                    )
                    .contentShape(Rectangle())
                    .onTapGesture { selection = cat }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

private struct CategoryTabItem: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? Color.primary : Color.secondary)

            Rectangle()
                .fill(isSelected ? Color.primary : Color.clear)
                .frame(height: 2)
        }
    }
}

struct Thumb: View {
    let urlString: String?
    var body: some View {
        AsyncImage(url: URL(string: urlString ?? "")) { phase in
            switch phase {
            case .success(let img): img.resizable().scaledToFill()
            case .empty: Rectangle().fill(.secondary.opacity(0.08))
            case .failure: Rectangle().fill(.secondary.opacity(0.08))
            @unknown default: Rectangle().fill(.secondary.opacity(0.08))
            }
        }
        .background(Color.secondary.opacity(0.06))
    }
}

// MARK: - Utilities

func relative(_ date: Date) -> String {
    let f = RelativeDateTimeFormatter()
    f.unitsStyle = .short
    return f.localizedString(for: date, relativeTo: .now)
}

func pseudoViews(_ a: ArticleUI) -> Int {
    abs(a.url.hashValue % 2000) + 100
}

