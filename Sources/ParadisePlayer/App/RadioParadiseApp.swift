import SwiftUI

@main
struct ParadisePlayerApp: App {
    @State private var player = PlayerViewModel()

    var body: some Scene {
        WindowGroup {
            PlayerView()
                .environment(player)
        }
    }
}
