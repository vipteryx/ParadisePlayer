import Foundation

struct Track: Equatable, Sendable {
    let songID: Int
    let title: String
    let artist: String
    let album: String
    let artURL: URL?
    let duration: TimeInterval
    let elapsed: TimeInterval
}
