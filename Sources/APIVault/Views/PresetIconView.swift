import AppKit
import SwiftUI

struct PresetIconView: View {
    let preset: Preset
    let size: CGFloat

    var body: some View {
        Group {
            if let image = PresetIconCache.shared.image(named: preset.iconAssetName) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: preset.symbolName)
                    .font(.system(size: size * 0.82, weight: .semibold))
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(preset.accent.color)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

@MainActor
final class PresetIconCache {
    static let shared = PresetIconCache()

    private var cachedImages: [String: NSImage] = [:]

    private init() { }

    func image(named name: String) -> NSImage? {
        if let cachedImage = cachedImages[name] {
            return cachedImage
        }

        guard
            let url = Bundle.module.url(
                forResource: name,
                withExtension: "svg"
            ),
            let image = NSImage(contentsOf: url)
        else {
            return nil
        }

        cachedImages[name] = image
        return image
    }
}
