# Radio Paradise

An alternative iOS player for [Radio Paradise](https://radioparadise.com), built with SwiftUI and the iOS 26 Liquid Glass design language.

## Features

- Stream all four Radio Paradise channels (Main, Mellow, Rock, Global)
- Lock screen now-playing card with album art
- Control Center and AirPods remote controls
- Liquid Glass UI

## Requirements

- Xcode 16.4+
- iOS 26+ device or simulator
- [xcodegen](https://github.com/yonaskolb/XcodeGen)

## Getting Started

```sh
brew install xcodegen   # if needed
xcodegen generate
open RadioParadise.xcodeproj
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

- [ ] Gapless block-based streaming
- [ ] Song history
- [ ] Skip / next track
- [ ] Audio quality selection
- [ ] CarPlay support

## License

MIT

---

## Changelog

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
