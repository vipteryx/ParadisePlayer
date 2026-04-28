# Paradise Player

Native iOS 26 SwiftUI player for Radio Paradise. Liquid Glass UI.

## Architecture

| Layer | File | Responsibility |
|---|---|---|
| Model | `Models/Track.swift` | Immutable song data |
| Model | `Models/Channel.swift` | 4 channels with stream URLs |
| Service | `Services/RadioParadiseAPI.swift` | `now_playing` API calls |
| Service | `Services/AudioPlayer.swift` | AVPlayer + lock screen / remote controls |
| ViewModel | `ViewModels/PlayerViewModel.swift` | `@Observable @MainActor` — owns state, drives polling |
| View | `Views/PlayerView.swift` | Single full-screen player UI |

## Radio Paradise API

| Endpoint | Notes |
|---|---|
| `https://api.radioparadise.com/api/now_playing?chan={0-3}` | Current track, elapsed, duration |
| `https://api.radioparadise.com/api/get_block?bitrate=4&info=true` | Block-based streaming (future) |
| `https://img.radioparadise.com/covers/500/{cover}` | Album art |

Channels: `0` Main · `1` Mellow · `2` Rock · `3` Global. No auth required.

Stream URLs use HTTP — ATS exceptions configured for `stream.radioparadise.com`.

## Build

```sh
xcodegen generate
open ParadisePlayer.xcodeproj
```

Set your team in Signing & Capabilities, then Run.

## Current Phase: Basic Playback

- Direct FLAC stream via AVPlayer
- `now_playing` polled every 10 s
- Lock screen info + remote play/pause
- Channel switching

## Roadmap

1. **Block-based streaming** — gapless playback, frame-accurate metadata via `get_block` API
2. **Song history** — track log with timestamps
3. **Skip / next track** — uses `elapsed` + `end_event` from block API
4. **Quality picker** — FLAC / AAC 320 / MP3
5. **CarPlay** — needs `com.apple.developer.carplay-audio` entitlement (request at developer.apple.com)
6. **Offline caching** — pre-buffer blocks to disk

## Notes

- Minimum deployment: iOS 26 (required for `.glassEffect()`)
- `UIBackgroundModes: audio` is set — playback survives backgrounding
- `@Observable` + `@Environment` pattern throughout (no `ObservableObject`)
- Swift 6 strict concurrency — all UI mutations on `@MainActor`
