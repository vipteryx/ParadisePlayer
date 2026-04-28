# TODO

## Phase 2 — Gapless Block Streaming
- [ ] Implement `get_block` API call (`GET /api/get_block?bitrate=4&info=true`)
- [ ] Chain blocks using `end_event` token from each response
- [ ] Feed blocks into `AVQueuePlayer` for gapless playback
- [ ] Sync track metadata using per-song `elapsed` offsets within each block
- [ ] Handle skip via `?event=<token>&elapsed=<seconds>`

## Phase 3 — Song History & Queue
- [ ] Store played tracks in a local history list (in-memory, then persisted)
- [ ] History sheet / slide-up panel from player view
- [ ] Upcoming tracks view (from block metadata)

## Phase 4 — Audio Quality Selection
- [ ] Quality picker: FLAC / AAC 320 / MP3 192
- [ ] Persist quality preference with `@AppStorage`
- [ ] Update `Channel.streamURL` to reflect selected quality

## Phase 5 — CarPlay
- [ ] Apply for `com.apple.developer.carplay-audio` entitlement at developer.apple.com
- [ ] Add `CPTemplateApplicationDelegate` and audio template
- [ ] Now-playing template with channel list
- [ ] Add entitlement to `project.yml` once approved

## Phase 6 — Polish & Edge Cases
- [ ] Handle AVAudioSession interruptions (phone calls, Siri) — pause and resume
- [ ] Handle network loss — show error state, auto-retry on reconnect
- [ ] Add loading indicator while stream buffers
- [ ] Animate track transitions (crossfade album art)
- [ ] Dynamic accent color derived from album art (ColorThief or similar)
- [ ] iPad layout

## Future / Nice to Have
- [ ] Offline caching — pre-buffer blocks to disk
- [ ] Sleep timer
- [ ] Scrobbling (Last.fm / ListenBrainz)
- [ ] Widget (lock screen + home screen) showing current track
- [ ] Share current track sheet
