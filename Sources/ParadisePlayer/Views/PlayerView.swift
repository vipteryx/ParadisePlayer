import SwiftUI

struct PlayerView: View {
    @Environment(PlayerViewModel.self) private var vm

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            albumArt
            trackInfo
            Spacer()
            controls
            channelPicker
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { backgroundLayer }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        ZStack {
            defaultGradient

            if let url = vm.currentTrack?.artURL {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 80)
                            .scaleEffect(1.4)
                            .transition(.opacity.animation(.easeInOut(duration: 0.8)))
                    } else {
                        Color.clear
                    }
                }
                .id(url)
            }

            Color.black.opacity(0.4)
        }
    }

    private var defaultGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.04, blue: 0.18),
                Color(red: 0.04, green: 0.02, blue: 0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Album Art

    private var albumArt: some View {
        Group {
            if let url = vm.currentTrack?.artURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    artPlaceholder
                }
            } else {
                artPlaceholder
            }
        }
        .frame(width: 280, height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.5), radius: 30, y: 12)
        .padding(.bottom, 36)
        .scaleEffect(vm.isPlaying ? 1.0 : 0.92)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: vm.isPlaying)
    }

    private var artPlaceholder: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay {
                Image(systemName: "waveform")
                    .font(.system(size: 56, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.4))
            }
    }

    // MARK: - Track Info

    private var trackInfo: some View {
        VStack(spacing: 6) {
            if let track = vm.currentTrack {
                Text(track.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 40)

                Text(track.artist)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(1)

                Text(track.album)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))
                    .lineLimit(1)
            } else {
                Text("Radio Paradise")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text("Tap play to begin")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(.bottom, 48)
    }

    // MARK: - Controls

    private var controls: some View {
        HStack(spacing: 56) {
            Button {
                // Reserved: skip back / song history
            } label: {
                Image(systemName: "backward.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.3))
            }
            .disabled(true)

            Button {
                vm.togglePlayback()
            } label: {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.12))
                        .frame(width: 76, height: 76)
                    if vm.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: vm.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white)
                            .offset(x: vm.isPlaying ? 0 : 2)
                    }
                }
                .glassEffect(.regular, in: Circle())
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: vm.isPlaying)

            Button {
                vm.skipToNext()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
        }
        .padding(.bottom, 32)
    }

    // MARK: - Channel Picker

    private var channelPicker: some View {
        HStack(spacing: 8) {
            ForEach(Channel.allCases) { channel in
                Button {
                    vm.selectChannel(channel)
                } label: {
                    Text(channel.shortName)
                        .font(.caption.bold())
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .foregroundStyle(vm.selectedChannel == channel ? .black : .white)
                        .background {
                            if vm.selectedChannel == channel {
                                Capsule()
                                    .fill(.white)
                            } else {
                                Capsule()
                                    .fill(.white.opacity(0.08))
                                    .glassEffect(.regular, in: Capsule())
                            }
                        }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: vm.selectedChannel)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 52)
    }
}

#Preview {
    PlayerView()
        .environment(PlayerViewModel())
}
