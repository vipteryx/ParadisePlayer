# Paradise Player

An alternative iOS player for [Radio Paradise](https://radioparadise.com), built with SwiftUI and the iOS 26 Liquid Glass design language.

## Features

- Gapless playback via block-based streaming (one FLAC file per song, queued in `AVQueuePlayer`)
- Joins the live stream at the correct position — no starting songs from the beginning
- Skip to next song — button in app and lock screen next-track control
- Stream all four Radio Paradise channels (Main, Mellow, Rock, Global)
- Lock screen now-playing card with album art, title, artist, duration
- Control Center and AirPods remote controls (play, pause, next)
- Liquid Glass UI

## Requirements

- Xcode 16.4+
- iOS 26+ device or simulator
- [xcodegen](https://github.com/yonaskolb/XcodeGen)

## Getting Started

```sh
brew install xcodegen   # if needed
xcodegen generate
open ParadisePlayer.xcodeproj
```

Set your development team in **Signing & Capabilities**, then build and run.

## Channels

| Channel | Stream |
|---|---|
| Main Mix | FLAC lossless |
| Mellow Mix | FLAC lossless |
| Rock Mix | FLAC lossless |
| Global Mix | FLAC lossless |

## Roadmap

- [x] Gapless block-based streaming
- [x] Skip / next track
- [ ] Song history
- [ ] Audio quality selection
- [ ] CarPlay support

## License

MIT

---

## Changelog

### 2026-04-28 — Bug fixes & stabilisation

- `song_id` decoded as `String` (block API returns string, not int like `now_playing`)
- Album art URL fixed — `cover` field is a full path (`covers/l/12345.jpg`), base URL decoded from `image_base` field
- `imageBase` made optional in decoder — missing field no longer silently kills playback
- Empty song list guard added in `toBlock()` — prevents index crash if block has no songs
- `components.url` force-unwrap replaced with `guard let` + `throw URLError(.badURL)`
- Skip double-advance fixed — manual skip and natural end now use separate code paths
- `checkPrefetch()` called immediately after first block loads — avoids empty queue on first skip
- `isLoading` state added — play button shows spinner while block is fetching
- `MPMediaItemArtwork` crash fixed (iOS 26 `dispatch_assert_queue`) — UIImage now created inside `MainActor.run { }` rather than in a lazy request handler
- Background art crossfade — new track fades in over gradient; no white flash between songs

### 2026-04-28 — Gapless block-based streaming

- Replaced `now_playing` polling with `get_block` API (`RadioParadiseAPI.getBlock`)
- Each block contains 4–5 songs, each with its own `gapless_url` (individual FLAC per song)
- `AVPlayer` replaced with `AVQueuePlayer` — songs queued as separate `AVPlayerItem`s for true gapless playback
- First song in each block is seeked to the live stream's current position (`cue` field, ms → seconds)
- `PlayerViewModel` maintains a flat `[Track]` queue; pre-fetches the next block (via `end_event`) when 2 songs remain
- Skip forward wired up: `AVQueuePlayer.advanceToNextItem()` + lock screen next-track button
- `Block` model added; `Track` updated — replaced `elapsed` with `gaplessURL` + `event`
- Lock screen progress bar now works (duration reported per song, elapsed reset to 0 on track change)

### 2026-04-28 — Technical cleanup

- `NowPlayingResponse`: renamed properties to camelCase, added `CodingKeys` mapping from `song_id`
- `AudioPlayer`: removed redundant `isPlaying` state; `updateNowPlaying` now takes explicit `isPlaying` parameter
- `AudioPlayer`: art-loading `Task` is now stored and cancelled before each new fetch, preventing concurrent image requests
- `PlayerViewModel`: polling stops when paused and restarts on resume, for both `togglePlayback()` and lock screen remote commands

### 2026-04-28 — Initial project

- Scaffolded iOS 26 SwiftUI project with xcodegen
- `Channel` model — 4 channels (Main, Mellow, Rock, Global) with FLAC stream URLs
- `Track` model — immutable, `Sendable` song data struct
- `RadioParadiseAPI` — async `now_playing` endpoint, decodes track + album art URL
- `AudioPlayer` — `AVPlayer` wrapper with `AVAudioSession` background audio config, `MPNowPlayingInfoCenter` lock screen card (title, artist, album, art), `MPRemoteCommandCenter` play/pause/stop
- `PlayerViewModel` — `@Observable @MainActor`, owns audio + API, 10-second polling loop, channel switching
- `PlayerView` — full-screen Liquid Glass UI: blurred album art background, album art card (scales on pause), track info, glass play/pause button, glass channel picker
- ATS exceptions configured for `stream.radioparadise.com` (HTTP streams)
- `UIBackgroundModes: audio` set in `Info.plist`
- Git repository initialised
