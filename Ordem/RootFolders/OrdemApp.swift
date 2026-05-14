import SwiftUI
import SwiftData

@main
struct OrdemApp: App {
    @State private var errorManager = ErrorManager()

    var body: some Scene {
        WindowGroup {
            MainSplitView()
                .frame(minWidth: 1000, minHeight: 650)
                .environment(errorManager)
        }
        .modelContainer(PersistenceController.shared.container)
    }
}
