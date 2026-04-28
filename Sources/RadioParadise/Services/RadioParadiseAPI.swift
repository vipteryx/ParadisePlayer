import Foundation

struct RadioParadiseAPI: Sendable {
    fileprivate static let artBase = "https://img.radioparadise.com/covers/500/"
    private static let session = URLSession.shared

    func nowPlaying(channel: Channel) async throws -> Track {
        let url = URL(string: "https://api.radioparadise.com/api/now_playing?chan=\(channel.rawValue)")!
        let (data, _) = try await Self.session.data(from: url)
        let response = try JSONDecoder().decode(NowPlayingResponse.self, from: data)
        return response.toTrack()
    }
}

private struct NowPlayingResponse: Decodable {
    let song_id: Int?
    let title: String?
    let artist: String?
    let album: String?
    let cover: String?
    let duration: Int?
    let elapsed: Int?

    func toTrack() -> Track {
        var artURL: URL?
        if let cover, !cover.isEmpty {
            artURL = URL(string: RadioParadiseAPI.artBase + cover)
        }
        return Track(
            songID: song_id ?? 0,
            title: title ?? "Unknown",
            artist: artist ?? "Unknown",
            album: album ?? "",
            artURL: artURL,
            duration: TimeInterval(duration ?? 0),
            elapsed: TimeInterval(elapsed ?? 0)
        )
    }
}
