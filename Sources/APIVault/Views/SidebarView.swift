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
                                storedKeyCount: viewModel.entries(for: preset).count
                            )
                            .tag(preset.id)
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
    let storedKeyCount: Int

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
            PresetIconView(preset: preset, size: 19)
                .opacity(storedKeyCount > 0 ? 1 : 0.7)
        }
        .badge(storedKeyCount > 0 ? "\(storedKeyCount)" : "")
        .help(storedKeyCount > 0 ? "\(storedKeyCount) keychain item(s)" : "No key saved yet")
    }
}
