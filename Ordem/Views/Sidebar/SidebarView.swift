import SwiftUI
import SwiftData

struct SidebarView: View {
    @Binding var sidebarSelection: SidebarSelection
    let folders: [Folder]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        List(selection: $sidebarSelection) {
            Section("Library") {
                Text("All Notes")
                    .tag(SidebarSelection.allNotes)
                    .dropDestination(for: String.self) { ids, _ in
                        handleDrop(ids, to: nil)
                    }
            }
            
            Section("Folders") {
                ForEach(folders) { folder in
                    Label(folder.name, systemImage: "folder")
                        .font(.callout)
                        .tag(SidebarSelection.folder(folder))
                        .dropDestination(for: String.self) { ids, _ in
                            handleDrop(ids, to: folder)
                        }
                }
            }
        }
        .listStyle(.sidebar)
    }
    
    private func handleDrop(_ ids: [String], to targetFolder: Folder?) {
        print("🔥 DROP RECEIVED - \(ids.count) items to \(targetFolder?.name ?? "All Notes")")
        
        for idString in ids {
            guard let uuid = UUID(uuidString: idString) else { continue }
            let descriptor = FetchDescriptor<Note>(predicate: #Predicate { $0.id == uuid })
            if let note = try? context.fetch(descriptor).first {
                print("   ✅ Found note: \(note.title)")
                if note.folder?.persistentModelID != targetFolder?.persistentModelID {
                    note.folder = targetFolder
                    note.lastModified = .now
                    try? context.save()
                    print("   ✅ Moved and saved")
                }
            }
        }
    }
}
