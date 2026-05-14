import SwiftUI
import SwiftData

struct MainSplitView: View {
    @State private var sidebarSelection: SidebarSelection = .allNotes
    @State private var selectedNote: Note?
    @State private var searchText = ""
    @AppStorage("noteSort") private var noteSort: NoteSort = .dateEdited

    @Query(sort: \Folder.sortIndex) private var folders: [Folder]
    @Environment(\.modelContext) private var context
    @Environment(ErrorManager.self) private var errorManager

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            SidebarView(sidebarSelection: $sidebarSelection, folders: folders)
                .navigationTitle("Ordem")
        } content: {
            NotesListView(
                sidebarSelection: sidebarSelection,
                selectedNote: $selectedNote,
                searchText: searchText,
                noteSort: $noteSort
            )
            .navigationTitle(titleFor(sidebarSelection))
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: createNewNote) {
                        Label("New Note", systemImage: "square.and.pencil")
                    }
                    .keyboardShortcut("n", modifiers: .command)
                    .disabled(sidebarSelection == .recentlyDeleted)
                }
                ToolbarItem(placement: .secondaryAction) {
                    Menu {
                        Picker("Sort By", selection: $noteSort) {
                            ForEach(NoteSort.allCases, id: \.self) { sort in
                                Text(sort.rawValue).tag(sort)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
        } detail: {
            NoteEditorView(selectedNote: $selectedNote)
        }
        .navigationSplitViewStyle(.balanced)
        .errorAlert(errorManager)
    }

    private func titleFor(_ selection: SidebarSelection) -> String {
        switch selection {
        case .allNotes:       return "All Notes"
        case .recentlyDeleted: return "Recently Deleted"
        case .folder(let id):
            return folders.first(where: { $0.persistentModelID == id })?.name ?? "Folder"
        }
    }

    private func createNewNote() {
        let newNote = Note(title: "Untitled", content: "")
        if case .folder(let id) = sidebarSelection {
            newNote.folder = folders.first(where: { $0.persistentModelID == id })
        }
        context.insert(newNote)
        selectedNote = newNote
    }
}
