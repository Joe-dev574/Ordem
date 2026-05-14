import Foundation
import SwiftData

enum SidebarSelection: Hashable {
    case allNotes
    case folder(id: PersistentIdentifier)
    case recentlyDeleted
}
