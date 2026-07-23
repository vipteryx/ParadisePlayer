# Paradise Player

Native iOS 26 SwiftUI player for Radio Paradise. Liquid Glass UI.

## Architecture

| Layer | File | Responsibility |
|---|---|---|
| Model | `Models/Track.swift` | Immutable song data — title, artist, art URL, `gaplessURL`, `event` |
| Model | `Models/Block.swift` | A block from the API — `endEvent`, song list, `initialSeek` offset |
| Model | `Models/Channel.swift` | 4 channels (Main / Mellow / Rock / Global) |
| Service | `Services/RadioParadiseAPI.swift` | `get_block` API — fetches and decodes blocks into `[Track]` |
| Service | `Services/AudioPlayer.swift` | `AVQueuePlayer` + lock screen (`MPNowPlayingInfoCenter`) + remote controls |
| ViewModel | `ViewModels/PlayerViewModel.swift` | `@Observable @MainActor` — owns block queue, drives pre-fetch, no polling |
| View | `Views/PlayerView.swift` | Single full-screen Liquid Glass player UI |

## Radio Paradise API

| Endpoint | Notes |
|---|---|
| `https://api.radioparadise.com/api/get_block?bitrate=4&info=true&chan={0-3}` | Primary — returns block with per-song `gapless_url`, `cue`, `end_event` |
| `https://api.radioparadise.com/api/get_block?bitrate=4&info=true&chan={0-3}&event={end_event}` | Fetch next block in sequence |
| `https://img.radioparadise.com/{cover}` | Album art — `cover` field is a full path e.g. `covers/l/12345.jpg`; base from `image_base` field |

Channels: `0` Main · `1` Mellow · `2` Rock · `3` Global. No auth required.

### Block API field notes
- `cue` — current listener position within the block, in **milliseconds**
- `elapsed` per song — position of that song's start within the block, in **milliseconds**
- `song_id` per song — returned as **String** (not Int, unlike `now_playing`)
- `image_base` — protocol-relative e.g. `"//img.radioparadise.com/"`, prepend `"https:"`
- `duration` per song — **milliseconds** in the block API (verified); divide by 1000 for seconds

## Playback model

1. `getBlock(channel:)` — fetch first block; `cue` tells us where the live stream is
2. Find song containing `cue`; seek that song's `gaplessURL` to `(cue − song.elapsed) / 1000` seconds
3. Queue remaining songs as `AVPlayerItem`s in `AVQueuePlayer`
4. When 2 songs remain in queue, pre-fetch next block via `end_event` and `appendSongs`
5. Natural song end → `AVPlayerItemDidPlayToEndTime` → `advanceSong()`
6. Manual skip → `queuePlayer.advanceToNextItem()` + direct `advanceSong()` call (separate paths to avoid double-fire)

## Build

```sh
xcodegen generate   # required after adding new .swift files
open ParadisePlayer.xcodeproj
```

Set your team in Signing & Capabilities, then Run.

## Current Phase: Gapless Block Streaming

- `AVQueuePlayer` with one `AVPlayerItem` per song (`gapless_url`)
- Joins live stream at correct position via `cue` + `elapsed` offsets
- Next block pre-fetched when 2 songs remain
- Skip forward — button + lock screen next-track
- Lock screen: title, artist, album, art, duration, playback rate
- Channel switching

## Roadmap

1. ~~**Block-based streaming**~~ — done
2. **Song history** — track log with timestamps
3. **Quality picker** — FLAC / AAC 320 / MP3 (block API supports `bitrate` param)
4. **CarPlay** — needs `com.apple.developer.carplay-audio` entitlement
5. **Offline caching** — pre-buffer blocks to disk

## Working Rules

After every meaningful change:
1. Add a dated entry to the `## Changelog` section in `README.md`
2. Update `TODO.md` — check off completed items, add any new ones

Do this before committing.

## Notes

- Minimum deployment: iOS 26 (required for `.glassEffect()`)
- `UIBackgroundModes: audio` is set — playback survives backgrounding
- `@Observable` + `@Environment` pattern throughout (no `ObservableObject`)
- Swift 6 strict concurrency — all UI mutations on `@MainActor`
- `MPMediaItemArtwork`: create the `UIImage` on `@MainActor`, but form the artwork's request handler in a `nonisolated` context (e.g. `AudioPlayer.makeArtwork`). MediaPlayer calls that handler on its own `MPNowPlayingInfoCenter/accessQueue`; a `@MainActor`-isolated closure trips the Swift 6 executor check (`swift_task_isCurrentExecutor` → `dispatch_assert_queue`) and traps with `EXC_BREAKPOINT`
- SourceKit shows false-positive "Cannot find type X" errors without an xcodeproj — run `xcodegen generate` to clear them
- ATS exceptions only needed for `stream.radioparadise.com` (HTTP); all other RP domains are HTTPS
