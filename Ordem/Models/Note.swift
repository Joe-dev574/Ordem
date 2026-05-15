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

    @Relationship(deleteRule: .nullify) var tags: [Tag] = []
    @Relationship(deleteRule: .nullify) var project: Project?
    @Relationship(deleteRule: .nullify, inverse: \UserTask.linkedNotes) var tasks: [UserTask] = []

    // Stored as optional String so SwiftData lightweight migration leaves existing rows
    // as NULL rather than crashing when trying to coerce nil → NoteType.
    var noteTypeRawValue: String? = NoteType.scratch.rawValue

    var noteType: NoteType {
        get { NoteType(rawValue: noteTypeRawValue ?? "") ?? .scratch }
        set { noteTypeRawValue = newValue.rawValue }
    }

    var isDeleted: Bool { deletedAt != nil }

    init(title: String = "Untitled", content: String = "", noteType: NoteType = .scratch) {
        self.title = title
        self.content = content
        self.contentData = Data()
        self.createdAt = .now
        self.lastModified = .now
        self.isPinned = false
        self.sortIndex = 0
        self.noteTypeRawValue = noteType.rawValue
    }
}
