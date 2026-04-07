//
//  ContentView.swift
//  Jisa
//
//  Created by Stian Frøystein on 2026/04/07.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var model = TimezoneOverviewModel()

    var body: some View {
        NavigationStack {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                ContentList(model: model, now: context.date)
            }
            .navigationTitle("Jisa")
        }
    }
}

private struct ContentList: View {
    @ObservedObject var model: TimezoneOverviewModel
    let now: Date

    var body: some View {
        List {
            statusSection
            managementSection
            timezoneSection
        }
        .listStyle(.insetGrouped)
        .environment(\.editMode, .constant(model.isManagingTimeZones ? .active : .inactive))
    }

    private var statusSection: some View {
        let status = model.status(now: now)

        return Section {
            VStack(alignment: .leading, spacing: 12) {
                Text(status.title)
                    .font(.title3.weight(.semibold))
                    .accessibilityIdentifier("timezone.status.title")

                Text(status.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("timezone.status.detail")

                if model.overrideDate != nil {
                    Button("Back to now") {
                        model.resetToNow()
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("timezone.reset")
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var managementSection: some View {
        Section {
            Button(model.isManagingTimeZones ? "Done managing timezones" : "Manage timezones") {
                withAnimation {
                    model.toggleManagementMode()
                }
            }
            .accessibilityIdentifier("timezone.manage")

            if model.isManagingTimeZones {
                TextField("Add timezone identifier", text: $model.searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier("timezone.search")

                let searchResults = model.searchResults()
                if searchResults.isEmpty {
                    Text("No matching timezone identifiers.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(searchResults, id: \.self) { id in
                        Button {
                            model.addTimeZone(id)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(id)
                                if let timeZone = TimeZone(identifier: id) {
                                    Text(TimeZoneDisplayFormatter().utcOffsetString(for: timeZone, at: now))
                                        .font(.caption.monospacedDigit())
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .accessibilityIdentifier("timezone.search-result.\(id.accessibilitySlug)")
                    }
                }
            }
        }
    }

    private var timezoneSection: some View {
        Section("Timezones") {
            let rows = model.rows(now: now)

            if model.isManagingTimeZones {
                ForEach(rows) { row in
                    timezoneRow(row)
                }
                .onDelete(perform: model.removeTimeZones)
                .onMove(perform: model.moveTimeZones)
            } else {
                ForEach(rows) { row in
                    timezoneRow(row)
                }
            }
        }
    }

    private func timezoneRow(_ row: TimezoneRowDisplay) -> some View {
        TimezoneRowView(
            row: row,
            isManaging: model.isManagingTimeZones,
            selection: Binding(
                get: { model.overrideDate ?? now },
                set: { model.applyOverride($0, for: row.id) }
            ),
            onDateTap: { model.beginEditing(.date, for: row.id) },
            onTimeTap: { model.beginEditing(.time, for: row.id) }
        )
    }
}

private extension String {
    var accessibilitySlug: String {
        unicodeScalars.map { scalar in
            CharacterSet.alphanumerics.contains(scalar) ? String(scalar) : "-"
        }
        .joined()
    }
}
