import Combine
import Foundation
import SwiftUI

enum TimezoneEditableComponent: Equatable {
    case date
    case time
}

struct TimezoneEditingTarget: Equatable {
    let component: TimezoneEditableComponent
    let timeZoneID: String
}

struct TimezoneRowDisplay: Identifiable, Equatable {
    let id: String
    let timeZone: TimeZone
    let dateText: String
    let timeText: String
    let utcOffsetText: String
    let isSystemTimeZone: Bool
    let isReferenceTimeZone: Bool
    let isEditingDate: Bool
    let isEditingTime: Bool
}

struct TimezoneOverviewStatus: Equatable {
    let title: String
    let detail: String
}

@MainActor
final class TimezoneOverviewModel: ObservableObject {
    static let defaultTimeZoneIDs = ["UTC", "Europe/Oslo", "Asia/Tokyo"]

    @Published var savedTimeZoneIDs: [String]
    @Published var overrideDate: Date?
    @Published var referenceTimeZoneID: String?
    @Published var editingTarget: TimezoneEditingTarget?
    @Published var isManagingTimeZones = false
    @Published var searchText = ""

    private let store: TimeZoneListStore
    private let formatter: TimeZoneDisplayFormatter
    private let knownTimeZoneIDs: [String]
    private let systemTimeZoneIDProvider: () -> String

    init(
        store: TimeZoneListStore? = nil,
        formatter: TimeZoneDisplayFormatter? = nil,
        knownTimeZoneIDs: [String] = TimeZone.knownTimeZoneIdentifiers.sorted(),
        systemTimeZoneID: @escaping () -> String = { TimeZone.current.identifier }
    ) {
        let store = store ?? UserDefaultsTimeZoneListStore()
        let formatter = formatter ?? TimeZoneDisplayFormatter()

        self.store = store
        self.formatter = formatter
        self.knownTimeZoneIDs = knownTimeZoneIDs
        self.systemTimeZoneIDProvider = systemTimeZoneID

        let storedList = store.load(
            defaultTimeZoneIDs: Self.defaultTimeZoneIDs,
            systemTimeZoneID: systemTimeZoneID()
        )
        self.savedTimeZoneIDs = storedList.timeZoneIDs
    }

    var localeTimeZoneID: String {
        systemTimeZoneIDProvider()
    }

    func status(now: Date) -> TimezoneOverviewStatus {
        if let overrideDate {
            let detail: String
            if let referenceTimeZoneID = resolvedReferenceTimeZoneID {
                detail = "Reference timezone: \(referenceTimeZoneID)"
            } else {
                detail = "Tap Back to now to return to live time."
            }

            return TimezoneOverviewStatus(
                title: formatter.relativeDescription(from: now, to: overrideDate),
                detail: detail
            )
        }

        return TimezoneOverviewStatus(
            title: "Live now",
            detail: "Showing current time across your saved timezones."
        )
    }

    func rows(now: Date) -> [TimezoneRowDisplay] {
        let displayDate = overrideDate ?? now
        let referenceID = resolvedReferenceTimeZoneID

        return savedTimeZoneIDs.compactMap { id in
            guard let timeZone = TimeZone(identifier: id) else {
                return nil
            }

            return TimezoneRowDisplay(
                id: id,
                timeZone: timeZone,
                dateText: formatter.dateString(for: displayDate, in: timeZone),
                timeText: formatter.timeString(for: displayDate, in: timeZone),
                utcOffsetText: formatter.utcOffsetString(for: timeZone, at: displayDate),
                isSystemTimeZone: id == localeTimeZoneID,
                isReferenceTimeZone: overrideDate != nil && id == referenceID,
                isEditingDate: editingTarget == .init(component: .date, timeZoneID: id),
                isEditingTime: editingTarget == .init(component: .time, timeZoneID: id)
            )
        }
    }

    func beginEditing(_ component: TimezoneEditableComponent, for timeZoneID: String) {
        let target = TimezoneEditingTarget(component: component, timeZoneID: timeZoneID)

        if editingTarget == target {
            editingTarget = nil
            if overrideDate == nil {
                referenceTimeZoneID = nil
            }
            return
        }

        editingTarget = target
        referenceTimeZoneID = timeZoneID
    }

    func applyOverride(_ date: Date, for timeZoneID: String) {
        referenceTimeZoneID = timeZoneID
        overrideDate = date
    }

    func resetToNow() {
        overrideDate = nil
        referenceTimeZoneID = nil
        editingTarget = nil
    }

    func toggleManagementMode() {
        isManagingTimeZones.toggle()

        if isManagingTimeZones {
            editingTarget = nil
        } else {
            searchText = ""
        }
    }

    func searchResults(limit: Int = 20) -> [String] {
        let excluded = Set(savedTimeZoneIDs)
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let candidates = knownTimeZoneIDs.filter { !excluded.contains($0) }

        if query.isEmpty {
            return Array(candidates.prefix(limit))
        }

        return Array(
            candidates
                .filter { $0.localizedCaseInsensitiveContains(query) }
                .prefix(limit)
        )
    }

    func addTimeZone(_ id: String) {
        guard TimeZone(identifier: id) != nil, !savedTimeZoneIDs.contains(id) else {
            return
        }

        savedTimeZoneIDs.append(id)
        searchText = ""
        persist()
    }

    func removeTimeZones(at offsets: IndexSet) {
        savedTimeZoneIDs.remove(atOffsets: offsets)
        if let editingTarget, !savedTimeZoneIDs.contains(editingTarget.timeZoneID) {
            self.editingTarget = nil
        }
        if let referenceTimeZoneID, !savedTimeZoneIDs.contains(referenceTimeZoneID) {
            self.referenceTimeZoneID = nil
        }
        persist()
    }

    func moveTimeZones(from source: IndexSet, to destination: Int) {
        savedTimeZoneIDs.move(fromOffsets: source, toOffset: destination)
        persist()
    }

    private var resolvedReferenceTimeZoneID: String? {
        if let referenceTimeZoneID, savedTimeZoneIDs.contains(referenceTimeZoneID) {
            return referenceTimeZoneID
        }

        if savedTimeZoneIDs.contains(localeTimeZoneID) {
            return localeTimeZoneID
        }

        return savedTimeZoneIDs.first
    }

    private func persist() {
        store.save(
            StoredTimeZoneList(
                timeZoneIDs: savedTimeZoneIDs,
                hasSeededSystemTimeZone: true
            )
        )
    }
}
