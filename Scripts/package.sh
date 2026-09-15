#!/bin/zsh
# Builds a shareable DMG: universal app (Apple silicon + Intel), icon, signature, drag-to-Applications.
#
#   Scripts/package.sh                       # ad-hoc signed: recipients approve it once in System Settings
#   SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
#   NOTARY_PROFILE=aula-notary Scripts/package.sh   # signed + notarized: opens without warnings
#
# One-time setup for notarization (Apple Developer Program membership required):
#   xcrun notarytool store-credentials aula-notary --apple-id you@example.com --team-id TEAMID
set -euo pipefail
cd "${0:A:h}/.."

APP_NAME="AULA Studio"
PRODUCT="AULAStudio"
BUNDLE_ID="${BUNDLE_ID:-app.aulastudio.AULAStudio}"
SIGN_IDENTITY="${SIGN_IDENTITY:--}"
NOTARY_PROFILE="${NOTARY_PROFILE:-}"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' Support/Info.plist)"
DIST="dist"
APP="$DIST/$APP_NAME.app"
DMG="$DIST/AULA-Studio-$VERSION.dmg"

# Command Line Tools without Xcode: build against the macOS 26 SDK (see Makefile).
if [[ "$(xcode-select -p)" == *CommandLineTools* && -d /Library/Developer/CommandLineTools/SDKs/MacOSX26.sdk ]]; then
  export SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX26.sdk
fi

step() { print -P "%F{cyan}==>%f $1"; }

step "Building universal release ($VERSION)"
swift build -c release --arch arm64 --arch x86_64 --product "$PRODUCT"
BIN_DIR="$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)"

step "Assembling $APP"
rm -rf "$DIST"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/$PRODUCT" "$APP/Contents/MacOS/$PRODUCT"
sed -e "s/\$(BUNDLE_ID)/$BUNDLE_ID/" Support/Info.plist > "$APP/Contents/Info.plist"
cp Support/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
for bundle in "$BIN_DIR"/*.bundle(N); do
  cp -R "$bundle" "$APP/Contents/Resources/"
done
lipo -info "$APP/Contents/MacOS/$PRODUCT"

step "Signing ($SIGN_IDENTITY)"
if [[ "$SIGN_IDENTITY" == "-" ]]; then
  codesign --force --sign - "$APP"
else
  codesign --force --options runtime --timestamp --sign "$SIGN_IDENTITY" "$APP"
fi
codesign --verify --strict --verbose=1 "$APP"

step "Creating $DMG"
STAGE="$DIST/stage"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
if [[ "$SIGN_IDENTITY" == "-" ]]; then
  cp "Support/How to open AULA Studio.txt" "$STAGE/"
fi
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGE" -ov -format UDZO -fs HFS+ "$DMG" >/dev/null
rm -rf "$STAGE"

if [[ "$SIGN_IDENTITY" != "-" ]]; then
  codesign --force --timestamp --sign "$SIGN_IDENTITY" "$DMG"
fi

if [[ -n "$NOTARY_PROFILE" ]]; then
  step "Notarizing (this can take a few minutes)"
  xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
  xcrun stapler staple "$DMG"
fi

step "Done"
ls -lh "$DMG"
shasum -a 256 "$DMG"
