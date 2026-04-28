import Foundation
import MediaPlayer
import Observation

@MainActor
@Observable
final class PlayerViewModel {
    var currentTrack: Track?
    var selectedChannel: Channel = .main
    var isPlaying = false
    var isLoading = false
    var errorMessage: String?

    private let api = RadioParadiseAPI()
    private let audioPlayer = AudioPlayer()

    private var songQueue: [Track] = []
    private var currentSongIndex: Int = 0
    private var currentBlock: Block?
    private var isFetchingNextBlock = false
    private var startupTask: Task<Void, Never>?

    init() {
        setupRemoteCommands()
        audioPlayer.onSongFinished = { [weak self] in
            self?.advanceSong()
        }
    }

    // MARK: - Public interface

    func togglePlayback() {
        if isPlaying {
            audioPlayer.pause()
            isPlaying = false
        } else if !songQueue.isEmpty {
            audioPlayer.resume()
            isPlaying = true
        } else {
            launchPlayback()
        }
    }

    func selectChannel(_ channel: Channel) {
        selectedChannel = channel
        launchPlayback()
    }

    func skipToNext() {
        audioPlayer.advanceToNext()
        advanceSong()
    }

    // MARK: - Private

    private func launchPlayback() {
        startupTask?.cancel()
        startupTask = Task { await startPlaying() }
    }

    private func startPlaying() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let block = try await api.getBlock(channel: selectedChannel)
            guard !Task.isCancelled else { return }

            currentBlock = block
            songQueue = block.songs
            currentSongIndex = 0
            currentTrack = block.songs.first

            audioPlayer.loadSongs(block.songs.map(\.gaplessURL), initialSeek: block.initialSeek)
            audioPlayer.play()
            isPlaying = true
            errorMessage = nil

            if let track = currentTrack {
                audioPlayer.updateNowPlaying(track, isPlaying: true)
            }
            checkPrefetch()
        } catch {
            print("startPlaying error: \(error)")
            if !Task.isCancelled {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func advanceSong() {
        currentSongIndex += 1
        guard currentSongIndex < songQueue.count else {
            isPlaying = false
            currentTrack = nil
            return
        }
        currentTrack = songQueue[currentSongIndex]
        audioPlayer.updateNowPlaying(songQueue[currentSongIndex], isPlaying: isPlaying)
        checkPrefetch()
    }

    private func checkPrefetch() {
        let remaining = songQueue.count - currentSongIndex - 1
        if remaining <= 2 && !isFetchingNextBlock {
            Task { await fetchAndEnqueueNextBlock() }
        }
    }

    private func fetchAndEnqueueNextBlock() async {
        guard let block = currentBlock else { return }
        isFetchingNextBlock = true
        defer { isFetchingNextBlock = false }
        do {
            let next = try await api.getBlock(channel: selectedChannel, event: block.endEvent)
            currentBlock = next
            songQueue.append(contentsOf: next.songs)
            audioPlayer.appendSongs(next.songs.map(\.gaplessURL))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Remote commands

    private func setupRemoteCommands() {
        let cc = MPRemoteCommandCenter.shared()

        cc.playCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if !songQueue.isEmpty {
                    audioPlayer.resume()
                    isPlaying = true
                } else {
                    launchPlayback()
                }
            }
            return .success
        }

        cc.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                audioPlayer.pause()
                isPlaying = false
            }
            return .success
        }

        cc.stopCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                audioPlayer.pause()
                isPlaying = false
            }
            return .success
        }

        cc.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.audioPlayer.advanceToNext()
            }
            return .success
        }

        cc.previousTrackCommand.isEnabled = false
    }
}
