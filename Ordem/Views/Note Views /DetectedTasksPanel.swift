import SwiftUI
import SwiftData

/// Inline panel shown below the note editor when actionable items are detected in the note content.
struct DetectedTasksPanel: View {
    let note: Note
    let onDismiss: () -> Void

    @Environment(\.modelContext) private var context
    @AppStorage("workspaceTheme") private var themeRawValue = WorkspaceTheme.HAZ.rawValue
    private var theme: WorkspaceTheme { WorkspaceTheme(rawValue: themeRawValue) ?? .HAZ }

    // Track which items have already been turned into reminders this session
    @State private var createdIDs: Set<UUID> = []

    private var pending: [DetectedTask] {
        NoteTaskParser.detect(in: note.content).filter { !createdIDs.contains($0.id) }
    }

    var body: some View {
        if pending.isEmpty { EmptyView() } else { panel }
    }

    private var panel: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "bell.badge")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.tint)
                Text("Suggested Reminders")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.secondaryTextColor)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(theme.tertiaryTextColor)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)

            Divider().opacity(0.15)

            // Task rows
            ForEach(pending) { task in
                TaskSuggestionRow(
                    task: task,
                    theme: theme,
                    onAdd: { addReminder(from: task) }
                )
            }
        }
        .background(theme.surfaceColor(.elevated))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.tint.opacity(0.35))
                .frame(height: 1)
        }
    }

    private func addReminder(from detected: DetectedTask) {
        let sync = RemindersSync.shared
        sync.requestAccessIfNeeded()

        let task = UserTask(
            title: detected.text,
            dueDate: detected.dueDate,
            priority: 2
        )
        task.linkedNotes.append(note)
        context.insert(task)

        // Push to Apple Reminders (async — auth may not be ready on first tap,
        // but the UserTask is saved locally regardless)
        Task { @MainActor in
            if sync.isAuthorized {
                sync.pushTask(task, context: context)
            }
        }

        createdIDs.insert(detected.id)
        try? context.save()
    }
}

// MARK: - Row

private struct TaskSuggestionRow: View {
    let task: DetectedTask
    let theme: WorkspaceTheme
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "circle")
                .font(.subheadline)
                .foregroundStyle(theme.tertiaryTextColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.text)
                    .font(.subheadline)
                    .foregroundStyle(theme.primaryTextColor)
                    .lineLimit(2)

                if let due = task.dueDate {
                    Text(due, style: .date)
                        .font(.caption2)
                        .foregroundStyle(theme.tint.opacity(0.8))
                }
            }

            Spacer()

            Button(action: onAdd) {
                Label("Add", systemImage: "plus.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.tint)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
    }
}
