import Foundation

enum NoteType: String, Codable, CaseIterable, Identifiable {
    case scratch    = "Scratch"
    case decision   = "Decision"
    case brainstorm = "Brainstorm"
    case research   = "Research"
    case issue      = "Bug"
    case meeting    = "Meeting"
    case idea       = "Idea"
    case update     = "Daily"
    case bookmark   = "Bookmark"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .scratch:    "doc.text"
        case .decision:   "checkmark.square"
        case .brainstorm: "brain.filled.head.profile"
        case .research:   "magnifyingglass"
        case .issue:      "exclamationmark.triangle"
        case .meeting:    "person.2"
        case .idea:       "lightbulb"
        case .update:     "calendar.day.timeline.left"
        case .bookmark:   "bookmark.fill"
        }
    }

    var templateMarkdown: String {
        switch self {
        case .issue:
            return "**Summary:**\n\n**Steps to Reproduce:**\n1. \n2. \n\n**Expected vs Actual:**\n\n**Device / OS:**"
        case .meeting:
            return "**Agenda:**\n\n**Decisions:**\n\n**Action Items:**\n\n"
        case .update:
            return "## Tasks\n- [ ] \n\n## Notes\n"
        case .bookmark:
            return "**URL:** \n\n**Summary:**\n\n**Tags:**\n"
        default:
            return ""
        }
    }
}
