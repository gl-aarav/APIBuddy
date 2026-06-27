import AppKit
import Foundation
import Observation

@MainActor
@Observable
final class VaultViewModel {
    let presets: [Preset]

    var selectedPresetID: Preset.ID?
    var storedPresetIDs: Set<Preset.ID> = []
    var searchText = ""
    var draftKey = ""
    var revealedKey: String?
    var isWorking = false
    var statusMessage: String?
    var errorMessage: String?

    private let keychain: KeychainManager

    init(
        presets: [Preset] = Preset.defaults,
        keychain: KeychainManager = .shared
    ) {
        self.presets = presets
        self.keychain = keychain
        selectedPresetID = presets.first?.id
        refreshKeyPresence()
    }

    var selectedPreset: Preset? {
        guard let selectedPresetID else { return presets.first }
        return presets.first { $0.id == selectedPresetID }
    }

    var selectedPresetHasStoredKey: Bool {
        guard let selectedPreset else { return false }
        return storedPresetIDs.contains(selectedPreset.id)
    }

    func presets(in category: PresetCategory) -> [Preset] {
        presets.filter { preset in
            guard preset.category == category else { return false }
            guard !searchText.isEmpty else { return true }

            return preset.serviceName.localizedCaseInsensitiveContains(searchText)
                || preset.environmentVariable.localizedCaseInsensitiveContains(searchText)
        }
    }

    func select(_ preset: Preset) {
        selectedPresetID = preset.id
        revealedKey = nil
        draftKey = ""
        errorMessage = nil
        statusMessage = nil
    }

    func refreshKeyPresence() {
        storedPresetIDs = Set(presets.filter { keychain.containsKey(for: $0) }.map(\.id))
    }

    func saveSelectedKey() async {
        guard let selectedPreset else { return }
        let trimmedKey = draftKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else {
            errorMessage = "Enter an API key before saving."
            return
        }

        let keychain = self.keychain
        await perform("Saved \(selectedPreset.serviceName) key.") {
            try keychain.saveKey(trimmedKey, for: selectedPreset)
        }

        if errorMessage == nil {
            draftKey = ""
            revealedKey = nil
            refreshKeyPresence()
        }
    }

    func revealSelectedKey() async {
        guard let selectedPreset else { return }

        let keychain = self.keychain
        await perform("Unlocked \(selectedPreset.serviceName) key.") {
            try keychain.fetchKey(for: selectedPreset)
        } onSuccess: { key in
            revealedKey = key
        }
    }

    func hideRevealedKey() {
        revealedKey = nil
        statusMessage = "Key hidden."
        errorMessage = nil
    }

    func deleteSelectedKey() async {
        guard let selectedPreset else { return }

        let keychain = self.keychain
        await perform("Deleted \(selectedPreset.serviceName) key.") {
            try keychain.deleteKey(for: selectedPreset)
        }

        if errorMessage == nil {
            draftKey = ""
            revealedKey = nil
            refreshKeyPresence()
        }
    }

    func copyExportCommand() async {
        guard let selectedPreset else { return }

        let keychain = self.keychain
        await perform("Copied export command for \(selectedPreset.serviceName).") {
            let key = try keychain.fetchKey(for: selectedPreset)
            let command = "export \(selectedPreset.environmentVariable)=\"\(Self.shellEscaped(key))\""
            return command
        } onSuccess: { command in
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(command, forType: .string)
        }
    }

    private func perform<Result: Sendable>(
        _ successMessage: String,
        operation: @escaping @Sendable () throws -> Result,
        onSuccess: (Result) -> Void = { _ in }
    ) async {
        isWorking = true
        errorMessage = nil
        statusMessage = nil

        do {
            let result = try await Task.detached {
                try operation()
            }.value
            onSuccess(result)
            statusMessage = successMessage
        } catch let error as KeychainError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isWorking = false
    }

    nonisolated private static func shellEscaped(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "$", with: "\\$")
            .replacingOccurrences(of: "`", with: "\\`")
    }
}
