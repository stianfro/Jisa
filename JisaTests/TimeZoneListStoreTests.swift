import Foundation
import Testing
@testable import Jisa

struct TimeZoneListStoreTests {
    @Test func bootstrapAddsSystemTimeZoneOnceWhenMissing() {
        let bootstrapped = StoredTimeZoneList.bootstrap(
            stored: nil,
            defaultTimeZoneIDs: ["UTC", "Europe/Oslo", "Asia/Tokyo"],
            systemTimeZoneID: "America/New_York",
            validTimeZoneIDs: ["UTC", "Europe/Oslo", "Asia/Tokyo", "America/New_York"]
        )

        #expect(bootstrapped.timeZoneIDs == ["UTC", "Europe/Oslo", "Asia/Tokyo", "America/New_York"])
        #expect(bootstrapped.hasSeededSystemTimeZone)
    }

    @Test func bootstrapDoesNotDuplicateExistingSystemTimeZone() {
        let bootstrapped = StoredTimeZoneList.bootstrap(
            stored: .init(timeZoneIDs: ["UTC", "Europe/Oslo"], hasSeededSystemTimeZone: false),
            defaultTimeZoneIDs: ["UTC", "Europe/Oslo", "Asia/Tokyo"],
            systemTimeZoneID: "Europe/Oslo",
            validTimeZoneIDs: ["UTC", "Europe/Oslo", "Asia/Tokyo"]
        )

        #expect(bootstrapped.timeZoneIDs == ["UTC", "Europe/Oslo"])
        #expect(bootstrapped.hasSeededSystemTimeZone)
    }

    @Test func bootstrapDoesNotReinsertSystemTimeZoneAfterInitialSeed() {
        let bootstrapped = StoredTimeZoneList.bootstrap(
            stored: .init(timeZoneIDs: ["UTC", "Asia/Tokyo"], hasSeededSystemTimeZone: true),
            defaultTimeZoneIDs: ["UTC", "Europe/Oslo", "Asia/Tokyo"],
            systemTimeZoneID: "Europe/Oslo",
            validTimeZoneIDs: ["UTC", "Europe/Oslo", "Asia/Tokyo"]
        )

        #expect(bootstrapped.timeZoneIDs == ["UTC", "Asia/Tokyo"])
        #expect(bootstrapped.hasSeededSystemTimeZone)
    }
}
