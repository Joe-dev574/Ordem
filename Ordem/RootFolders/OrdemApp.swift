import SwiftUI
import SwiftData

@main
struct OrdemApp: App {
    var body: some Scene {
        WindowGroup {
            MainSplitView()
                .frame(minWidth: 1000, minHeight: 650)
        }
        .modelContainer(PersistenceController.shared.container)
    }
}
