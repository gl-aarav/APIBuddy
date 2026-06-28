# API Vault

API Vault is a native macOS app for keeping developer API keys organized,
protected, and easy to export into a terminal session.

The app provides a preset-based vault UI where each preset can hold multiple
keys. Keys can be labeled, assigned an environment variable name, revealed only
after macOS authentication, copied as shell export commands, and deleted when
they are no longer needed.

## Features

- Native SwiftUI macOS interface with a sidebar and detail view.
- Built-in presets grouped by category.
- Multiple saved keys per preset.
- Optional labels and editable environment variable names for each key.
- Key reveal and copy actions gated by macOS authentication.
- Secret storage through the macOS Keychain.
- Lightweight metadata persistence for saved key entries.
- Bundled preset icons with fallback system symbols.
- Release scripts for building a signed app bundle and DMG.

## Requirements

- macOS with support for the configured deployment target.
- Xcode or a compatible Swift toolchain.
- A configured macOS login password for authentication prompts.

## Build and Run

Build the project:

```sh
swift build
```

Run the app:

```sh
swift run APIVault
```

Create a release build:

```sh
swift build -c release
```

## Package

Create an app bundle:

```sh
./create_app.sh
```

Create a DMG:

```sh
./create_dmg.sh
```

The app packaging script defaults to local ad-hoc signing. Set
`CODE_SIGN_IDENTITY` when building with a real signing certificate. Set
`CODE_SIGN_TIMESTAMP=secure` for a timestamped signing pass.

## Storage Model

API Vault separates secret data from display metadata:

- API key values are stored in the macOS Keychain.
- Entry metadata such as labels, preset association, and environment variable
  names is stored locally.
- Revealing or copying a key requires macOS device-owner authentication.
- Export commands are generated on demand and copied to the pasteboard.

## Customization

Preset definitions live in the model layer. Each preset defines its display
name, default environment variable, category, accent, icon asset, fallback
symbol, and placeholder hint.

Bundled icons live in the app resources. If an icon asset is unavailable, the
UI falls back to the preset's system symbol.

## Project Layout

```text
Assets/                 App icon source assets
Sources/APIVault/
  App/                  App entry point and window setup
  Models/               Presets and saved-entry metadata
  Resources/            Bundled UI assets
  Services/             Keychain access and errors
  Stores/               Local metadata persistence
  ViewModels/           App state and user actions
  Views/                SwiftUI screens and controls
Package.swift           Swift package definition
create_app.sh           App bundle packaging script
create_dmg.sh           DMG packaging script
```

## License

This project is licensed under the MIT License.
