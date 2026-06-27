import SwiftUI

struct PresetDetailView: View {
    var viewModel: VaultViewModel
    let namespace: Namespace.ID

    var body: some View {
        ZStack {
            if let preset = viewModel.selectedPreset {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header(for: preset)
                        secretPanel(for: preset)
                        savePanel(for: preset)
                        quickActions(for: preset)
                    }
                    .padding(34)
                    .frame(maxWidth: 760, alignment: .leading)
                }
                .scrollContentBackground(.hidden)
            } else {
                ContentUnavailableView("No Preset Selected", systemImage: "key.slash")
            }
        }
    }

    private func header(for preset: Preset) -> some View {
        HStack(alignment: .center, spacing: 18) {
            Image(systemName: preset.symbolName)
                .font(.system(size: 34, weight: .semibold))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(preset.accent.color)
                .frame(width: 72, height: 72)
                .glassEffect(.regular.tint(preset.accent.color.opacity(0.18)).interactive(), in: .rect(cornerRadius: 24))
                .glassEffectID("icon-\(preset.id)", in: namespace)

            VStack(alignment: .leading, spacing: 6) {
                Text(preset.serviceName)
                    .font(.largeTitle.bold())
                Text(preset.environmentVariable)
                    .font(.title3.monospaced())
                    .foregroundStyle(.secondary)
            }

            Spacer()

            StoredStateBadge(isStored: viewModel.selectedPresetHasStoredKey)
        }
    }

    private func secretPanel(for preset: Preset) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Stored Secret", systemImage: "lock.shield")
                .font(.headline)

            HStack(spacing: 12) {
                Text(viewModel.revealedKey ?? preset.maskedValue)
                    .font(.system(.title3, design: .monospaced, weight: .semibold))
                    .textSelection(.enabled)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentTransition(.numericText())

                if viewModel.revealedKey == nil {
                    Button {
                        Task { await viewModel.revealSelectedKey() }
                    } label: {
                        Label("Reveal", systemImage: "touchid")
                    }
                    .disabled(!viewModel.selectedPresetHasStoredKey || viewModel.isWorking)
                } else {
                    Button {
                        viewModel.hideRevealedKey()
                    } label: {
                        Label("Hide", systemImage: "eye.slash")
                    }
                    .disabled(viewModel.isWorking)
                }
            }

            if !viewModel.selectedPresetHasStoredKey {
                Text("Save a key below to create a biometric-protected keychain item.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(22)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 26))
        .glassEffectID("secret-\(preset.id)", in: namespace)
        .buttonStyle(.glass)
        .buttonBorderShape(.capsule)
    }

    private func savePanel(for preset: Preset) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Save or Replace Key", systemImage: "square.and.arrow.down")
                .font(.headline)

            SecureField("Paste API key, for example \(preset.keyHint)", text: Bindable(viewModel).draftKey)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))

            HStack {
                Button {
                    Task { await viewModel.saveSelectedKey() }
                } label: {
                    Label(viewModel.selectedPresetHasStoredKey ? "Replace Key" : "Save Key", systemImage: "key.fill")
                }
                .keyboardShortcut("s", modifiers: [.command])
                .disabled(viewModel.draftKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isWorking)

                Button(role: .destructive) {
                    Task { await viewModel.deleteSelectedKey() }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .disabled(!viewModel.selectedPresetHasStoredKey || viewModel.isWorking)

                Spacer()

                if viewModel.isWorking {
                    ProgressView()
                        .controlSize(.small)
                }
            }
        }
        .padding(22)
        .glassEffect(.regular, in: .rect(cornerRadius: 26))
        .buttonStyle(.glass)
        .buttonBorderShape(.capsule)
    }

    private func quickActions(for preset: Preset) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Quick Actions", systemImage: "terminal")
                .font(.headline)

            Text(preset.exportTemplate)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.secondary)
                .textSelection(.enabled)

            HStack {
                Button {
                    Task { await viewModel.copyExportCommand() }
                } label: {
                    Label("Copy Export Command", systemImage: "doc.on.doc")
                }
                .disabled(!viewModel.selectedPresetHasStoredKey || viewModel.isWorking)

                Spacer()
            }

            if let statusMessage = viewModel.statusMessage {
                Label(statusMessage, systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.callout)
            }

            if let errorMessage = viewModel.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.callout)
            }
        }
        .padding(22)
        .glassEffect(.regular, in: .rect(cornerRadius: 26))
        .buttonStyle(.glass)
        .buttonBorderShape(.capsule)
    }
}

private struct StoredStateBadge: View {
    let isStored: Bool

    var body: some View {
        Label(isStored ? "Saved" : "Empty", systemImage: isStored ? "checkmark.seal.fill" : "circle.dashed")
            .font(.callout.weight(.semibold))
            .foregroundStyle(isStored ? .green : .secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .glassEffect(.regular.interactive(), in: .capsule)
    }
}
