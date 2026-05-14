import SwiftUI
import SwiftData

/// Main editor container for a single note.
/// Follows Apple Notes behavior: title + date live inside the editable content,
/// while all formatting controls live in the window toolbar.
struct NoteEditorView: View {
    @Binding var selectedNote: Note?
    @State private var editorState = TextEditorState()
    
    var body: some View {
        Group {
            if let note = selectedNote {
                NoteEditorContent(note: note, editorState: editorState)
                    .id(note.id)
            } else {
                ContentUnavailableView(
                    "No Note Selected",
                    systemImage: "note.text",
                    description: Text("Select a note or create a new one with ⌘N")
                )
            }
        }
        .workspaceSurface(.detail)
        .toolbar {
            RichTextFormatBar(editorState: editorState, isEnabled: selectedNote != nil)
        }
    }
}
