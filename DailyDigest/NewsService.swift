//
//  NewsService.swift
//  DailyDigest
//
//  Created by Sai Vikshit Kode on 9/23/25.
//

import Foundation

final class NewsService {
    // Insert your NewsAPI key here (or set in scheme’s env var NEWSAPI_KEY)
    private let apiKey = ProcessInfo.processInfo.environment["NEWSAPI_KEY"] ?? "46a76a4c77894640af59e8118f3d4cda"
    private let session = URLSession.shared
    private let base = URL(string: "https://newsapi.org/v2")!

    // Ensures images are https and valid
    func usableImageURLString(_ s: String?) -> String? {
        guard var comps = URLComponents(string: s ?? "") else { return nil }
        if comps.scheme == "http" { comps.scheme = "https" }
        return comps.url?.absoluteString
    }

    // Fetch USA headlines (/top-headlines)
    func fetchUSHeadlines(page: Int, pageSize: Int) async throws -> [ArticleUI] {
        var comps = URLComponents(url: base.appendingPathComponent("top-headlines"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            .init(name: "country", value: "us"),
            .init(name: "page", value: String(page)),
            .init(name: "pageSize", value: String(pageSize))
        ]
        return try await fetchMappedArticles(url: comps.url!)
    }

    // Fetch global news (/everything) → requires q param
    func fetchGlobal(page: Int, pageSize: Int, language: String = "en") async throws -> [ArticleUI] {
        var comps = URLComponents(url: base.appendingPathComponent("everything"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            .init(name: "q", value: "the"), // broad match to approximate global feed
            .init(name: "language", value: language),
            .init(name: "sortBy", value: "publishedAt"),
            .init(name: "page", value: String(page)),
            .init(name: "pageSize", value: String(pageSize))
        ]
        return try await fetchMappedArticles(url: comps.url!)
    }

    private func fetchMappedArticles(url: URL) async throws -> [ArticleUI] {
        var req = URLRequest(url: url)
        req.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")

        let (data, resp) = try await session.data(for: req)
        if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(NewsAPIResponse.self, from: data)

        // Map to UI model and filter for valid https images
        let mapped: [ArticleUI] = decoded.articles.compactMap { a in
            let img = usableImageURLString(a.urlToImage)
            return ArticleUI(
                title: a.title,
                description: a.description,
                url: a.url,
                source: a.source.name,
                image: img,
                publishedAt: a.publishedAt
            )
        }.filter { $0.image != nil && !$0.title.isEmpty && URL(string: $0.url) != nil }

        return mapped
    }
}
