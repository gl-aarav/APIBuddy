#!/bin/zsh
set -euo pipefail

APP_NAME="API Vault"
EXECUTABLE_NAME="APIVault"
BUNDLE_ID="com.aaravgoyal.apivault"
SIGNING_IDENTITY="${CODE_SIGN_IDENTITY:--}"
CODE_SIGN_TIMESTAMP="${CODE_SIGN_TIMESTAMP:-none}"

if [[ "$SIGNING_IDENTITY" == "PLACEHOLDER" || "$SIGNING_IDENTITY" == "Developer ID Application: Your Name" ]]; then
  echo "Error: Set CODE_SIGN_IDENTITY to a real signing identity, or leave it unset for ad-hoc signing."
  exit 1
fi

case "$CODE_SIGN_TIMESTAMP" in
  none)
    TIMESTAMP_ARGS=(--timestamp=none)
    ;;
  secure)
    TIMESTAMP_ARGS=(--timestamp)
    ;;
  *)
    echo "Error: CODE_SIGN_TIMESTAMP must be 'none' or 'secure'."
    exit 1
    ;;
esac

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$ROOT_DIR/build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
ICON_SOURCE="$ROOT_DIR/Assets/AppIcon.icon"
ICON_NAME="AppIcon"

cd "$ROOT_DIR"

swift build -c release

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp -X "$ROOT_DIR/.build/release/$EXECUTABLE_NAME" "$MACOS_DIR/$EXECUTABLE_NAME"
chmod 755 "$MACOS_DIR/$EXECUTABLE_NAME"

if [[ -d "$ROOT_DIR/.build/release/APIVault_APIVault.bundle" ]]; then
  cp -R -X "$ROOT_DIR/.build/release/APIVault_APIVault.bundle" "$RESOURCES_DIR/"
fi

if [[ ! -d "$ICON_SOURCE" ]]; then
  echo "Error: Missing native app icon: $ICON_SOURCE"
  exit 1
fi

xcrun actool "$ICON_SOURCE" \
  --compile "$RESOURCES_DIR" \
  --app-icon "$ICON_NAME" \
  --enable-on-demand-resources NO \
  --development-region en \
  --target-device mac \
  --platform macosx \
  --include-all-app-icons \
  --minimum-deployment-target 26.0 \
  --output-partial-info-plist "$BUILD_DIR/icon-partial.plist" >/dev/null

cat > "$CONTENTS_DIR/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleExecutable</key>
    <string>$EXECUTABLE_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleIconFile</key>
    <string>$ICON_NAME</string>
    <key>CFBundleIconName</key>
    <string>$ICON_NAME</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>26.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
PLIST

printf "APPL????" > "$CONTENTS_DIR/PkgInfo"
xattr -cr "$APP_DIR"

if [[ "$SIGNING_IDENTITY" == "-" ]]; then
  echo "Using ad-hoc code signing. Set CODE_SIGN_IDENTITY for Developer ID or CI signing."
elif ! /usr/bin/security find-identity -v -p codesigning | /usr/bin/grep -Fq "$SIGNING_IDENTITY"; then
  echo "Error: Code signing identity not found: $SIGNING_IDENTITY"
  echo "Run 'security find-identity -v -p codesigning' or set CODE_SIGN_IDENTITY."
  exit 1
else
  echo "Using code signing identity: $SIGNING_IDENTITY"
fi

/usr/bin/codesign --force --deep --options runtime "${TIMESTAMP_ARGS[@]}" --sign "$SIGNING_IDENTITY" "$APP_DIR"
/usr/bin/codesign --verify --deep --strict --verbose=2 "$APP_DIR"

LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
if [[ -x "$LSREGISTER" ]]; then
  "$LSREGISTER" -f "$APP_DIR"
fi

if command -v mdimport >/dev/null 2>&1; then
  mdimport "$APP_DIR"
fi

touch "$APP_DIR"

echo "Created signed app: $APP_DIR"
