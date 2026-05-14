import SwiftUI

struct NoteEditorView: View {
    @Binding var selectedNote: Note?
    @State private var editorState = TextEditorState()

    var body: some View {
        Group {
            if let note = selectedNote {
                NoteEditorContent(note: note, editorState: editorState)
                    .id(note.id)
            } else {
                ContentUnavailableView("No Note Selected", systemImage: "note.text")
            }
        }
        .toolbar {
            RichTextFormatBar(editorState: editorState, isEnabled: selectedNote != nil)
        }
    }
}
