//
//  HomeView.swift
//  DailyDigest
//
//  Created by Sai Vikshit Kode on 9/25/25.
//

import SwiftUI
import Observation

struct HomeView: View {
    @Bindable var vm: HeadlinesViewModel
    var ns: Namespace.ID
    var open: (String) -> Void

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    // NEWS OF THE DAY - hero
                    if let hero = vm.articles.first, let img = URL(string: hero.image ?? "") {
                        HeroCard(article: hero, imageURL: img) {
                            open(hero.url)
                        }
                        .matchedGeometryEffect(id: "hero-\(hero.url)", in: ns)
                        .padding(.horizontal, 16)
                    }

                    // Breaking News strip
                    SectionHeader(title: "Breaking News") {
                        // OPTIONAL: push to full list screen
                    }
                    .padding(.horizontal, 16)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 28) {
                            ForEach(vm.articles.prefix(10)) { a in
                                BreakingCard(article: a) { open(a.url) }
                                    .frame(width: 260, height: 160)
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Latest list
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(vm.articles) { a in
                            ArticleRow(article: a, ns: ns) { open(a.url) }
                                .onAppear {
                                    if a.id == vm.articles.last?.id {
                                        Task { await vm.loadMore(global: false) }
                                    }
                                }
                            Divider()
                                .padding(.leading, 92)
                        }
                    }
                    .padding(.top, 6)
                }
                .padding(.top, 12)
            }
            .refreshable { await vm.refresh(global: false) }
            .background(.background)
            .navigationTitle("DailyDigest")
        }
    }
}

private struct HomePreview: View {
    @State private var vm = HeadlinesViewModel()
    @Namespace private var ns

    var body: some View {
        HomeView(vm: vm, ns: ns, open: { _ in })
            .task {
                // simple mock data so the UI shows something
                vm.articles = [
                    ArticleUI(
                        title: "Candidate Biden Called Saudi Arabia a ‘Pariah.’",
                        description: "A look at the shifting US–Saudi relationship…",
                        url: "https://example.com/1",
                        source: "NYTimes",
                        image: "https://picsum.photos/600/400?1",
                        publishedAt: .now.addingTimeInterval(-4*3600)
                    ),
                    ArticleUI(
                        title: "A New Coronavirus Variant Is Spreading in New York",
                        description: "Officials report localized outbreaks...",
                        url: "https://example.com/2",
                        source: "Reuters",
                        image: "https://picsum.photos/600/400?2",
                        publishedAt: .now.addingTimeInterval(-6*3600)
                    ),
                    ArticleUI(
                        title: "Studies Examine Variant Surging in California",
                        description: "Early findings suggest higher transmissibility.",
                        url: "https://example.com/3",
                        source: "AP",
                        image: "https://picsum.photos/600/400?3",
                        publishedAt: .now.addingTimeInterval(-10*3600)
                    )
                ]
            }
    }
}

#Preview {
    HomePreview()
}
