import Foundation
import MediaPlayer
import Observation

@MainActor
@Observable
final class PlayerViewModel {
    var currentTrack: Track?
    var selectedChannel: Channel = .main
    var isPlaying = false
    var errorMessage: String?

    private let api = RadioParadiseAPI()
    private let audioPlayer = AudioPlayer()
    private var pollTask: Task<Void, Never>?

    init() {
        setupRemoteCommands()
    }

    func togglePlayback() {
        if isPlaying {
            audioPlayer.pause()
            isPlaying = false
        } else if currentTrack != nil {
            audioPlayer.resume()
            isPlaying = true
        } else {
            startPlaying()
        }
    }

    func selectChannel(_ channel: Channel) {
        selectedChannel = channel
        if isPlaying {
            startPlaying()
        }
    }

    private func startPlaying() {
        audioPlayer.play(channel: selectedChannel)
        isPlaying = true
        startPolling()
    }

    private func startPolling() {
        pollTask?.cancel()
        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.fetchNowPlaying()
                try? await Task.sleep(for: .seconds(10))
            }
        }
    }

    private func fetchNowPlaying() async {
        do {
            let track = try await api.nowPlaying(channel: selectedChannel)
            currentTrack = track
            audioPlayer.updateNowPlaying(track)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func setupRemoteCommands() {
        let cc = MPRemoteCommandCenter.shared()

        cc.playCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.audioPlayer.resume()
                self?.isPlaying = true
            }
            return .success
        }

        cc.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.audioPlayer.pause()
                self?.isPlaying = false
            }
            return .success
        }

        cc.stopCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.audioPlayer.pause()
                self?.isPlaying = false
            }
            return .success
        }

        cc.nextTrackCommand.isEnabled = false
        cc.previousTrackCommand.isEnabled = false
    }
}
