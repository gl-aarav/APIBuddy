import SwiftUI

struct SidebarView: View {
    var viewModel: VaultViewModel

    var body: some View {
        List(selection: Bindable(viewModel).selectedPresetID) {
            ForEach(PresetCategory.allCases) { category in
                let categoryPresets = viewModel.presets(in: category)
                if !categoryPresets.isEmpty {
                    Section(category.rawValue) {
                        ForEach(categoryPresets) { preset in
                            PresetSidebarRow(
                                preset: preset,
                                hasStoredKey: viewModel.storedPresetIDs.contains(preset.id)
                            )
                            .tag(preset.id)
                            .onTapGesture {
                                viewModel.select(preset)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("API Vault")
        .toolbar(removing: .sidebarToggle)
    }
}

private struct PresetSidebarRow: View {
    let preset: Preset
    let hasStoredKey: Bool

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(preset.serviceName)
                    .font(.body.weight(.medium))
                Text(preset.environmentVariable)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        } icon: {
            Image(systemName: preset.symbolName)
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(hasStoredKey ? preset.accent.color : .secondary)
        }
        .badge(hasStoredKey ? "Saved" : "")
        .help(hasStoredKey ? "Stored in the system keychain" : "No key saved yet")
    }
}
