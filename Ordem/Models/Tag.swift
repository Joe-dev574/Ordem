import SwiftData
import Foundation

@Model
final class Tag: Identifiable, Hashable {
    @Attribute(.unique) var name: String
    var colorHex: String?

    @Relationship(inverse: \UserTask.tags) var tasks: [UserTask] = []
    @Relationship(inverse: \Note.tags) var notes: [Note] = []

    init(name: String, colorHex: String? = nil) {
        self.name = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        self.colorHex = colorHex
    }
}
