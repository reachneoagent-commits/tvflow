#!/bin/bash
# Builds installer/TVflow.dmg from the release build. Run `flutter build macos --release` first.
set -euo pipefail
cd "$(dirname "$0")/.."
APP=build/macos/Build/Products/Release/TVflow.app
[ -d "$APP" ] || { echo "Build the app first: flutter build macos --release"; exit 1; }
STAGE=$(mktemp -d)
cp -R "$APP" "$STAGE/TVflow.app"
# Synced folders add Finder metadata that breaks the signature; strip it and sign again (ad hoc).
xattr -cr "$STAGE/TVflow.app"
codesign --force --deep --sign - --preserve-metadata=entitlements "$STAGE/TVflow.app" >/dev/null
codesign --verify --deep --strict "$STAGE/TVflow.app"
ln -s /Applications "$STAGE/Applications"
cat > "$STAGE/Install TVflow.command" <<'CMD'
#!/bin/bash
# Double-click to install TVflow into Applications and open it.
cd "$(dirname "$0")"
echo "Installing TVflow…"
osascript -e 'tell application "TVflow" to quit' >/dev/null 2>&1 || true
rm -rf /Applications/TVflow.app
cp -R TVflow.app /Applications/TVflow.app
xattr -dr com.apple.quarantine /Applications/TVflow.app 2>/dev/null || true
open /Applications/TVflow.app
echo "Done. You can close this window and eject the TVflow disk."
CMD
chmod +x "$STAGE/Install TVflow.command"
rm -f installer/TVflow.dmg
hdiutil create -volname "TVflow" -srcfolder "$STAGE" -ov -format UDZO installer/TVflow.dmg >/dev/null

# Zip for handing over: unzip, double-click Install TVflow.command.
ZDIR=$(mktemp -d)/"TVflow for Mac"
mkdir -p "$ZDIR"
cp -R "$STAGE/TVflow.app" "$ZDIR/TVflow.app"
cp "$STAGE/Install TVflow.command" "$ZDIR/"
cat > "$ZDIR/READ ME FIRST.txt" <<'TXT'
TVflow for Mac
===========

Install (takes about 20 seconds)
1. Double-click "Install TVflow.command".
   The first time, macOS may say it can't verify the developer. Then:
   right-click "Install TVflow.command" > Open > Open.
2. TVflow copies itself into Applications and opens.
3. If TVflow itself is blocked on first launch: Applications > right-click TVflow > Open > Open.
   (Or System Settings > Privacy & Security > "Open Anyway".)
   You only have to do this once.

First use
- Click "Add playlist" and enter your IPTV playlist (M3U link, Xtream Codes login or Stalker portal).
- Your playlist and favourites stay on this Mac.

Works on Apple Silicon and Intel Macs, macOS 12 or newer.
You can delete this folder after installing.
TXT
rm -f installer/TVflow-for-Mac.zip
ditto -c -k --keepParent "$ZDIR" installer/TVflow-for-Mac.zip
rm -rf "$(dirname "$ZDIR")"
echo "Created installer/TVflow-for-Mac.zip ($(du -h installer/TVflow-for-Mac.zip | cut -f1))"
rm -rf "$STAGE"
echo "Created installer/TVflow.dmg ($(du -h installer/TVflow.dmg | cut -f1))"
