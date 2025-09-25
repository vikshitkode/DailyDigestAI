//
//  ContentView.swift
//  DailyDigest
//
//  Created by Sai Vikshit Kode on 9/23/25.
//

import SwiftUI
import Observation
import UIKit

struct WebLink: Identifiable { let id = UUID(); let url: URL }

struct ContentView: View {
    @State private var vm = HeadlinesViewModel()
    @State private var selectedLink: WebLink?
    @Namespace private var ns

    var body: some View {
        TabView {
            HomeView(vm: vm, ns: ns, open: open)
                .tabItem { Label("Home", systemImage: "house.fill") }

            DiscoverView(vm: vm, ns: ns, open: open)
                .tabItem { Label("Discover", systemImage: "magnifyingglass") }

            ProfilePlaceholderView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .sheet(item: $selectedLink) { SafariView(url: $0.url).ignoresSafeArea() }
        .task { vm.loadInitial(global: false) }
    }

    private func open(_ urlString: String) {
        if let url = URL(string: urlString) { selectedLink = WebLink(url: url) }
    }
}

private struct ProfilePlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 64))
                Text("Profile coming soon")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("You")
        }
    }
}


#Preview {
    ContentView()
}
