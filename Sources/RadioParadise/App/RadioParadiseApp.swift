import SwiftUI

@main
struct RadioParadiseApp: App {
    @State private var player = PlayerViewModel()

    var body: some Scene {
        WindowGroup {
            PlayerView()
                .environment(player)
        }
    }
}
