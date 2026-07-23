import AVFoundation
import MediaPlayer
import UIKit

@MainActor
final class AudioPlayer {
    private var queuePlayer = AVQueuePlayer()
    private var itemObservers: [Any] = []
    private var artTask: Task<Void, Never>?
    private var seekObserver: NSKeyValueObservation?

    var onSongFinished: (() -> Void)?

    init() {
        configureAudioSession()
    }

    // MARK: - Queue management

    func loadSongs(_ urls: [URL], initialSeek: TimeInterval = 0) {
        clearItemObservers()
        seekObserver?.invalidate()
        seekObserver = nil
        queuePlayer.removeAllItems()
        artTask?.cancel()

        guard !urls.isEmpty else { return }

        for (i, url) in urls.enumerated() {
            let item = AVPlayerItem(url: url)
            queuePlayer.insert(item, after: nil)
            if i == 0 && initialSeek > 0 {
                seekObserver = item.observe(\.status, options: [.new, .initial]) { [weak self, weak item] _, _ in
                    guard let item, item.status == .readyToPlay else { return }
                    item.seek(to: CMTime(seconds: initialSeek, preferredTimescale: 1000), completionHandler: nil)
                    Task { @MainActor [weak self] in
                        self?.seekObserver?.invalidate()
                        self?.seekObserver = nil
                    }
                }
            }
            observeFinish(of: item)
        }
    }

    func appendSongs(_ urls: [URL]) {
        for url in urls {
            let item = AVPlayerItem(url: url)
            queuePlayer.insert(item, after: nil)
            observeFinish(of: item)
        }
    }

    // MARK: - Playback

    func play() {
        queuePlayer.play()
    }

    func pause() {
        queuePlayer.pause()
        updatePlaybackRate(0)
    }

    func resume() {
        queuePlayer.play()
        updatePlaybackRate(1)
    }

    func advanceToNext() {
        queuePlayer.advanceToNextItem()
    }

    // MARK: - Now Playing

    func updateNowPlaying(_ track: Track, isPlaying: Bool) {
        let info: [String: Any] = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artist,
            MPMediaItemPropertyAlbumTitle: track.album,
            MPMediaItemPropertyPlaybackDuration: track.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: 0,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info

        guard let artURL = track.artURL else { return }
        artTask?.cancel()
        artTask = Task {
            guard let (data, _) = try? await URLSession.shared.data(from: artURL),
                  !Task.isCancelled else { return }
            await MainActor.run {
                guard let image = UIImage(data: data) else { return }
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                var updated = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
                updated[MPMediaItemPropertyArtwork] = artwork
                MPNowPlayingInfoCenter.default().nowPlayingInfo = updated
            }
        }
    }

    // MARK: - Private

    private func observeFinish(of item: AVPlayerItem) {
        let token = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.onSongFinished?()
            }
        }
        itemObservers.append(token)
    }

    private func clearItemObservers() {
        itemObservers.forEach { NotificationCenter.default.removeObserver($0) }
        itemObservers = []
    }

    private func updatePlaybackRate(_ rate: Float) {
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        info[MPNowPlayingInfoPropertyPlaybackRate] = rate
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }
}
