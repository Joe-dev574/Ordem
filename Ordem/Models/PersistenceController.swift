import SwiftData
import SwiftUI

@MainActor
final class PersistenceController {
    static let shared = PersistenceController()
    static let preview = PersistenceController(inMemory: true)
    
    let container: ModelContainer
    
    private init(inMemory: Bool = false) {
        let schema = Schema([Folder.self, Note.self, Attachment.self])

        if inMemory {
            do {
                container = try ModelContainer(for: schema, configurations: [
                    ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                ])
            } catch {
                fatalError("Preview container failed: \(error)")
            }
            return
        }

        // Pin to an explicit URL so we can destroy it on schema changes during development.
        let storeURL = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("default.store")
        let config = ModelConfiguration(schema: schema, url: storeURL)

        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            #if DEBUG
            // Schema changed — wipe the old store and start fresh.
            // Before shipping, replace this block with a versioned SchemaMigrationPlan.
            Self.destroyStore(at: storeURL)
            Self.hasSeededData = false
            do {
                container = try ModelContainer(for: schema, configurations: [config])
            } catch {
                fatalError("Container failed after store reset: \(error)")
            }
            #else
            fatalError("ModelContainer failed: \(error)")
            #endif
        }

        if !Self.hasSeededData {
            seedInitialData(context: container.mainContext)
            try? container.mainContext.save()
            Self.hasSeededData = true
        }
    }

    private static func destroyStore(at url: URL) {
        let fm = FileManager.default
        for suffix in ["", "-wal", "-shm"] {
            try? fm.removeItem(at: URL(fileURLWithPath: url.path + suffix))
        }
    }
    
    private static var hasSeededData: Bool {
        get { UserDefaults.standard.bool(forKey: "Ordem.hasSeeded") }
        set { UserDefaults.standard.set(newValue, forKey: "Ordem.hasSeeded") }
    }
    
    private func seedInitialData(context: ModelContext) {
        let work = Folder(name: "Work")
        let personal = Folder(name: "Personal")
        context.insert(work)
        context.insert(personal)
        
        let note1 = Note(title: "Q3 Planning", content: "Discuss Helix integration...")
        let note2 = Note(title: "Grocery List", content: "Milk, eggs, bread")
        note1.folder = work
        note2.folder = personal
        note1.sortIndex = 0
        note2.sortIndex = 1
        
        work.notes.append(note1)
        personal.notes.append(note2)
        
        context.insert(note1)
        context.insert(note2)
    }
}
