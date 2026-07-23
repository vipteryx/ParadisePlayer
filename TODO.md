# TODO

## Phase 2 — Gapless Block Streaming ✓
- [x] Implement `get_block` API call (`GET /api/get_block?bitrate=4&info=true`)
- [x] Chain blocks using `end_event` token from each response
- [x] Feed blocks into `AVQueuePlayer` for gapless playback
- [x] Sync track metadata using per-song `gapless_url` + `cue` for initial seek
- [x] Skip forward via `AVQueuePlayer.advanceToNextItem()`
- [x] Pre-fetch next block when queue runs low (≤ 2 songs remaining)
- [x] Loading spinner while first block fetches
- [x] Album art crossfade on track change
- [ ] Verify `duration` field unit (seconds vs ms) against real device playback — lock screen progress bar length depends on this

## Phase 3 — Song History & Queue
- [ ] Store played tracks in a local history list (in-memory, then persisted)
- [ ] History sheet / slide-up panel from player view
- [ ] Upcoming tracks view (from block metadata)

## Phase 4 — Audio Quality Selection
- [ ] Quality picker: FLAC / AAC 320 / MP3 192
- [ ] Persist quality preference with `@AppStorage`
- [ ] Pass correct `bitrate` value to `get_block` (4=FLAC, 3=AAC320, 2=MP3320, 1=MP3192)

## Phase 5 — CarPlay
- [ ] Apply for `com.apple.developer.carplay-audio` entitlement at developer.apple.com
- [ ] Add `CPTemplateApplicationDelegate` and audio template
- [ ] Now-playing template with channel list
- [ ] Add entitlement to `project.yml` once approved

## Phase 6 — Polish & Edge Cases
- [x] Restore one-shot semantics for the initial-seek observer — invalidate `seekObserver` after the first seek via a `Task { @MainActor in ... }` hop
- [x] Add `.initial` to the seek observer options — closes the insert-before-observe race where the item is ready before KVO registration and the initial seek is silently skipped
- [ ] Handle AVAudioSession interruptions (phone calls, Siri) — pause and resume
- [ ] Handle network loss — show error state, auto-retry on reconnect
- [ ] Show `errorMessage` in UI (currently set but not displayed)
- [ ] Animate track transitions (crossfade album art card, not just background)
- [ ] Dynamic accent color derived from album art (ColorThief or similar)
- [ ] iPad layout

## Future / Nice to Have
- [ ] Offline caching — pre-buffer blocks to disk
- [ ] Sleep timer
- [ ] Scrobbling (Last.fm / ListenBrainz)
- [ ] Widget (lock screen + home screen) showing current track
- [ ] Share current track sheet
