import Foundation

struct APIKeyEntry: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let presetID: Preset.ID
    var label: String
    var environmentVariable: String
    let createdAt: Date

    var keychainAccount: String {
        "\(presetID).\(id.uuidString)"
    }

    var maskedValue: String {
        String(repeating: "•", count: 12)
    }

    var exportTemplate: String {
        "export \(environmentVariable)=\"\(maskedValue)\""
    }
}
