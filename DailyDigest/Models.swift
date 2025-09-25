//
//  Models.swift
//  DailyDigest
//
//  Created by Sai Vikshit Kode on 9/23/25.
//

import Foundation

struct NewsAPIResponse: Decodable {
    let status: String
    let totalResults: Int
    let articles: [NewsAPIArticle]
}

struct NewsAPIArticle: Decodable {
    struct Source: Decodable { let id: String?; let name: String? }
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: Date
    let content: String?
}

struct ArticleUI: Identifiable {
    let id = UUID()
    let title: String
    let description: String?
    let url: String
    let source: String?
    let image: String?
    let publishedAt: Date
}

extension URL: Identifiable {
    public var id: URL { self }
}
