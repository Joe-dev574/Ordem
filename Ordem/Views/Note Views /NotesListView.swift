import SwiftUI
import SwiftData

struct NotesListView: View {
    let sidebarSelection: SidebarSelection
    @Binding var selectedNote: Note?
    let searchText: String
    
    @Query private var allNotes: [Note]
    @Environment(\.modelContext) private var context
    
    private var displayedNotes: [Note] {
        let notes: [Note]
        switch sidebarSelection {
        case .allNotes: notes = allNotes
        case .folder(let folder): notes = folder.notes
        }
        
        let filtered = searchText.isEmpty
            ? notes
            : notes.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.content.localizedCaseInsensitiveContains(searchText) }
        
        return filtered.sorted { $0.sortIndex < $1.sortIndex }
    }
    
    private var pinnedNotes: [Note] { displayedNotes.filter { $0.isPinned } }
    private var regularNotes: [Note] { displayedNotes.filter { !$0.isPinned } }
    
    var body: some View {
        List(selection: $selectedNote) {
            if !pinnedNotes.isEmpty {
                Section("Pinned") {
                    ForEach(pinnedNotes, id: \.id) { note in
                        NoteRow(note: note)
                            .draggable(note.id.uuidString)
                            .tag(note)
                    }
                }
            }
            
            Section {
                ForEach(regularNotes, id: \.id) { note in
                    NoteRow(note: note)
                        .draggable(note.id.uuidString)
                        .tag(note)
                }
                .onMove { source, destination in
                    reorderNotes(from: source, to: destination)
                }
            }
        }
        .listStyle(.plain)
    }
    
    private func reorderNotes(from source: IndexSet, to destination: Int) {
        var updated = regularNotes
        updated.move(fromOffsets: source, toOffset: destination)
        for (index, note) in updated.enumerated() {
            note.sortIndex = index
        }
        try? context.save()
    }
}
