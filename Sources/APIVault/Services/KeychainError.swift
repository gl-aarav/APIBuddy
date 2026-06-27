import Foundation
import Security

enum KeychainError: LocalizedError, Equatable {
    case accessControlCreationFailed(String)
    case duplicateItem
    case itemNotFound
    case authenticationCanceled
    case invalidData
    case unexpectedStatus(OSStatus)

    var errorDescription: String? {
        switch self {
        case .accessControlCreationFailed(let message):
            "Unable to create biometric keychain protection: \(message)"
        case .duplicateItem:
            "A key already exists for this preset."
        case .itemNotFound:
            "No saved key was found for this preset."
        case .authenticationCanceled:
            "Authentication was canceled."
        case .invalidData:
            "The saved keychain item could not be decoded."
        case .unexpectedStatus(let status):
            Self.message(for: status)
        }
    }

    static func from(status: OSStatus) -> KeychainError {
        switch status {
        case errSecDuplicateItem:
            .duplicateItem
        case errSecItemNotFound:
            .itemNotFound
        case errSecUserCanceled, errSecAuthFailed:
            .authenticationCanceled
        default:
            .unexpectedStatus(status)
        }
    }

    static func message(for status: OSStatus) -> String {
        if let securityMessage = SecCopyErrorMessageString(status, nil) as String? {
            return securityMessage
        }

        return "Keychain operation failed with status \(status)."
    }
}
