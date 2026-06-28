import Foundation
import LocalAuthentication
import Security

struct KeychainManager: Sendable {
    static let shared = KeychainManager()

    private let service = "com.aaravgoyal.APIVault.api-key"

    func saveKey(_ key: String, for entry: APIKeyEntry, preset: Preset) throws {
        guard let secretData = key.data(using: .utf8) else {
            throw KeychainError.invalidData
        }

        try deleteKeyIfPresent(account: entry.keychainAccount)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: entry.keychainAccount,
            kSecAttrLabel as String: "API Vault \(preset.serviceName) \(entry.label)",
            kSecAttrDescription as String: "API key protected by API Vault",
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecValueData as String: secretData
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.from(status: status)
        }
    }

    func fetchKey(for entry: APIKeyEntry, preset: Preset) async throws -> String {
        let context = LAContext()
        let reason = "Authenticate to reveal \(entry.label) for \(preset.serviceName)."

        // The generic-password item stays in the macOS keychain. We gate every
        // app-level read behind native device-owner authentication so revealing
        // or copying a secret always triggers Touch ID or the device password.
        try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: entry.keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else {
            throw KeychainError.from(status: status)
        }

        guard
            let data = result as? Data,
            let key = String(data: data, encoding: .utf8)
        else {
            throw KeychainError.invalidData
        }

        return key
    }

    func deleteKey(for entry: APIKeyEntry) throws {
        let status = SecItemDelete(baseQuery(account: entry.keychainAccount) as CFDictionary)
        guard status == errSecSuccess else {
            throw KeychainError.from(status: status)
        }
    }

    func containsKey(for entry: APIKeyEntry) -> Bool {
        let context = LAContext()
        context.interactionNotAllowed = true

        var query = baseQuery(account: entry.keychainAccount)
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecUseAuthenticationContext as String] = context

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        return status == errSecSuccess || status == errSecInteractionNotAllowed
    }

    private func deleteKeyIfPresent(account: String) throws {
        let status = SecItemDelete(baseQuery(account: account) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.from(status: status)
        }
    }

    private func baseQuery(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
