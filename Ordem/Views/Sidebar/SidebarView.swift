import SwiftUI
import SwiftData

struct SidebarView: View {
    @Binding var sidebarSelection: SidebarSelection
    let folders: [Folder]
    @Query private var allNotes: [Note]
    @Environment(\.modelContext) private var context
    @Environment(ErrorManager.self) private var errorManager

    @State private var isCreatingFolder = false
    @State private var newFolderName = ""
    @State private var renamingFolderID: PersistentIdentifier?
    @State private var renameText = ""

    private var visibleFolders: [Folder] { folders.filter { !$0.isArchived } }
    private var archivedFolders: [Folder] { folders.filter { $0.isArchived } }
    private var activeNoteCount: Int { allNotes.filter { !$0.isDeleted }.count }
    private var deletedNoteCount: Int { allNotes.filter { $0.isDeleted }.count }

    var body: some View {
        List(selection: $sidebarSelection) {
            Section {
                selectionRow(title: "All Notes", systemImage: "note.text", count: activeNoteCount)
                    .tag(SidebarSelection.allNotes)
                    .dropDestination(for: String.self) { ids, _ in handleDrop(ids, to: nil) }
            } header: {
                Text("iCloud")
            }

            Section {
                ForEach(visibleFolders) { folder in
                    folderRow(folder)
                }
                .onMove { source, destination in
                    reorderFolders(from: source, to: destination)
                }

                if isCreatingFolder {
                    HStack(spacing: 8) {
                        Image(systemName: "folder").foregroundStyle(.secondary)
                        TextField("Folder Name", text: $newFolderName)
                            .textFieldStyle(.plain)
                            .onSubmit { commitNewFolder() }
                            .onExitCommand { cancelNewFolder() }
                    }
                }
            } header: {
                HStack {
                    Text("Folders")
                    Spacer()
                    Button { startCreatingFolder() } label: {
                        Image(systemName: "plus").font(.caption)
                    }
                    .buttonStyle(.plain)
                }
            }

            if !archivedFolders.isEmpty {
                Section("Archived") {
                    ForEach(archivedFolders) { folder in
                        folderRow(folder)
                    }
                }
            }

            Section {
                selectionRow(title: "Recently Deleted", systemImage: "trash", count: deletedNoteCount)
                    .tag(SidebarSelection.recentlyDeleted)
                    .foregroundStyle(deletedNoteCount > 0 ? .primary : .secondary)
            }
        }
        .listStyle(.sidebar)
    }

    // MARK: - Folder Row

    @ViewBuilder
    private func folderRow(_ folder: Folder) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(folder.color)
                .frame(width: 8, height: 8)

            if renamingFolderID == folder.persistentModelID {
                TextField("Folder Name", text: $renameText)
                    .textFieldStyle(.plain)
                    .onSubmit { commitRename(folder) }
                    .onExitCommand { renamingFolderID = nil }
            } else {
                selectionRow(
                    title: folder.name,
                    systemImage: "folder",
                    count: folder.notes.filter { !$0.isDeleted }.count
                )
            }
        }
        .contextMenu {
            Button("Rename", systemImage: "pencil") { startRenaming(folder) }
            Button(
                folder.isArchived ? "Unarchive" : "Archive",
                systemImage: folder.isArchived ? "tray.and.arrow.up" : "tray.and.arrow.down"
            ) { toggleArchive(folder) }
            Menu("Change Color", systemImage: "paintpalette") {
                ForEach(["#FFD166", "#EF476F", "#06D6A0", "#118AB2", "#8338EC"], id: \.self) { hex in
                    Button {
                        setFolderColor(folder, hex: hex)
                    } label: {
                        HStack {
                            Circle().fill(Color(hex: hex) ?? .clear).frame(width: 12, height: 12)
                            Text(colorName(hex))
                        }
                    }
                }
            }
            Divider()
            Button("Delete Folder", systemImage: "trash", role: .destructive) { deleteFolder(folder) }
        }
        .tag(SidebarSelection.folder(id: folder.persistentModelID))
        .dropDestination(for: String.self) { ids, _ in handleDrop(ids, to: folder) }
    }

    @ViewBuilder
    private func selectionRow(title: String, systemImage: String, count: Int) -> some View {
        HStack(spacing: 10) {
            Label(title, systemImage: systemImage).font(.callout)
            Spacer(minLength: 8)
            if count > 0 {
                Text("\(count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.quaternary, in: Capsule())
            }
        }
        .contentShape(Rectangle())
    }

    // MARK: - Folder Creation

    private func startCreatingFolder() {
        newFolderName = ""
        isCreatingFolder = true
    }

    private func commitNewFolder() {
        let name = newFolderName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { cancelNewFolder(); return }
        let folder = Folder(name: name)
        folder.sortIndex = (visibleFolders.map(\.sortIndex).max() ?? -1) + 1
        context.insert(folder)
        do {
            try context.save()
            sidebarSelection = .folder(id: folder.persistentModelID)
        } catch {
            errorManager.handle(error, context: "Creating folder")
        }
        isCreatingFolder = false
        newFolderName = ""
    }

    private func cancelNewFolder() {
        isCreatingFolder = false
        newFolderName = ""
    }

    // MARK: - Folder Rename

    private func startRenaming(_ folder: Folder) {
        renameText = folder.name
        renamingFolderID = folder.persistentModelID
    }

    private func commitRename(_ folder: Folder) {
        let name = renameText.trimmingCharacters(in: .whitespaces)
        if !name.isEmpty { folder.name = name }
        do { try context.save() } catch { errorManager.handle(error, context: "Renaming folder") }
        renamingFolderID = nil
    }

    // MARK: - Reorder

    private func reorderFolders(from source: IndexSet, to destination: Int) {
        var updated = visibleFolders
        updated.move(fromOffsets: source, toOffset: destination)
        for (index, folder) in updated.enumerated() {
            folder.sortIndex = index
        }
        do { try context.save() } catch { errorManager.handle(error, context: "Reordering folders") }
    }

    // MARK: - Drop

    private func handleDrop(_ ids: [String], to targetFolder: Folder?) {
        var didChange = false
        for idString in ids {
            guard let uuid = UUID(uuidString: idString) else { continue }
            let descriptor = FetchDescriptor<Note>(predicate: #Predicate { $0.id == uuid })
            if let note = try? context.fetch(descriptor).first,
               note.folder?.persistentModelID != targetFolder?.persistentModelID {
                note.folder = targetFolder
                note.lastModified = .now
                didChange = true
            }
        }
        if didChange {
            do { try context.save() } catch { errorManager.handle(error, context: "Moving notes after drop") }
        }
    }

    // MARK: - Actions

    private func toggleArchive(_ folder: Folder) {
        folder.isArchived.toggle()
        do { try context.save() } catch { errorManager.handle(error, context: "Toggling folder archive") }
    }

    private func setFolderColor(_ folder: Folder, hex: String) {
        folder.colorHex = hex
        do { try context.save() } catch { errorManager.handle(error, context: "Changing folder color") }
    }

    private func deleteFolder(_ folder: Folder) {
        context.delete(folder)
        do { try context.save() } catch { errorManager.handle(error, context: "Deleting folder") }
    }

    private func colorName(_ hex: String) -> String {
        switch hex {
        case "#FFD166": return "Yellow"
        case "#EF476F": return "Red"
        case "#06D6A0": return "Green"
        case "#118AB2": return "Blue"
        case "#8338EC": return "Purple"
        default: return hex
        }
    }
}
