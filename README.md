# API Vault

API Vault is a native macOS app for storing developer API keys in the system
Keychain and quickly copying shell export commands for local development.

It ships with presets for common services such as OpenAI, Anthropic,
OpenRouter, GitHub, Stripe, and a custom key slot. Each saved secret is stored
as a protected Keychain item and requires user presence before it can be
revealed or copied.

## Features

- Native SwiftUI macOS interface with a split-view preset browser.
- Preset API key entries grouped by AI, code, payments, and custom categories.
- Bundled service icons with SF Symbol fallback icons.
- Secure save, replace, reveal, hide, and delete actions for each key.
- Keychain storage backed by `Security.framework`.
- User-presence protection through macOS authentication before secret access.
- Search across service names and environment variable names.
- One-click copy for shell commands such as:

  ```sh
  export OPENAI_API_KEY="..."
  ```

## Requirements

- macOS 26 or later.
- Xcode 26 or a Swift 6.2 toolchain.
- A Mac with a configured device password. Touch ID is supported when available.

The project is a Swift Package Manager executable target and links against
AppKit and Security.

## Build and Run

Clone the repository, then build from the project root:

```sh
swift build
```

Run the app directly with SwiftPM:

```sh
swift run APIVault
```

For a release build:

```sh
swift build -c release
```

## Package the App

Create a signed `.app` bundle:

```sh
./create_app.sh
```

The app bundle is written to:

```text
build/API Vault.app
```

Create a DMG installer:

```sh
./create_dmg.sh
```

The disk image is written to:

```text
build/API Vault.dmg
```

By default, `create_app.sh` uses ad-hoc signing so local builds work without an
Apple Developer certificate. For Developer ID or CI signing, set
`CODE_SIGN_IDENTITY`:

```sh
CODE_SIGN_IDENTITY="Developer ID Application: Example" ./create_app.sh
```

For a notarization-ready Developer ID build, enable a secure timestamp:

```sh
CODE_SIGN_IDENTITY="Developer ID Application: Example" CODE_SIGN_TIMESTAMP=secure ./create_app.sh
```

## How Secrets Are Stored

API Vault stores secrets as generic password items in the macOS Keychain using:

- Service: `com.aaravgoyal.APIVault.api-key`
- Account: the preset environment variable, such as `OPENAI_API_KEY`
- Accessibility: `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`
- Access control: `.userPresence`

This means stored keys remain local to the current Mac and require macOS
authentication when revealed or copied.

## Adding Presets

Default presets live in:

```text
Sources/APIVault/Models/Preset.swift
```

Add a new `Preset` entry to `Preset.defaults` with a stable `id`, display name,
environment variable, SF Symbol name, bundled icon asset name, accent color,
category, and key hint.

Bundled preset icons live in:

```text
Sources/APIVault/Resources/Icons/
```

If an SVG icon cannot be loaded, the app falls back to the preset's SF Symbol.

## Project Structure

```text
Sources/APIVault/
  App/             App entry point and window configuration
  Models/          Preset definitions and categories
  Resources/       Bundled preset icon assets
  Services/        Keychain integration and error mapping
  ViewModels/      App state and keychain actions
  Views/           SwiftUI interface
Package.swift      SwiftPM package definition
create_app.sh      Release app bundle script
create_dmg.sh      DMG packaging script
```

## License

This project is licensed under the MIT License. See `LICENSE` for details.
