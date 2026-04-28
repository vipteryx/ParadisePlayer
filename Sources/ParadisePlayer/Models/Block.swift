import Foundation

struct Block: Sendable {
    let endEvent: String
    let length: TimeInterval
    let songs: [Track]
    let initialSeek: TimeInterval  // seconds into songs[0] where live stream currently is
}
