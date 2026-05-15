import EventKit
import SwiftData
import Foundation

/// Singleton for bidirectional sync between Ordem tasks and Apple Reminders.
@Observable
@MainActor
final class RemindersSync {
    static let shared = RemindersSync()

    let store = EKEventStore()
    private(set) var isAuthorized = false
    private var observer: NSObjectProtocol?

    private init() {}

    // MARK: - Authorization

    func requestAccessIfNeeded() {
        guard !isAuthorized else { return }
        Task { @MainActor in
            if #available(macOS 14.0, iOS 17.0, *) {
                let status = EKEventStore.authorizationStatus(for: .reminder)
                if status != .fullAccess {
                    _ = try? await self.store.requestFullAccessToReminders()
                }
                self.isAuthorized = EKEventStore.authorizationStatus(for: .reminder) == .fullAccess
            } else {
                let granted = await withCheckedContinuation { cont in
                    self.store.requestAccess(to: .reminder) { ok, _ in cont.resume(returning: ok) }
                }
                self.isAuthorized = granted
            }
            self.startObserving()
        }
    }

    // MARK: - Observation

    private func startObserving() {
        guard observer == nil else { return }
        observer = NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: store,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.pullFromReminders()
            }
        }
    }

    // MARK: - Outbound: Ordem → Reminders

    func pushTask(_ task: UserTask, context: ModelContext) {
        guard isAuthorized else { return }
        if let id = task.ekReminderID,
           let reminder = store.calendarItem(withIdentifier: id) as? EKReminder {
            apply(task: task, to: reminder)
            try? store.save(reminder, commit: true)
        } else {
            createReminder(for: task, context: context)
        }
        task.lastSyncedAt = .now
    }

    private func apply(task: UserTask, to reminder: EKReminder) {
        reminder.title = task.taskTitle
        if let due = task.dueDate {
            reminder.dueDateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], from: due)
        } else {
            reminder.dueDateComponents = nil
        }
        reminder.isCompleted = task.isCompleted
        // Map Ordem priority (1=Urgent…4=Low) → EKReminder priority (1=High…9=Low)
        let ekPriority: Int
        switch task.priority {
        case 1: ekPriority = 1
        case 2: ekPriority = 5
        case 3: ekPriority = 7
        default: ekPriority = 9
        }
        reminder.priority = ekPriority
        reminder.notes = "ordem://userTask/\(task.id)"
    }

    private func createReminder(for task: UserTask, context: ModelContext) {
        guard isAuthorized else { return }
        let reminder = EKReminder(eventStore: store)
        apply(task: task, to: reminder)
        reminder.calendar = store.defaultCalendarForNewReminders()
        do {
            try store.save(reminder, commit: true)
            task.ekReminderID = reminder.calendarItemIdentifier
            task.lastSyncedAt = .now
        } catch {
            print("[RemindersSync] Failed to create reminder for '\(task.taskTitle)': \(error.localizedDescription)")
        }
    }

    // MARK: - Inbound: Reminders → Ordem

    func pullFromReminders() async {
        guard isAuthorized else { return }
        let predicate = store.predicateForReminders(in: nil)
        let reminders: [EKReminder] = await withCheckedContinuation { cont in
            store.fetchReminders(matching: predicate) { cont.resume(returning: $0 ?? []) }
        }
        NotificationCenter.default.post(
            name: .remindersDidSync,
            object: nil,
            userInfo: ["reminders": reminders]
        )
    }

    func applyInboundChanges(reminders: [EKReminder], context: ModelContext) throws {
        for reminder in reminders {
            let rid = reminder.calendarItemIdentifier

            // Match by stored ekReminderID
            let byID = FetchDescriptor<UserTask>(predicate: #Predicate { $0.ekReminderID == rid })
            if let task = try? context.fetch(byID).first {
                var changed = false
                if task.isCompleted != reminder.isCompleted { task.isCompleted = reminder.isCompleted; changed = true }
                if let rTitle = reminder.title, task.taskTitle != rTitle { task.taskTitle = rTitle; changed = true }
                let newDue = reminder.dueDateComponents.flatMap { Calendar.current.date(from: $0) }
                if task.dueDate != newDue { task.dueDate = newDue; changed = true }
                if changed { task.lastSyncedAt = .now }
                continue
            }

            // Reminder note contains an Ordem task UUID — re-link
            if let taskID = taskID(fromNotes: reminder.notes) {
                let byUUID = FetchDescriptor<UserTask>(predicate: #Predicate { $0.id == taskID })
                if let task = try? context.fetch(byUUID).first {
                    task.ekReminderID = rid
                    task.lastSyncedAt = .now
                    continue
                }
            }

            // Import external reminder as a new task
            guard !reminder.isCompleted else { continue }
            let task = UserTask(
                title: reminder.title ?? "Untitled",
                dueDate: reminder.dueDateComponents.flatMap { Calendar.current.date(from: $0) },
                priority: priorityFromEK(reminder.priority)
            )
            task.ekReminderID = rid
            task.lastSyncedAt = .now
            context.insert(task)
        }
    }

    // MARK: - Helpers

    private func priorityFromEK(_ ekPriority: Int) -> Int {
        switch ekPriority {
        case 1...3: return 1
        case 4...6: return 2
        case 7...8: return 3
        default:    return 4
        }
    }

    private func taskID(fromNotes notes: String?) -> UUID? {
        guard let notes else { return nil }
        let prefix = "ordem://userTask/"
        if let range = notes.range(of: prefix) {
            return UUID(uuidString: String(notes[range.upperBound...]))
        }
        return nil
    }
}

extension Notification.Name {
    static let remindersDidSync = Notification.Name("com.ordem.remindersDidSync")
}
