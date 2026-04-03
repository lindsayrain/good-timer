#!/bin/bash
# package.sh — Build GoodTimer and produce a versioned DMG installer
# Usage: ./package.sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

APP_NAME="GoodTimer"
BUNDLE_NAME="${APP_NAME}.app"
INFO_PLIST="$SCRIPT_DIR/Info.plist"
ICNS="$SCRIPT_DIR/AppIcon.icns"
BUILD_DIR="$SCRIPT_DIR/.build/release"

# --- Read version from Info.plist (single source of truth) ---
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFO_PLIST")
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
DMG_PATH="$SCRIPT_DIR/$DMG_NAME"

echo "▶ Building $APP_NAME v$VERSION"
echo ""

# --- Step 1: Build release binary ---
echo "[1/4] Building release binary..."
swift build -c release 2>&1
BINARY="$BUILD_DIR/$APP_NAME"
if [ ! -f "$BINARY" ]; then
    echo "❌ Binary not found at $BINARY"
    exit 1
fi
echo "✓ Binary ready"

# --- Step 2: Generate icon if needed ---
if [ ! -f "$ICNS" ]; then
    echo ""
    echo "[2/4] Generating app icon..."
    swift "$SCRIPT_DIR/generate-icon.swift"
    iconutil -c icns "$SCRIPT_DIR/AppIcon.iconset" -o "$ICNS"
    echo "✓ Icon generated"
else
    echo ""
    echo "[2/4] Icon exists, skipping generation"
fi

# --- Step 3: Assemble .app bundle ---
echo ""
echo "[3/4] Assembling .app bundle..."
STAGING="$SCRIPT_DIR/.staging"
APP_BUNDLE="$STAGING/$BUNDLE_NAME"
rm -rf "$STAGING"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BINARY"      "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp "$INFO_PLIST"  "$APP_BUNDLE/Contents/Info.plist"
cp "$ICNS"        "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# Applications symlink inside staging (for drag-to-install)
ln -s /Applications "$STAGING/Applications"

echo "✓ Bundle assembled"

# --- Step 4: Create DMG ---
echo ""
echo "[4/4] Creating $DMG_NAME..."

# Remove previous DMG of same version
if [ -f "$DMG_PATH" ]; then
    rm -f "$DMG_PATH"
    echo "  (removed previous $DMG_NAME)"
fi

hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$STAGING" \
    -ov \
    -format UDZO \
    "$DMG_PATH" 2>&1

rm -rf "$STAGING"

echo "✓ $DMG_NAME created"
echo ""
echo "══════════════════════════════════════════"
echo "  Done! $DMG_NAME"
echo "  Share this file or open it to install."
echo "══════════════════════════════════════════"
