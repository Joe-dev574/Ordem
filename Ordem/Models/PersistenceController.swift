import SwiftData
import SwiftUI

@MainActor
final class PersistenceController {
    static let shared = PersistenceController()
    static let preview = PersistenceController(inMemory: true)
    
    let container: ModelContainer
    
    private init(inMemory: Bool = false) {
        let schema = Schema([Folder.self, Note.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        
        do {
            container = try ModelContainer(for: schema, configurations: [config])
            
            if !inMemory && !Self.hasSeededData {
                let context = container.mainContext
                seedInitialData(context: context)
                try context.save()
                Self.hasSeededData = true
            }
        } catch {
            fatalError("ModelContainer failed: \(error)")
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
