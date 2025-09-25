//
//  ArticleDetailView.swift
//  DailyDigest
//
//  Created by Sai Vikshit Kode on 9/25/25.
//

import SwiftUI

struct ArticleDetailView: View {
    let article: ArticleUI
    var open: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HeaderImage(urlString: article.image, title: article.title)

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Label("Michael S.", systemImage: "person.fill")
                            .labelStyle(.titleAndIcon)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Capsule().fill(.thinMaterial))
                        StatPill(icon: "clock", text: "\(readingTimeMins(article)) h")
                        StatPill(icon: "eye", text: "\(pseudoViews(article))")
                    }

                    Text(article.title)
                        .font(.title3).bold()
                        .padding(.top, 6)

                    Text(article.description ?? "No description available.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(2)

                    Button("Open original →") {
                        open(article.url)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 12)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 16, y: -4))
                .offset(y: -28)
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    private func readingTimeMins(_ a: ArticleUI) -> Int {
        // rough: 200 wpm; use description length if body not available
        let words = (a.description ?? a.title).split(separator: " ").count
        return max(1, Int(ceil(Double(words) / 200.0)))
    }

    private func pseudoViews(_ a: ArticleUI) -> Int {
        abs(a.url.hashValue % 1800) + 100 // stable pseudo number
    }
}

private struct HeaderImage: View {
    let urlString: String?
    let title: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: urlString ?? "")) { phase in
                switch phase {
                case .empty:
                    Rectangle().fill(.secondary.opacity(0.1))
                        .overlay(ProgressView())
                case .success(let img):
                    img.resizable().scaledToFill()
                case .failure:
                    Rectangle().fill(.secondary.opacity(0.1))
                @unknown default:
                    Rectangle().fill(.secondary.opacity(0.1))
                }
            }
            .frame(height: 280)
            .clipped()

            LinearGradient(colors: [.black.opacity(0.0), .black.opacity(0.7)],
                           startPoint: .center, endPoint: .bottom)
                .frame(height: 140)

            VStack(alignment: .leading, spacing: 10) {
                Text("Health") // you can compute a real category if you want
                    .font(.caption).bold()
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Capsule().fill(.ultraThinMaterial))
                Text(title)
                    .font(.title).bold().foregroundStyle(.white)
                    .shadow(radius: 4)
            }
            .padding(16)
        }
    }
}

private struct StatPill: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.subheadline)
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Capsule().fill(.thinMaterial))
    }
}

