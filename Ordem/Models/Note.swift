import AppKit
import SwiftData

@Model
final class Note {
    var id: UUID = UUID()          // stable unique ID
    var title: String
    var content: String
    var lastModified: Date
    var isPinned: Bool
    var folder: Folder?
    var sortIndex: Int = 0
    
    init(title: String = "Untitled", content: String = "") {
        self.title = title
        self.content = content
        self.lastModified = .now
        self.isPinned = false
        self.sortIndex = 0
    }
}
