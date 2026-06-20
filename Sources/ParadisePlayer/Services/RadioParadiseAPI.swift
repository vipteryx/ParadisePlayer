import Foundation

struct RadioParadiseAPI: Sendable {
    func getBlock(channel: Channel, event: String? = nil) async throws -> Block {
        var components = URLComponents(string: "https://api.radioparadise.com/api/get_block")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "bitrate", value: "4"),
            URLQueryItem(name: "info", value: "true"),
            URLQueryItem(name: "chan", value: "\(channel.rawValue)")
        ]
        if let event {
            queryItems.append(URLQueryItem(name: "event", value: event))
        }
        components.queryItems = queryItems

        guard let url = components.url else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(BlockResponse.self, from: data)
        return response.toBlock()
    }
}

// MARK: - Decodable response types

private struct BlockResponse: Decodable {
    let endEvent: String
    let length: String
    let cue: Int
    let imageBase: String?
    let song: [String: SongData]

    enum CodingKeys: String, CodingKey {
        case endEvent = "end_event"
        case imageBase = "image_base"
        case length, cue, song
    }

    func toBlock() -> Block {
        let sorted = song
            .sorted { (Int($0.key) ?? 0) < (Int($1.key) ?? 0) }
            .map(\.value)

        guard !sorted.isEmpty else {
            return Block(endEvent: endEvent, length: Double(length) ?? 0, songs: [], initialSeek: 0)
        }

        let cueSeconds = Double(cue) / 1000.0
        let artBaseURL = "https:" + (imageBase ?? "//img.radioparadise.com/")

        // Find the song that contains the current cue position
        var currentIdx = 0
        for (i, s) in sorted.enumerated() {
            if Double(s.elapsed) / 1000.0 <= cueSeconds {
                currentIdx = i
            }
        }

        let currentSongStartSeconds = Double(sorted[currentIdx].elapsed) / 1000.0
        let initialSeek = max(0, cueSeconds - currentSongStartSeconds)

        let tracks: [Track] = sorted[currentIdx...].compactMap { s in
            guard let rawURL = s.gaplessURL, let gaplessURL = URL(string: rawURL) else { return nil }
            let artURL = s.cover.flatMap { !$0.isEmpty ? URL(string: artBaseURL + $0) : nil }
            return Track(
                songID: Int(s.songID ?? "0") ?? 0,
                title: s.title ?? "Unknown",
                artist: s.artist ?? "Unknown",
                album: s.album ?? "",
                artURL: artURL,
                duration: TimeInterval(s.duration ?? 0) / 1000.0,
                gaplessURL: gaplessURL,
                event: s.event ?? ""
            )
        }

        return Block(
            endEvent: endEvent,
            length: Double(length) ?? 0,
            songs: tracks,
            initialSeek: initialSeek
        )
    }
}

private struct SongData: Decodable {
    let songID: String?
    let title: String?
    let artist: String?
    let album: String?
    let cover: String?
    let duration: Int?
    let elapsed: Int
    let gaplessURL: String?
    let event: String?

    enum CodingKeys: String, CodingKey {
        case songID = "song_id"
        case title, artist, album, cover, duration, elapsed
        case gaplessURL = "gapless_url"
        case event
    }
}
