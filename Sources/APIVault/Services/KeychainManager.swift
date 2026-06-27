import Foundation
import LocalAuthentication
import Security

struct KeychainManager: Sendable {
    static let shared = KeychainManager()

    private let service = "com.aaravgoyal.APIVault.api-key"

    func saveKey(_ key: String, for preset: Preset) throws {
        guard let secretData = key.data(using: .utf8) else {
            throw KeychainError.invalidData
        }

        try deleteKeyIfPresent(for: preset)

        var accessControlError: Unmanaged<CFError>?
        guard let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            .userPresence,
            &accessControlError
        ) else {
            let message = accessControlError?.takeRetainedValue().localizedDescription ?? "Unknown Security.framework error."
            throw KeychainError.accessControlCreationFailed(message)
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: preset.environmentVariable,
            kSecAttrLabel as String: "API Vault \(preset.serviceName) API Key",
            kSecAttrDescription as String: "API key protected by API Vault",
            kSecAttrAccessControl as String: accessControl,
            kSecUseDataProtectionKeychain as String: true,
            kSecValueData as String: secretData
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.from(status: status)
        }
    }

    func fetchKey(for preset: Preset) throws -> String {
        let context = LAContext()
        context.localizedReason = "Authenticate to reveal \(preset.serviceName)'s API key."

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: preset.environmentVariable,
            kSecUseDataProtectionKeychain as String: true,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            // Accessing the protected item triggers the native macOS biometric
            // or device-password sheet because the item was saved with
            // SecAccessControlCreateWithFlags(..., .userPresence, ...).
            kSecUseAuthenticationContext as String: context
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

    func deleteKey(for preset: Preset) throws {
        let status = SecItemDelete(baseQuery(for: preset) as CFDictionary)
        guard status == errSecSuccess else {
            throw KeychainError.from(status: status)
        }
    }

    func containsKey(for preset: Preset) -> Bool {
        let context = LAContext()
        context.interactionNotAllowed = true

        var query = baseQuery(for: preset)
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecUseAuthenticationContext as String] = context

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        return status == errSecSuccess || status == errSecInteractionNotAllowed
    }

    private func deleteKeyIfPresent(for preset: Preset) throws {
        let status = SecItemDelete(baseQuery(for: preset) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.from(status: status)
        }
    }

    private func baseQuery(for preset: Preset) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: preset.environmentVariable,
            kSecUseDataProtectionKeychain as String: true
        ]
    }
}
