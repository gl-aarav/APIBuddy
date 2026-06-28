import SwiftUI

struct MenuBarVaultView: View {
    var viewModel: VaultViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "key.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Text("API Vault")
                    .font(.headline)

                Spacer()

                if viewModel.isWorking {
                    ProgressView()
                        .controlSize(.small)
                }
            }

            Divider()

            ScrollView {
                if viewModel.entries.isEmpty {
                    ContentUnavailableView("No Saved APIs", systemImage: "key.slash")
                        .frame(maxWidth: .infinity, minHeight: 120)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(PresetCategory.allCases) { category in
                            let categoryPresets = viewModel.presetsWithEntries(in: category)
                            if !categoryPresets.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(category.rawValue)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 8)

                                    VStack(spacing: 8) {
                                        ForEach(categoryPresets) { preset in
                                            ForEach(viewModel.entries(for: preset)) { entry in
                                                MenuBarAPIEntryRow(
                                                    preset: preset,
                                                    entry: entry,
                                                    isWorking: viewModel.isWorking
                                                ) {
                                                    Task {
                                                        await viewModel.copyExportCommand(for: entry, preset: preset)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxHeight: 430)

            if let statusMessage = viewModel.statusMessage {
                Label(statusMessage, systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                    .lineLimit(2)
                    .padding(.top, 8)
            }

            if let errorMessage = viewModel.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .lineLimit(2)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

private struct MenuBarAPIEntryRow: View {
    let preset: Preset
    let entry: APIKeyEntry
    let isWorking: Bool
    let onCopy: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            PresetIconView(preset: preset, size: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.label)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                Text(entry.environmentVariable)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 10)

            Button(action: onCopy) {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .help("Copy export command")
            .disabled(isWorking)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .glassEffect(.regular, in: .rect(cornerRadius: 14))
    }
}
