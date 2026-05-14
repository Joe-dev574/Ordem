import SwiftUI
import SwiftData

struct NotesListView: View {
    let sidebarSelection: SidebarSelection
    @Binding var selectedNote: Note?
    let searchText: String
    @Binding var noteSort: NoteSort

    @Query private var allNotes: [Note]
    @Environment(\.modelContext) private var context
    @Environment(ErrorManager.self) private var errorManager

    private var isRecentlyDeleted: Bool { sidebarSelection == .recentlyDeleted }

    private var displayedNotes: [Note] {
        switch sidebarSelection {
        case .recentlyDeleted:
            return allNotes
                .filter { $0.isDeleted }
                .sorted { ($0.deletedAt ?? .distantPast) > ($1.deletedAt ?? .distantPast) }
        case .allNotes:
            return sorted(filtered(allNotes.filter { !$0.isDeleted }))
        case .folder(let id):
            return sorted(filtered(allNotes.filter { !$0.isDeleted && $0.folder?.persistentModelID == id }))
        }
    }

    private var pinnedNotes: [Note] { displayedNotes.filter { $0.isPinned } }
    private var regularNotes: [Note] { displayedNotes.filter { !$0.isPinned } }

    var body: some View {
        if displayedNotes.isEmpty {
            emptyState
        } else if isRecentlyDeleted {
            recentlyDeletedList
        } else {
            notesList
        }
    }

    // MARK: - List Views

    private var notesList: some View {
        List(selection: $selectedNote) {
            if !pinnedNotes.isEmpty {
                Section("Pinned") {
                    ForEach(pinnedNotes, id: \.id) { note in
                        NoteRow(note: note)
                            .draggable(note.id.uuidString) { NoteDragPreview(note: note) }
                            .tag(note)
                            .contextMenu { noteContextMenu(for: note) }
                    }
                }
            }
            Section {
                ForEach(regularNotes, id: \.id) { note in
                    NoteRow(note: note)
                        .draggable(note.id.uuidString) { NoteDragPreview(note: note) }
                        .tag(note)
                        .contextMenu { noteContextMenu(for: note) }
                }
                .onMove { source, destination in
                    guard searchText.isEmpty else { return }
                    reorderNotes(from: source, to: destination)
                }
            }
        }
        .listStyle(.plain)
    }

    private var recentlyDeletedList: some View {
        List(selection: $selectedNote) {
            ForEach(displayedNotes, id: \.id) { note in
                NoteRow(note: note)
                    .tag(note)
                    .contextMenu {
                        Button("Restore", systemImage: "arrow.uturn.backward") { restore(note) }
                        Divider()
                        Button("Delete Permanently", systemImage: "trash", role: .destructive) {
                            deletePermanently(note)
                        }
                    }
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private var emptyState: some View {
        switch sidebarSelection {
        case .allNotes:
            ContentUnavailableView("No Notes", systemImage: "note.text",
                description: Text("Press ⌘N to create your first note."))
        case .folder:
            ContentUnavailableView("Empty Folder", systemImage: "folder",
                description: Text("Press ⌘N to add a note to this folder."))
        case .recentlyDeleted:
            ContentUnavailableView("No Deleted Notes", systemImage: "trash",
                description: Text("Deleted notes are kept here for 30 days."))
        }
    }

    @ViewBuilder
    private func noteContextMenu(for note: Note) -> some View {
        Button(note.isPinned ? "Unpin" : "Pin",
               systemImage: note.isPinned ? "pin.slash" : "pin") { togglePin(note) }
        Divider()
        Button("Delete", systemImage: "trash", role: .destructive) { softDelete(note) }
    }

    // MARK: - Sorting & Filtering

    private func filtered(_ notes: [Note]) -> [Note] {
        guard !searchText.isEmpty else { return notes }
        return notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func sorted(_ notes: [Note]) -> [Note] {
        switch noteSort {
        case .dateEdited:  return notes.sorted { $0.lastModified > $1.lastModified }
        case .dateCreated: return notes.sorted { $0.createdAt > $1.createdAt }
        case .title:       return notes.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .manual:      return notes.sorted {
            $0.sortIndex != $1.sortIndex ? $0.sortIndex < $1.sortIndex : $0.createdAt > $1.createdAt
        }
        }
    }

    // MARK: - Actions

    private func reorderNotes(from source: IndexSet, to destination: Int) {
        // Auto-switch to manual order so the new position persists
        if noteSort != .manual { noteSort = .manual }
        var updated = regularNotes
        updated.move(fromOffsets: source, toOffset: destination)
        for (index, note) in updated.enumerated() { note.sortIndex = index }
        do { try context.save() } catch { errorManager.handle(error, context: "Reordering notes") }
    }

    private func togglePin(_ note: Note) {
        note.isPinned.toggle()
        note.lastModified = .now
        do { try context.save() } catch { errorManager.handle(error, context: "Toggling pin") }
    }

    private func softDelete(_ note: Note) {
        if selectedNote?.id == note.id { selectedNote = nil }
        note.deletedAt = .now
        note.folder = nil
        do { try context.save() } catch { errorManager.handle(error, context: "Deleting note") }
    }

    private func restore(_ note: Note) {
        note.deletedAt = nil
        do { try context.save() } catch { errorManager.handle(error, context: "Restoring note") }
    }

    private func deletePermanently(_ note: Note) {
        if selectedNote?.id == note.id { selectedNote = nil }
        context.delete(note)
        do { try context.save() } catch { errorManager.handle(error, context: "Permanently deleting note") }
    }
}
