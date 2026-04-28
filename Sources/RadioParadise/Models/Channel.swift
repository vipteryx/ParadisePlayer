import Foundation

enum Channel: Int, CaseIterable, Identifiable, Sendable {
    case main = 0
    case mellow = 1
    case rock = 2
    case global = 3

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .main:   "Main Mix"
        case .mellow: "Mellow Mix"
        case .rock:   "Rock Mix"
        case .global: "Global Mix"
        }
    }

    var shortName: String {
        switch self {
        case .main:   "Main"
        case .mellow: "Mellow"
        case .rock:   "Rock"
        case .global: "Global"
        }
    }

    var streamURL: URL {
        let path: String
        switch self {
        case .main:   path = "flac"
        case .mellow: path = "mellow-flac"
        case .rock:   path = "rock-flac"
        case .global: path = "global-flac"
        }
        return URL(string: "http://stream.radioparadise.com/\(path)")!
    }
}
