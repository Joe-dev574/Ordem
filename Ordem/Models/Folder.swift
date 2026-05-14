import Foundation
import SwiftData

@Model
final class Folder {
    var name: String
    
    @Relationship(deleteRule: .cascade, inverse: \Note.folder)
    var notes: [Note] = []
    
    init(name: String) {
        self.name = name
    }
}
