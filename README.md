# TVflow

**Stream. Discover. Enjoy.** A free, local-first IPTV player for Mac, Windows, Android, Fire TV and Roku.

TVflow plays playlists you add yourself (M3U links, Xtream Codes logins or Stalker portals). It does not include or provide any channels, playlists or content.

## Download

| Platform | Installer |
|---|---|
| macOS (Apple Silicon and Intel) | [DMG](https://github.com/reachneoagent-commits/tvflow/releases/download/v1.0.0/tvflow-1.0.0-macos-universal.dmg) |
| Windows x64 | [Portable zip](https://github.com/reachneoagent-commits/tvflow/releases/download/v1.0.0/tvflow-1.0.0-windows-x64-portable.zip) |
| Android phone, tablet and Android TV | [APK](https://github.com/reachneoagent-commits/tvflow/releases/download/v1.0.0/tvflow-1.0.0-android.apk) |
| Fire TV / Fire Stick | [Zip with install steps](https://github.com/reachneoagent-commits/tvflow/releases/download/v1.0.0/tvflow-1.0.0-firetv.zip) |
| Roku | [Zip with install steps](https://github.com/reachneoagent-commits/tvflow/releases/download/v1.0.0/tvflow-1.0.0-roku.zip) |

Older versions are on the [Releases page](../../releases). Checksums are in `SHA256SUMS.txt` on each release.

The app checks GitHub for a newer version (Settings > About) and tells you when one is available.

## Features

- Live TV with channel guide (EPG), movies and series, favorites and custom groups
- Resume where you stopped, watch history
- Playlists and guide refresh automatically
- Sync favorites, groups and history between your devices through a shared folder
- OpenSubtitles search and auto-skip of intros and credits
- Cast to Chromecast, smart TVs (DLNA), Roku and AirPlay devices
- Built for the remote: full D-pad navigation on TV devices

## Your data

Playlists, logins and history stay on your device. Nothing is uploaded, and there is no account. Add your own playlist the first time you open the app.

## Build from source

Requires [Flutter](https://flutter.dev).

    flutter pub get
    flutter build macos --release      # or: windows, apk

The Roku app is in `roku/` (BrightScript). Brand and UI guidelines are in `brand/`.

## Releases and versions

The version comes from `pubspec.yaml` and is shown in Settings > About. Each release is tagged `vX.Y.Z`.
