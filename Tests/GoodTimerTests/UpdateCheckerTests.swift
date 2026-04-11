import XCTest
@testable import GoodTimer

final class UpdateCheckerTests: XCTestCase {

    func testInitialState() {
        let checker = UpdateChecker()
        XCTAssertFalse(checker.isUpdateAvailable)
        XCTAssertNil(checker.latestVersion)
        XCTAssertNil(checker.releaseURL)
        XCTAssertFalse(checker.isChecking)
    }

    // MARK: - Semver comparison

    func testNewerVersionAvailable() {
        XCTAssertTrue(UpdateChecker.isNewer(remote: "1.4.0", thanLocal: "1.3.0"))
    }

    func testSameVersionNotNewer() {
        XCTAssertFalse(UpdateChecker.isNewer(remote: "1.3.0", thanLocal: "1.3.0"))
    }

    func testOlderVersionNotNewer() {
        XCTAssertFalse(UpdateChecker.isNewer(remote: "1.2.0", thanLocal: "1.3.0"))
    }

    func testNewerMinorVersion() {
        XCTAssertTrue(UpdateChecker.isNewer(remote: "1.4.0", thanLocal: "1.3.5"))
    }

    func testNewerPatchVersion() {
        XCTAssertTrue(UpdateChecker.isNewer(remote: "1.3.1", thanLocal: "1.3.0"))
    }

    func testNewerMajorVersion() {
        XCTAssertTrue(UpdateChecker.isNewer(remote: "2.0.0", thanLocal: "1.9.9"))
    }

    func testStripVPrefix() {
        XCTAssertTrue(UpdateChecker.isNewer(remote: "v1.4.0", thanLocal: "1.3.0"))
    }

    // MARK: - JSON parsing

    func testParseReleaseJSON() {
        let json = """
        {"tag_name": "v1.4.0", "html_url": "https://github.com/lindsayrain/good-timer/releases/tag/v1.4.0"}
        """.data(using: .utf8)!

        let result = UpdateChecker.parseRelease(from: json)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.version, "1.4.0")
        XCTAssertEqual(result?.url.absoluteString, "https://github.com/lindsayrain/good-timer/releases/tag/v1.4.0")
    }

    func testParseInvalidJSON() {
        let json = "not json".data(using: .utf8)!
        XCTAssertNil(UpdateChecker.parseRelease(from: json))
    }

    // MARK: - Throttle logic

    func testShouldCheckWhenNoPreviousCheck() {
        let defaults = UserDefaults(suiteName: "test-throttle-none")!
        defaults.removeObject(forKey: "lastUpdateCheckDate")
        XCTAssertTrue(UpdateChecker.shouldAutoCheck(defaults: defaults))
        defaults.removeSuite(named: "test-throttle-none")
    }

    func testShouldNotCheckWithin24Hours() {
        let defaults = UserDefaults(suiteName: "test-throttle-recent")!
        defaults.set(Date().addingTimeInterval(-6 * 3600), forKey: "lastUpdateCheckDate") // 6 hours ago
        XCTAssertFalse(UpdateChecker.shouldAutoCheck(defaults: defaults))
        defaults.removeSuite(named: "test-throttle-recent")
    }

    func testShouldCheckAfter24Hours() {
        let defaults = UserDefaults(suiteName: "test-throttle-old")!
        defaults.set(Date().addingTimeInterval(-25 * 3600), forKey: "lastUpdateCheckDate") // 25 hours ago
        XCTAssertTrue(UpdateChecker.shouldAutoCheck(defaults: defaults))
        defaults.removeSuite(named: "test-throttle-old")
    }

    // MARK: - Manual check

    func testManualCheckSetsIsChecking() {
        let checker = UpdateChecker()
        checker.manualCheck()
        XCTAssertTrue(checker.isChecking)
    }
}
