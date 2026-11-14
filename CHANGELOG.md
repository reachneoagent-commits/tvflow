# Changelog

## Unreleased: TV One lite for LG webOS — 2026-10-25

### Added
- `lg-lite/`: a separate ES5 web app for older LG webOS TVs (built for a 2015 webOS 2 model).
  - Live TV with now/next, the per-channel guide, replay, channel zapping and favourites.
  - Movies and series with posters, detail pages, seasons and episodes, resume points and the next-episode countdown.
  - Search, Home, Favourites and Settings.
  - Remote-control navigation.
  - Build and install script with an ES5 syntax check.
  - Mock Xtream server for testing in a desktop browser.
  - Menu across the top. Live TV, Movies and Series each have a search box at the top of their categories column.
  - Several sources: Settings lists them, with Add source, Edit, Save and use, and Delete. The login is checked before saving. Pasting a provider's M3U (get.php) link fills in the server, username and password. Favourites, resume points and history are kept per source; existing ones move to the first source.

### Fixed (LG lite)
- The player no longer says "format not supported" when the provider refuses a stream because the account's one connection is still in use. It asks the server what happened. If the connection is busy it waits and retries for up to a minute, showing "Waiting for your connection to free up". It only blames the format when the server did send the video.
- Clearer messages for missing streams, no internet and server errors.
- While a stream loads, the player shows what it's doing (Connecting, Loading, Buffering) and how many seconds it has taken.
- The first stream starts 0.35 s sooner (the pause is only needed when switching streams).
- Retrying a film after an error resumes from where it stopped.

### Changed (Mac app)
- The main menu is now a bar across the top: Home, Live TV, Movies, Series, Favourites and History, with search, sync status, the source picker and Settings on the right.
- Live TV, Movies and Series each have their own search box, sort and filter buttons at the top of the categories column. When the column is hidden they move to the toolbar.


## 1.1.0 (TV One) — 2026-10-25

Redesign, built on the `tv-one` branch as a separate app so it can be tried next to the old one.

### Changed
- Renamed to TV One (bundle id `app.local.tvOne`, own data folder). The sync file format is unchanged.
- Apple TV-style look: system font, black/grey dark theme and light theme, blue accent, rounded cards, grouped settings.
- Left sidebar (Home, Search, Live TV, Movies, Series, Favourites, History, source picker, Settings) replaces the top bar; it collapses to icons on Live TV and narrow windows. Hidden title bar with the window buttons in the sidebar.
- Live TV: click selects a channel and shows its panel (now, next, replay days, guide); double-click, the play button or Return plays. Arrow keys move the selection. Channels | TV guide switch on the page.
- Movies and Series: "Continue watching" banner with backdrop, Continue watching and Recently added shelves, category counts.
- Player: frosted control panel, LIVE/REPLAY badge, next programme.
- Detail pages, history, search, home and settings restyled.

### Added
- Favourites page with Channels, Movies and Series, each with Reorder.
- Category counts in the category column.

### Fixed
- The "Open the TV guide grid by default" setting now takes effect.


## 1.0.0 — 2026-10-25

First working build.

### Added
- Data layer: Drift/SQLite schema; M3U, Xtream Codes and Stalker importers (parsed off the UI thread); XMLTV guide import with matching and time offset; scheduler for automatic catalogue and guide refresh.
- UI: Home with sources and sync status; TV Live / Series / Movies browsing with category sidebar, search, sort, favourites, replay and language filters; movie and series detail pages; search tab; history; EPG grid and per-channel guide sheet; full settings menu.
- Player (media_kit/libmpv): resume and restart, progress saving, audio/subtitle track selection, external and OpenSubtitles subtitles, speed, aspect, fullscreen, channel zapping, keyboard shortcuts, next-episode countdown, intro/recap/credits skip from TheIntroDB, catch-up replay.
- Favourites, custom groups, hidden items and category ordering.
- Cross-device sync through a shared folder: per-device snapshots, HLC last-writer-wins merge, tombstones, optional AES-GCM passphrase, per-peer error reporting.
- Light, dark and system themes.
- Test fixtures generator and a range-capable local server; dev bridge for UI automation.

### Changed
- A title counts as watched at 95% of its length (no fixed "last 2 minutes" rule), so short videos aren't marked finished early.
- Unencrypted sync keeps plain playlist URLs and server addresses, and drops only usernames, passwords, MACs and URLs that contain credentials.

### Fixed
- OpenSubtitles "Test connection" reported an invalid key as working (the endpoint it used doesn't check keys).
- Hiding every category showed "No movies in this source"; it now says the items are in hidden categories and links to the manager.
- Full screen button tooltip now says "Exit full screen" when in full screen.
- M3U refresh failing with "object is unsendable" (isolate closures captured app state).
- Non-fatal mpv errors (for example on servers without range support) no longer stop playback that is still running.
- A synced source without its login now shows a clear message with an **Edit source** button instead of a network error.
