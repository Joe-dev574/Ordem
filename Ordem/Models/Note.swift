import AppKit
import SwiftData

@Model
final class Note {
    var id: UUID = UUID()
    var title: String
    var content: String                                    // plain text kept in sync for search
    @Attribute(.externalStorage) var contentData: Data = Data()
    var createdAt: Date
    var lastModified: Date
    var isPinned: Bool
    var deletedAt: Date?
    var folder: Folder?
    var sortIndex: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \Attachment.note)
    var attachments: [Attachment] = []

    var isDeleted: Bool { deletedAt != nil }

    init(title: String = "Untitled", content: String = "") {
        self.title = title
        self.content = content
        self.contentData = Data()
        self.createdAt = .now
        self.lastModified = .now
        self.isPinned = false
        self.sortIndex = 0
    }
}
