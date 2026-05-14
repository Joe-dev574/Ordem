import SwiftUI
import SwiftData

@main
struct OrdemApp: App {
    @State private var errorManager = ErrorManager()

    var body: some Scene {
        // Main Application Window
        WindowGroup {
            MainSplitView()
                .frame(minWidth: 1100, minHeight: 700)
                .environment(errorManager)
        }
        .defaultSize(width: 1100, height: 700)
        .windowResizability(.contentSize)
        .modelContainer(PersistenceController.shared.container)

        // Native Settings Window (HIG + macOS Pro Rules)
        Settings {
            SettingsSheet()
                .environment(errorManager)
        }
        .modelContainer(PersistenceController.shared.container)

        // Menu Bar Extra (HIG Compliant)
        MenuBarExtra("Ordem", systemImage: "note.text") {
            MenuBarView()
                .environment(errorManager)
        }
        .menuBarExtraStyle(.window)
    }
}
