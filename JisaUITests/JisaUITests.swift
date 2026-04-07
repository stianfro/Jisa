//
//  JisaUITests.swift
//  JisaUITests
//
//  Created by Stian Frøystein on 2026/04/07.
//

import XCTest

final class JisaUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testMainScreenShowsDefaultTimezones() throws {
        let app = launchApp()

        XCTAssertTrue(app.staticTexts["timezone.status.title"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts["timezone.status.title"].label, "Live now")
        XCTAssertTrue(app.staticTexts["timezone.row.UTC"].exists)
        XCTAssertTrue(app.staticTexts["timezone.row.Europe-Oslo"].exists)
        XCTAssertTrue(app.staticTexts["timezone.row.Asia-Tokyo"].exists)
    }

    @MainActor
    func testManagingTimezonesShowsSearchAndCanAddResult() throws {
        let app = launchApp()

        app.buttons["timezone.manage"].tap()

        let searchField = app.textFields["timezone.search"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))

        searchField.tap()
        searchField.typeText("New_York")

        let result = app.buttons["timezone.search-result.America-New-York"]
        XCTAssertTrue(result.waitForExistence(timeout: 2))
        result.tap()

        XCTAssertTrue(app.staticTexts["timezone.row.America-New-York"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testTappingDateShowsInlineDatePicker() throws {
        let app = launchApp()

        let dateField = app.buttons["timezone.date.UTC"]
        XCTAssertTrue(dateField.waitForExistence(timeout: 2))
        dateField.tap()

        let datePicker = app.descendants(matching: .any)["timezone.date-picker.UTC"]
        XCTAssertTrue(datePicker.waitForExistence(timeout: 2))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            launchApp()
        }
    }

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }
}
