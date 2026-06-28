import Foundation

struct VaultEntryStore {
    private let defaults: UserDefaults
    private let storageKey = "com.aaravgoyal.APIVault.keyEntries.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadEntries() -> [APIKeyEntry] {
        guard let data = defaults.data(forKey: storageKey) else {
            return []
        }

        do {
            return try JSONDecoder().decode([APIKeyEntry].self, from: data)
        } catch {
            return []
        }
    }

    func saveEntries(_ entries: [APIKeyEntry]) throws {
        let data = try JSONEncoder().encode(entries)
        defaults.set(data, forKey: storageKey)
    }
}
