//
//  ProfilePlaceholderView.swift
//  DailyDigest
//
//  Created by Sai Vikshit Kode on 9/25/25.
//

import SwiftUI

struct ProfilePlaceholderView: View {
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
