import SwiftUI
import SwiftData

struct MainSplitView: View {
    @State private var sidebarSelection: SidebarSelection = .allNotes
    @State private var selectedNote: Note?
    @State private var searchText = ""
    
    @Query(sort: \Folder.name) private var folders: [Folder]
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            SidebarView(sidebarSelection: $sidebarSelection, folders: folders)
                .navigationTitle("Ordem")
        } content: {
            NotesListView(
                sidebarSelection: sidebarSelection,
                selectedNote: $selectedNote,
                searchText: searchText
            )
            .navigationTitle(titleFor(sidebarSelection))
            .searchable(text: $searchText)
        } detail: {
            NoteEditorView(selectedNote: $selectedNote)
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: createNewNote) {
                    Label("New Note", systemImage: "square.and.pencil")
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
    
    private func titleFor(_ selection: SidebarSelection) -> String {
        switch selection {
        case .allNotes: return "All Notes"
        case .folder(let folder): return folder.name
        }
    }
    
    private func createNewNote() {
        let newNote = Note(title: "Untitled", content: "")
        
        // If we're in a specific folder, put the new note there
        if case .folder(let folder) = sidebarSelection {
            newNote.folder = folder
        }
        
        context.insert(newNote)
        selectedNote = newNote
    }
}
