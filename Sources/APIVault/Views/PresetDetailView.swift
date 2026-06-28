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
                        keysPanel(for: preset)
                        savePanel(for: preset)
                        messagePanel
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
            PresetIconView(preset: preset, size: 46)
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

            StoredStateBadge(count: viewModel.selectedEntries.count)
        }
    }

    private func keysPanel(for preset: Preset) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("API Keys", systemImage: "lock.shield")
                .font(.headline)

            if viewModel.selectedEntries.isEmpty {
                Text("Save a key below to create a protected keychain item.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.selectedEntries) { entry in
                        APIKeyEntryRow(
                            entry: entry,
                            revealedKey: viewModel.revealedEntryID == entry.id ? viewModel.revealedKey : nil,
                            isWorking: viewModel.isWorking,
                            onReveal: {
                                Task { await viewModel.revealKey(entry) }
                            },
                            onHide: viewModel.hideRevealedKey,
                            onCopy: {
                                Task { await viewModel.copyExportCommand(for: entry) }
                            },
                            onDelete: {
                                Task { await viewModel.deleteKey(entry) }
                            }
                        )
                    }
                }
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
            Label("Add API Key", systemImage: "square.and.arrow.down")
                .font(.headline)

            TextField("Label, for example Production", text: Bindable(viewModel).draftLabel)
                .textFieldStyle(.roundedBorder)

            TextField("Environment variable", text: Bindable(viewModel).draftEnvironmentVariable)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))

            SecureField("Paste API key, for example \(preset.keyHint)", text: Bindable(viewModel).draftKey)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))

            HStack {
                Button {
                    Task { await viewModel.saveSelectedKey() }
                } label: {
                    Label("Save Key", systemImage: "key.fill")
                }
                .keyboardShortcut("s", modifiers: [.command])
                .disabled(viewModel.draftKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isWorking)

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

    private var messagePanel: some View {
        Group {
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
        .padding(.horizontal, 4)
    }
}

private struct StoredStateBadge: View {
    let count: Int

    var body: some View {
        Label(count == 1 ? "1 Key" : "\(count) Keys", systemImage: count > 0 ? "checkmark.seal.fill" : "circle.dashed")
            .font(.callout.weight(.semibold))
            .foregroundStyle(count > 0 ? .green : .secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .glassEffect(.regular.interactive(), in: .capsule)
    }
}

private struct APIKeyEntryRow: View {
    let entry: APIKeyEntry
    let revealedKey: String?
    let isWorking: Bool
    let onReveal: () -> Void
    let onHide: () -> Void
    let onCopy: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.label)
                        .font(.headline)
                    Text(entry.environmentVariable)
                        .font(.callout.monospaced())
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    if revealedKey == nil {
                        onReveal()
                    } else {
                        onHide()
                    }
                } label: {
                    Label(revealedKey == nil ? "Reveal" : "Hide", systemImage: revealedKey == nil ? "touchid" : "eye.slash")
                }
                .disabled(isWorking)

                Button {
                    onCopy()
                } label: {
                    Label("Copy Export", systemImage: "doc.on.doc")
                }
                .disabled(isWorking)

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .disabled(isWorking)
            }

            Text(revealedKey ?? entry.maskedValue)
                .font(.system(.body, design: .monospaced, weight: .semibold))
                .textSelection(.enabled)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(entry.exportTemplate)
                .font(.system(.callout, design: .monospaced))
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
        }
        .padding(16)
        .glassEffect(.regular, in: .rect(cornerRadius: 18))
        .buttonStyle(.glass)
        .buttonBorderShape(.capsule)
    }
}
