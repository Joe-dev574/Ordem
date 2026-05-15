import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// MARK: - Main Inspector

struct NoteInspectorView: View {
    let note: Note

    @Environment(\.modelContext) private var context
    @AppStorage("workspaceTheme") private var themeRawValue = WorkspaceTheme.HAZ.rawValue
    private var theme: WorkspaceTheme { WorkspaceTheme(rawValue: themeRawValue) ?? .HAZ }

    @Query(sort: \Project.projectTitle) private var allProjects: [Project]
    @Query(sort: \Tag.name) private var allTags: [Tag]

    @State private var detectedTasks: [DetectedTask] = []
    @State private var createdTaskIDs: Set<UUID> = []
    @State private var isFileImporterShown = false

    private var pendingTasks: [DetectedTask] {
        detectedTasks.filter { !createdTaskIDs.contains($0.id) }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 0) {
                noteTypeSection
                separator
                checklistSection
                separator
                attachmentsSection
                separator
                projectFolderSection
                separator
                tagsSection
                separator
                remindersSection
                Spacer(minLength: 20)
            }
        }
        .background(theme.surfaceColor(.chrome))
        .frame(width: 268)
        .onAppear { detectedTasks = NoteTaskParser.detect(in: note.content) }
        .onChange(of: note.content) { _, _ in
            detectedTasks = NoteTaskParser.detect(in: note.content)
        }
        .fileImporter(
            isPresented: $isFileImporterShown,
            allowedContentTypes: [.image, .pdf, .text, .data],
            allowsMultipleSelection: false,
            onCompletion: handleFileImport
        )
    }

    private var separator: some View {
        Divider().opacity(0.12)
    }

    // MARK: - Note Type

    private var noteTypeSection: some View {
        InspectorSection(title: "Note Type", systemImage: "doc.badge.gearshape", theme: theme) {
            Picker("Note Type", selection: Binding(
                get: { note.noteType },
                set: { note.noteType = $0; try? context.save() }
            )) {
                ForEach(NoteType.allCases) { type in
                    Label(type.rawValue, systemImage: type.icon).tag(type)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Checklist

    private var checklistSection: some View {
        InspectorSection(
            title: "Checklist",
            systemImage: "checklist",
            badge: pendingTasks.isEmpty ? nil : "\(pendingTasks.count)/\(detectedTasks.count)",
            theme: theme
        ) {
            if pendingTasks.isEmpty {
                Text(detectedTasks.isEmpty ? "No action items detected" : "All items added")
                    .font(.caption)
                    .foregroundStyle(theme.tertiaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(pendingTasks) { task in
                        ChecklistRow(task: task, theme: theme) {
                            createReminder(from: task)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Attachments

    private var attachmentsSection: some View {
        InspectorSection(
            title: "Attachments",
            systemImage: "paperclip",
            badge: note.attachments.isEmpty ? nil : "\(note.attachments.count)",
            trailingButton: ("plus", { isFileImporterShown = true }),
            theme: theme
        ) {
            if note.attachments.isEmpty {
                Button { isFileImporterShown = true } label: {
                    Label("Add Attachment", systemImage: "plus.circle")
                        .font(.subheadline)
                        .foregroundStyle(theme.tint)
                }
                .buttonStyle(.plain)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(note.attachments) { att in
                        AttachmentRow(attachment: att, theme: theme) {
                            context.delete(att)
                            try? context.save()
                        }
                    }
                    Button { isFileImporterShown = true } label: {
                        Label("Add", systemImage: "plus.circle")
                            .font(.caption)
                            .foregroundStyle(theme.tint)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Project & Folder

    private var projectFolderSection: some View {
        InspectorSection(title: "Project & Folder", systemImage: "folder.badge.gearshape", theme: theme) {
            VStack(spacing: 8) {
                HStack {
                    Text("Project")
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryTextColor)
                    Spacer()
                    Picker("Project", selection: Binding(
                        get: { note.project?.persistentModelID },
                        set: { id in
                            note.project = allProjects.first { $0.persistentModelID == id }
                            try? context.save()
                        }
                    )) {
                        Text("None").tag(Optional<PersistentIdentifier>.none)
                        ForEach(allProjects) { project in
                            Text(project.projectTitle).tag(Optional(project.persistentModelID))
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .frame(maxWidth: 130)
                }

                if let folder = note.folder {
                    HStack {
                        Text("Folder")
                            .font(.subheadline)
                            .foregroundStyle(theme.secondaryTextColor)
                        Spacer()
                        HStack(spacing: 5) {
                            Circle().fill(folder.color).frame(width: 7, height: 7)
                            Text(folder.name)
                                .font(.subheadline)
                                .foregroundStyle(theme.primaryTextColor)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Tags

    private var tagsSection: some View {
        InspectorSection(
            title: "Tags",
            systemImage: "tag",
            theme: theme
        ) {
            let noteTags = note.tags
            let available = allTags.filter { tag in
                !noteTags.contains { $0.persistentModelID == tag.persistentModelID }
            }

            VStack(alignment: .leading, spacing: 6) {
                if !noteTags.isEmpty {
                    TagChipGrid(tags: noteTags, theme: theme) { tag in
                        note.tags.removeAll { $0.persistentModelID == tag.persistentModelID }
                        try? context.save()
                    }
                }
                if !available.isEmpty {
                    Menu {
                        ForEach(available) { tag in
                            Button(tag.name) {
                                note.tags.append(tag)
                                try? context.save()
                            }
                        }
                    } label: {
                        Label("Tags", systemImage: "tag.badge.plus")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(theme.tint)
                    }
                    .menuStyle(.borderlessButton)
                    .menuIndicator(.visible)
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else if noteTags.isEmpty {
                    Text("No tags available")
                        .font(.caption)
                        .foregroundStyle(theme.tertiaryTextColor)
                }
            }
        }
    }

    // MARK: - Reminders

    private var remindersSection: some View {
        InspectorSection(title: "Reminders", systemImage: "bell", theme: theme) {
            let linkedReminders = note.tasks.filter { $0.ekReminderID != nil }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(linkedReminders) { task in
                    HStack(spacing: 8) {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.body)
                            .foregroundStyle(task.isCompleted ? .green : theme.tertiaryTextColor)
                        Text(task.taskTitle)
                            .font(.subheadline)
                            .foregroundStyle(theme.primaryTextColor)
                            .lineLimit(2)
                    }
                }

                Button {
                    addReminder()
                } label: {
                    Label("Add Reminder", systemImage: "plus.circle")
                        .font(.subheadline)
                        .foregroundStyle(theme.tint)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Actions

    private func createReminder(from detected: DetectedTask) {
        let sync = RemindersSync.shared
        sync.requestAccessIfNeeded()
        let task = UserTask(title: detected.text, dueDate: detected.dueDate, priority: 2)
        task.linkedNotes.append(note)
        context.insert(task)
        Task { @MainActor in
            if sync.isAuthorized { sync.pushTask(task, context: context) }
        }
        createdTaskIDs.insert(detected.id)
        try? context.save()
    }

    private func addReminder() {
        let sync = RemindersSync.shared
        sync.requestAccessIfNeeded()
        let task = UserTask(title: note.title.isEmpty ? "Reminder" : note.title, priority: 2)
        task.linkedNotes.append(note)
        context.insert(task)
        Task { @MainActor in
            if sync.isAuthorized { sync.pushTask(task, context: context) }
        }
        try? context.save()
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        guard case .success(let urls) = result, let url = urls.first else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let data = try? Data(contentsOf: url) else { return }
        let mime = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType ?? "application/octet-stream"
        let att = Attachment(filename: url.lastPathComponent, mimeType: mime, data: data)
        att.note = note
        note.attachments.append(att)
        context.insert(att)
        try? context.save()
    }
}

// MARK: - InspectorSection

private struct InspectorSection<Content: View>: View {
    let title: String
    let systemImage: String
    var badge: String? = nil
    var trailingButton: (String, () -> Void)? = nil
    let theme: WorkspaceTheme
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.tint)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.secondaryTextColor)
                if let badge {
                    Text(badge)
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(theme.tint.opacity(0.18))
                        .foregroundStyle(theme.tint)
                        .clipShape(Capsule())
                }
                Spacer()
                if let (icon, action) = trailingButton {
                    Button(action: action) {
                        Image(systemName: icon)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(theme.tertiaryTextColor)
                    }
                    .buttonStyle(.plain)
                }
            }
            content()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

// MARK: - ChecklistRow

private struct ChecklistRow: View {
    let task: DetectedTask
    let theme: WorkspaceTheme
    let onAdd: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "circle")
                .font(.body)
                .foregroundStyle(theme.tertiaryTextColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.text)
                    .font(.subheadline)
                    .foregroundStyle(theme.primaryTextColor)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                if let due = task.dueDate {
                    Text(due, style: .date)
                        .font(.caption2)
                        .foregroundStyle(theme.tint.opacity(0.85))
                }
            }

            Spacer(minLength: 4)

            Button("Reminder", action: onAdd)
                .font(.caption.weight(.medium))
                .foregroundStyle(theme.tint)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(theme.tint.opacity(0.15))
                .clipShape(Capsule())
                .buttonStyle(.plain)
        }
    }
}

// MARK: - AttachmentRow

private struct AttachmentRow: View {
    let attachment: Attachment
    let theme: WorkspaceTheme
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(theme.surfaceColor(.elevated))
                    .frame(width: 34, height: 34)
                Image(systemName: attachment.isImage ? "photo" : attachment.isPDF ? "doc.richtext" : "doc")
                    .font(.system(size: 15))
                    .foregroundStyle(theme.tint)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(attachment.filename)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(theme.primaryTextColor)
                    .lineLimit(1)
                Text(attachment.mimeType)
                    .font(.caption2)
                    .foregroundStyle(theme.tertiaryTextColor)
                    .lineLimit(1)
            }
            Spacer()
            Button(action: onRemove) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.75))
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - TagChipGrid

private struct TagChipGrid: View {
    let tags: [Tag]
    let theme: WorkspaceTheme
    let onRemove: (Tag) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60, maximum: 110))], spacing: 4) {
            ForEach(tags) { tag in
                HStack(spacing: 3) {
                    if let hex = tag.colorHex {
                        Circle().fill(Color(hex: hex) ?? theme.tint).frame(width: 6, height: 6)
                    }
                    Text(tag.name)
                        .font(.caption2.weight(.medium))
                        .lineLimit(1)
                    Button {
                        onRemove(tag)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 7, weight: .bold))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(theme.tint.opacity(0.15))
                .foregroundStyle(theme.tint)
                .clipShape(Capsule())
            }
        }
    }
}
