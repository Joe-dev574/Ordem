import Foundation
import SwiftData
import SwiftUI

@Model
final class UserTask: Identifiable {
    @Attribute(.unique) var id: UUID

    var taskTitle: String
    var notes: String?
    var dueDate: Date?

    /// 1 = Urgent, 2 = High, 3 = Medium, 4 = Low
    var priority: Int = 2
    var isCompleted: Bool = false
    var isFlagged: Bool = false
    var isTrashed: Bool = false
    var trashedAt: Date?
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Reminders / Calendar Sync
    var ekReminderID: String?
    var ekEventID: String?
    var lastSyncedAt: Date?

    var sortIndex: Int = 0

    // MARK: - Relationships
    @Relationship(deleteRule: .nullify) var folder: Folder?
    @Relationship(deleteRule: .nullify) var project: Project?
    @Relationship(deleteRule: .nullify) var tags: [Tag] = []
    @Relationship(deleteRule: .nullify) var linkedNotes: [Note] = []

    init(title: String, dueDate: Date? = nil, priority: Int = 2,
         folder: Folder? = nil, isFlagged: Bool = false) {
        self.id = UUID()
        self.taskTitle = title
        self.dueDate = dueDate
        self.priority = max(1, min(4, priority))
        self.isFlagged = isFlagged
        self.folder = folder
        self.createdAt = .now
        self.updatedAt = .now
    }

    var isOverdue: Bool {
        guard let due = dueDate, !isCompleted else { return false }
        return due < .now
    }

    var isUpcoming: Bool {
        guard let due = dueDate, !isCompleted else { return false }
        let endOfTomorrow = Calendar.current.date(byAdding: .day, value: 2,
            to: Calendar.current.startOfDay(for: .now))!
        return due >= .now && due < endOfTomorrow
    }

    var priorityColor: Color {
        switch priority {
        case 1: .red
        case 2: .orange
        case 3: .blue
        default: .gray
        }
    }
}
