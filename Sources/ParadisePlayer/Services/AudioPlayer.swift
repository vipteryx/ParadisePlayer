import AVFoundation
import MediaPlayer
import UIKit

@MainActor
final class AudioPlayer {
    private var player: AVPlayer?
    private(set) var isPlaying = false

    init() {
        configureAudioSession()
    }

    func play(channel: Channel) {
        player?.pause()
        player = AVPlayer(url: channel.streamURL)
        player?.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
        updatePlaybackRate(0)
    }

    func resume() {
        player?.play()
        isPlaying = true
        updatePlaybackRate(1)
    }

    func updateNowPlaying(_ track: Track) {
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artist,
            MPMediaItemPropertyAlbumTitle: track.album,
            MPMediaItemPropertyPlaybackDuration: track.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: track.elapsed,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
            MPNowPlayingInfoPropertyIsLiveStream: true
        ]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info

        if let artURL = track.artURL {
            Task { @MainActor in
                guard let (data, _) = try? await URLSession.shared.data(from: artURL),
                      let image = UIImage(data: data) else { return }
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                var updated = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
                updated[MPMediaItemPropertyArtwork] = artwork
                MPNowPlayingInfoCenter.default().nowPlayingInfo = updated
            }
        }
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
