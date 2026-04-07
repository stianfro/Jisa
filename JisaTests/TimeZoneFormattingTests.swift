import Foundation
import Testing
@testable import Jisa

struct TimeZoneFormattingTests {
    private let formatter = TimeZoneDisplayFormatter()
    private let referenceDate = Date(timeIntervalSince1970: 1_767_225_600) // 2026-01-01 00:00:00 UTC

    @Test func formatsDateAndTimeIn24HourTime() throws {
        let tokyo = try #require(TimeZone(identifier: "Asia/Tokyo"))

        #expect(formatter.dateString(for: referenceDate, in: tokyo) == "01/01/2026")
        #expect(formatter.timeString(for: referenceDate, in: tokyo) == "09:00")
    }

    @Test func formatsUTCOffset() throws {
        let tokyo = try #require(TimeZone(identifier: "Asia/Tokyo"))

        #expect(formatter.utcOffsetString(for: tokyo, at: referenceDate) == "+09:00")
    }

    @Test func formatsFutureRelativeDifference() {
        let now = referenceDate
        let future = now.addingTimeInterval((2 * 24 * 60 * 60) + (7 * 60 * 60) + (3 * 60))

        #expect(
            formatter.relativeDescription(from: now, to: future) == "In 2 days, 7 hours and 3 minutes"
        )
    }

    @Test func formatsPastRelativeDifference() {
        let now = referenceDate
        let past = now.addingTimeInterval(-((24 * 60 * 60) + (2 * 60 * 60) + (14 * 60)))

        #expect(
            formatter.relativeDescription(from: now, to: past) == "1 day, 2 hours and 14 minutes ago"
        )
    }
}
