//
//  HeadlinesViewModel.swift
//  DailyDigest
//
//  Created by Sai Vikshit Kode on 9/23/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class HeadlinesViewModel {
    
    var articles: [ArticleUI] = []
    var error: String?
    var lastRefresh: Date?
    var upToDateNotice: String?
    
    // flags
    private(set) var isRefreshing = false
    private(set) var isPaging = false
    
    private var page = 1
    private let pageSize = 20
    private var reachedEnd = false
    private let service = NewsService()
    
    func loadInitial(global: Bool) {
        page = 1; reachedEnd = false
        Task { await refresh(global: global, hard: true) }
    }
    
    func loadMore(global: Bool) async {
        guard !isPaging, !isRefreshing, !reachedEnd else { return }
        isPaging = true; defer { isPaging = false }
        do {
            page += 1
            let items = try await fetch(global: global, page: page)
            if items.isEmpty { reachedEnd = true }
            articles.append(contentsOf: dedupe(existing: articles, incoming: items))
        } catch { self.error = friendly(error); page = max(1, page - 1) }
    }
    
    func refresh(global: Bool, hard: Bool = false) async {
        while isPaging { try? await Task.sleep(nanoseconds: 150_000_000) }
        guard !isRefreshing else { return }
        isRefreshing = true; defer { isRefreshing = false }
        
        do {
            let fresh = try await fetch(global: global, page: 1)
            if hard || articles.isEmpty {
                articles = fresh
            } else {
                let newestExisting = articles.first?.publishedAt ?? .distantPast
                let newestFresh = fresh.first?.publishedAt ?? .distantPast
                if newestFresh <= newestExisting {
                    upToDateNotice = "You're up to date"
                } else {
                    let deduped = dedupe(existing: articles, incoming: fresh)
                    articles = deduped.sorted { $0.publishedAt > $1.publishedAt }
                }
            }
            lastRefresh = Date()
            page = 1
            reachedEnd = fresh.count < pageSize
        } catch { self.error = friendly(error) }
    }
    
    
    private func fetch(global: Bool, page: Int) async throws -> [ArticleUI] {
        if global {
            return try await service.fetchGlobal(page: page, pageSize: pageSize)
        } else {
            return try await service.fetchUSHeadlines(page: page, pageSize: pageSize)
        }
    }
    
    private func dedupe(existing: [ArticleUI], incoming: [ArticleUI]) -> [ArticleUI] {
        let existingURLs = Set(existing.map { $0.url })
        let newOnes = incoming.filter { !existingURLs.contains($0.url) }
        return (existing + newOnes).sorted(by: { $0.publishedAt > $1.publishedAt })
    }
    
    private func friendly(_ error: Error) -> String {
        if let u = error as? URLError {
            switch u.code {
            case .notConnectedToInternet: return "You’re offline. Check your connection."
            case .timedOut: return "The request timed out. Try again."
            default: break
            }
        }
        return "Couldn’t load news right now. Please try again."
    }
}
