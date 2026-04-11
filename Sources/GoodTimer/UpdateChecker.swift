import Foundation
import SwiftUI

class UpdateChecker: ObservableObject {
    @Published var isUpdateAvailable = false
    @Published var latestVersion: String?
    @Published var releaseURL: URL?
    @Published var isChecking = false

    private static let apiURL = URL(string: "https://api.github.com/repos/lindsayrain/good-timer/releases/latest")!
    private static let checkIntervalKey = "lastUpdateCheckDate"
    private static let throttleInterval: TimeInterval = 24 * 3600

    struct ReleaseInfo {
        let version: String
        let url: URL
    }

    // MARK: - Public

    func checkOnLaunch(defaults: UserDefaults = .standard) {
        guard Self.shouldAutoCheck(defaults: defaults) else { return }
        checkForUpdates(defaults: defaults)
    }

    func manualCheck(defaults: UserDefaults = .standard) {
        checkForUpdates(defaults: defaults)
    }

    func checkForUpdates(defaults: UserDefaults = .standard) {
        guard !isChecking else { return }
        isChecking = true

        let request = URLRequest(url: Self.apiURL)
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { DispatchQueue.main.async { self?.isChecking = false } }

            guard let data = data,
                  let http = response as? HTTPURLResponse,
                  http.statusCode == 200,
                  let release = Self.parseRelease(from: data) else {
                return
            }

            defaults.set(Date(), forKey: Self.checkIntervalKey)

            let localVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"

            DispatchQueue.main.async {
                if Self.isNewer(remote: release.version, thanLocal: localVersion) {
                    self?.isUpdateAvailable = true
                    self?.latestVersion = release.version
                    self?.releaseURL = release.url
                } else {
                    self?.isUpdateAvailable = false
                    self?.latestVersion = nil
                    self?.releaseURL = nil
                }
            }
        }.resume()
    }

    // MARK: - Throttle

    static func shouldAutoCheck(defaults: UserDefaults = .standard) -> Bool {
        guard let lastCheck = defaults.object(forKey: checkIntervalKey) as? Date else {
            return true
        }
        return Date().timeIntervalSince(lastCheck) >= throttleInterval
    }

    // MARK: - Parsing

    static func parseRelease(from data: Data) -> ReleaseInfo? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tagName = json["tag_name"] as? String,
              let htmlURL = json["html_url"] as? String,
              let url = URL(string: htmlURL) else {
            return nil
        }
        let version = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName
        return ReleaseInfo(version: version, url: url)
    }

    // MARK: - Version comparison

    static func isNewer(remote: String, thanLocal local: String) -> Bool {
        let r = parseVersion(remote.hasPrefix("v") ? String(remote.dropFirst()) : remote)
        let l = parseVersion(local)
        if r.major != l.major { return r.major > l.major }
        if r.minor != l.minor { return r.minor > l.minor }
        return r.patch > l.patch
    }

    private static func parseVersion(_ string: String) -> (major: Int, minor: Int, patch: Int) {
        let parts = string.split(separator: ".").compactMap { Int($0) }
        return (
            major: parts.count > 0 ? parts[0] : 0,
            minor: parts.count > 1 ? parts[1] : 0,
            patch: parts.count > 2 ? parts[2] : 0
        )
    }
}
