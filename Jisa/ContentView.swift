//
//  ContentView.swift
//  Jisa
//
//  Created by Stian Frøystein on 2026/04/07.
//

import SwiftUI

struct ContentView: View {
    private let previewCities: [PreviewCity] = [
        .init(name: "Tokyo", description: "UTC+9"),
        .init(name: "Oslo", description: "UTC+1 / UTC+2"),
        .init(name: "New York", description: "UTC-5 / UTC-4")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Timezone workspace")
                        .font(.largeTitle.bold())
                        .accessibilityIdentifier("home.title")

                    Text("A SwiftUI shell for comparing cities, offsets, and working hours across timezones. Implementation details will follow.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("home.subtitle")
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Planned starting points")
                        .font(.headline)

                    ForEach(previewCities) { city in
                        HStack(spacing: 16) {
                            Image(systemName: "globe.europe.africa.fill")
                                .font(.title3)
                                .foregroundStyle(.tint)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(city.name)
                                    .font(.headline)
                                Text(city.description)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "clock")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemGroupedBackground))
    }
}

private struct PreviewCity: Identifiable {
    let id = UUID()
    let name: String
    let description: String
}

#Preview {
    ContentView()
}
