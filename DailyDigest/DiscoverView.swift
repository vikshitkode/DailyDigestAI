//
//  DiscoverView.swift
//  DailyDigest
//
//  Created by Sai Vikshit Kode on 9/25/25.
//

import SwiftUI
import Observation

enum NewsCategory: String, CaseIterable, Identifiable {
    case health = "Health", politics = "Politics", art = "Art", food = "Food"
    case science = "Science", sports = "Sports", tech = "Tech"
    var id: String { rawValue }
}

struct DiscoverView: View {
    @Bindable var vm: HeadlinesViewModel
    var ns: Namespace.ID
    var open: (String) -> Void

    @State private var query: String = ""
    @State private var selected: NewsCategory = .health

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Discover")
                        .font(.largeTitle).bold()
                        .padding(.top, 6)

                    Text("News at your fingertips")
                        .foregroundStyle(.secondary)

                    SearchBar(text: $query) {
                        // OPTIONAL: hook up server search
                    }

                    CategoryTabs(categories: NewsCategory.allCases, selection: $selected)

                    // filtered list (simple heuristic for now)
                    VStack(spacing: 0) {
                        ForEach(filtered(vm.articles, by: selected)) { a in
                            ArticleRowCompact(article: a, ns: ns) { open(a.url) }
                            Divider().padding(.leading, 80)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .refreshable { await vm.refresh(global: false) }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func filtered(_ items: [ArticleUI], by cat: NewsCategory) -> [ArticleUI] {
        items.filter { a in
            let t = (a.title + " " + (a.description ?? "")).lowercased()
            switch cat {
            case .health:  return t.contains("covid") || t.contains("health") || t.contains("disease")
            case .politics:return t.contains("biden") || t.contains("election") || t.contains("senate") || t.contains("congress")
            case .art:     return t.contains("art") || t.contains("museum") || t.contains("film") || t.contains("movie")
            case .food:    return t.contains("food") || t.contains("restaurant") || t.contains("chef")
            case .science: return t.contains("science") || t.contains("research") || t.contains("study")
            case .sports:  return t.contains("game") || t.contains("team") || t.contains("league") || t.contains("match")
            case .tech:    return t.contains("tech") || t.contains("apple") || t.contains("google") || t.contains("ai")
            }
        }
    }
}


#Preview {
    DiscoverViewPreview()
}

private struct DiscoverViewPreview: View {
    @Namespace private var ns
    private let vm = HeadlinesViewModel()

    var body: some View {
        DiscoverView(vm: vm, ns: ns, open: { _ in })
    }
}
