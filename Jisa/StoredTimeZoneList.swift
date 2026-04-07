import Foundation

struct StoredTimeZoneList: Codable, Equatable {
    var timeZoneIDs: [String]
    var hasSeededSystemTimeZone: Bool

    static func bootstrap(
        stored: StoredTimeZoneList?,
        defaultTimeZoneIDs: [String],
        systemTimeZoneID: String,
        validTimeZoneIDs: some Sequence<String>
    ) -> StoredTimeZoneList {
        let validIDs = Set(validTimeZoneIDs)
        let seededIDs = sanitize(stored?.timeZoneIDs ?? defaultTimeZoneIDs, validTimeZoneIDs: validIDs)
        var result = StoredTimeZoneList(
            timeZoneIDs: seededIDs.isEmpty ? sanitize(defaultTimeZoneIDs, validTimeZoneIDs: validIDs) : seededIDs,
            hasSeededSystemTimeZone: stored?.hasSeededSystemTimeZone ?? false
        )

        if !result.hasSeededSystemTimeZone {
            if validIDs.contains(systemTimeZoneID), !result.timeZoneIDs.contains(systemTimeZoneID) {
                result.timeZoneIDs.append(systemTimeZoneID)
            }
            result.hasSeededSystemTimeZone = true
        }

        if result.timeZoneIDs.isEmpty {
            result.timeZoneIDs = sanitize(defaultTimeZoneIDs, validTimeZoneIDs: validIDs)
        }

        return result
    }

    private static func sanitize(_ ids: [String], validTimeZoneIDs: Set<String>) -> [String] {
        var seen = Set<String>()

        return ids.filter { id in
            guard validTimeZoneIDs.contains(id) else {
                return false
            }

            return seen.insert(id).inserted
        }
    }
}

protocol TimeZoneListStore {
    func load(defaultTimeZoneIDs: [String], systemTimeZoneID: String) -> StoredTimeZoneList
    func save(_ state: StoredTimeZoneList)
}

final class UserDefaultsTimeZoneListStore: TimeZoneListStore {
    private enum Keys {
        static let storedTimeZoneList = "stored-time-zone-list"
    }

    private let userDefaults: UserDefaults
    private let validTimeZoneIDs: [String]

    init(
        userDefaults: UserDefaults = .standard,
        validTimeZoneIDs: [String] = TimeZone.knownTimeZoneIdentifiers
    ) {
        self.userDefaults = userDefaults
        self.validTimeZoneIDs = validTimeZoneIDs
    }

    func load(defaultTimeZoneIDs: [String], systemTimeZoneID: String) -> StoredTimeZoneList {
        let storedState: StoredTimeZoneList? = if
            let data = userDefaults.data(forKey: Keys.storedTimeZoneList),
            let decoded = try? JSONDecoder().decode(StoredTimeZoneList.self, from: data)
        {
            decoded
        } else {
            nil
        }

        let bootstrapped = StoredTimeZoneList.bootstrap(
            stored: storedState,
            defaultTimeZoneIDs: defaultTimeZoneIDs,
            systemTimeZoneID: systemTimeZoneID,
            validTimeZoneIDs: validTimeZoneIDs
        )

        save(bootstrapped)
        return bootstrapped
    }

    func save(_ state: StoredTimeZoneList) {
        guard let data = try? JSONEncoder().encode(state) else {
            return
        }

        userDefaults.set(data, forKey: Keys.storedTimeZoneList)
    }
}
