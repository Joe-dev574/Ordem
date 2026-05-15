import Foundation
import SwiftUI
import SwiftData

@Model
final class Project: Identifiable {
    @Attribute(.unique) var id: UUID
    var sortOrder: Int = 0
    var projectTitle: String
    var subtitle: String?
    var colorHex: String?
    var targetDate: Date?
    var isArchived: Bool = false
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .nullify, inverse: \Note.project) var notes: [Note] = []
    @Relationship(deleteRule: .nullify, inverse: \UserTask.project) var userTasks: [UserTask] = []

    var noteCount: Int { notes.filter { !$0.isDeleted }.count }

    var color: Color { Color(hex: colorHex ?? "#3B82F6") ?? .blue }

    init(title: String, subtitle: String? = nil, colorHex: String? = nil, targetDate: Date? = nil) {
        self.id = UUID()
        self.projectTitle = title
        self.subtitle = subtitle
        self.colorHex = colorHex
        self.targetDate = targetDate
        self.createdAt = .now
        self.updatedAt = .now
    }
}
