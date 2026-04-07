import Foundation
import Testing
@testable import Jisa

@MainActor
struct TimezoneOverviewModelTests {
    private let referenceDate = Date(timeIntervalSince1970: 1_767_225_600) // 2026-01-01 00:00:00 UTC

    @Test func convertsOverrideDateAcrossMultipleTimeZones() {
        let store = InMemoryTimeZoneListStore(
            state: .init(
                timeZoneIDs: ["UTC", "Europe/Oslo", "Asia/Tokyo"],
                hasSeededSystemTimeZone: true
            )
        )
        let model = TimezoneOverviewModel(
            store: store,
            systemTimeZoneID: { "Europe/Oslo" }
        )

        model.applyOverride(referenceDate, for: "UTC")

        let rows = Dictionary(uniqueKeysWithValues: model.rows(now: referenceDate).map { ($0.id, $0) })

        #expect(rows["UTC"]?.dateText == "01/01/2026")
        #expect(rows["UTC"]?.timeText == "00:00")
        #expect(rows["Europe/Oslo"]?.timeText == "01:00")
        #expect(rows["Asia/Tokyo"]?.timeText == "09:00")
    }

    @Test func editingDifferentRowChangesReferenceTimeZone() {
        let store = InMemoryTimeZoneListStore(
            state: .init(
                timeZoneIDs: ["UTC", "Europe/Oslo", "Asia/Tokyo"],
                hasSeededSystemTimeZone: true
            )
        )
        let model = TimezoneOverviewModel(
            store: store,
            systemTimeZoneID: { "Europe/Oslo" }
        )

        model.beginEditing(.time, for: "UTC")
        model.applyOverride(referenceDate, for: "UTC")
        model.beginEditing(.date, for: "Asia/Tokyo")

        #expect(model.referenceTimeZoneID == "Asia/Tokyo")
        #expect(model.editingTarget == .init(component: .date, timeZoneID: "Asia/Tokyo"))
    }

    @Test func resetReturnsToLiveMode() {
        let store = InMemoryTimeZoneListStore(
            state: .init(
                timeZoneIDs: ["UTC", "Europe/Oslo", "Asia/Tokyo"],
                hasSeededSystemTimeZone: true
            )
        )
        let model = TimezoneOverviewModel(
            store: store,
            systemTimeZoneID: { "Europe/Oslo" }
        )

        model.applyOverride(referenceDate, for: "UTC")
        model.resetToNow()

        #expect(model.overrideDate == nil)
        #expect(model.referenceTimeZoneID == nil)
        #expect(model.editingTarget == nil)
    }

    @Test func overrideStatusShowsRelativeDescriptionAndReferenceTimeZone() {
        let store = InMemoryTimeZoneListStore(
            state: .init(
                timeZoneIDs: ["UTC", "Europe/Oslo", "Asia/Tokyo"],
                hasSeededSystemTimeZone: true
            )
        )
        let model = TimezoneOverviewModel(
            store: store,
            systemTimeZoneID: { "Europe/Oslo" }
        )

        model.applyOverride(referenceDate.addingTimeInterval(60 * 60), for: "UTC")

        let status = model.status(now: referenceDate)

        #expect(status.title == "In 1 hour")
        #expect(status.detail == "Reference timezone: UTC")
    }

    @Test func addMoveAndRemoveTimeZonesPersistState() {
        let store = InMemoryTimeZoneListStore(
            state: .init(
                timeZoneIDs: ["UTC", "Europe/Oslo", "Asia/Tokyo"],
                hasSeededSystemTimeZone: true
            )
        )
        let model = TimezoneOverviewModel(
            store: store,
            systemTimeZoneID: { "Europe/Oslo" }
        )

        model.addTimeZone("America/New_York")
        #expect(store.state.timeZoneIDs == ["UTC", "Europe/Oslo", "Asia/Tokyo", "America/New_York"])

        model.moveTimeZones(from: IndexSet(integer: 3), to: 1)
        #expect(store.state.timeZoneIDs == ["UTC", "America/New_York", "Europe/Oslo", "Asia/Tokyo"])

        model.removeTimeZones(at: IndexSet(integer: 2))
        #expect(store.state.timeZoneIDs == ["UTC", "America/New_York", "Asia/Tokyo"])
    }
}

private final class InMemoryTimeZoneListStore: TimeZoneListStore {
    var state: StoredTimeZoneList

    init(state: StoredTimeZoneList) {
        self.state = state
    }

    func load(defaultTimeZoneIDs: [String], systemTimeZoneID: String) -> StoredTimeZoneList {
        state
    }

    func save(_ state: StoredTimeZoneList) {
        self.state = state
    }
}
