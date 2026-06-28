import SwiftUI

enum PresetCategory: String, CaseIterable, Identifiable {
    case ai = "AI"
    case code = "Code"
    case payments = "Payments"
    case custom = "Custom"

    var id: String { rawValue }
}

enum PresetAccent: String, CaseIterable, Identifiable, Sendable {
    case blue
    case green
    case orange
    case purple
    case rose
    case gray

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .blue: .blue
        case .green: .green
        case .orange: .orange
        case .purple: .purple
        case .rose: .pink
        case .gray: .secondary
        }
    }
}

struct Preset: Identifiable, Hashable, Sendable {
    let id: String
    let serviceName: String
    let environmentVariable: String
    let symbolName: String
    let iconAssetName: String
    let accent: PresetAccent
    let category: PresetCategory
    let keyHint: String

    var maskedValue: String { String(repeating: "•", count: 12) }
    var exportTemplate: String { "export \(environmentVariable)=\"\(maskedValue)\"" }

    static let defaults: [Preset] = [
        Preset(
            id: "openai",
            serviceName: "OpenAI",
            environmentVariable: "OPENAI_API_KEY",
            symbolName: "sparkles",
            iconAssetName: "openai",
            accent: .green,
            category: .ai,
            keyHint: "sk-..."
        ),
        Preset(
            id: "anthropic",
            serviceName: "Anthropic",
            environmentVariable: "ANTHROPIC_API_KEY",
            symbolName: "brain.head.profile",
            iconAssetName: "anthropic",
            accent: .orange,
            category: .ai,
            keyHint: "sk-ant-..."
        ),
        Preset(
            id: "openrouter",
            serviceName: "OpenRouter",
            environmentVariable: "OPENROUTER_API_KEY",
            symbolName: "arrow.triangle.branch",
            iconAssetName: "openrouter",
            accent: .purple,
            category: .ai,
            keyHint: "sk-or-..."
        ),
        Preset(
            id: "github",
            serviceName: "GitHub",
            environmentVariable: "GITHUB_TOKEN",
            symbolName: "chevron.left.forwardslash.chevron.right",
            iconAssetName: "github",
            accent: .gray,
            category: .code,
            keyHint: "ghp_..."
        ),
        Preset(
            id: "stripe",
            serviceName: "Stripe",
            environmentVariable: "STRIPE_API_KEY",
            symbolName: "creditcard",
            iconAssetName: "stripe",
            accent: .blue,
            category: .payments,
            keyHint: "sk_live_..."
        ),
        Preset(
            id: "custom",
            serviceName: "Custom",
            environmentVariable: "CUSTOM_API_KEY",
            symbolName: "key",
            iconAssetName: "",
            accent: .rose,
            category: .custom,
            keyHint: "Paste any developer secret"
        )
    ]
}
