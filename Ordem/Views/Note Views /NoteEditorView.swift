import SwiftUI
import SwiftData

struct NoteEditorView: View {
    @Binding var selectedNote: Note?
    @State private var editorState = TextEditorState()
    @State private var isInspectorShown = false

    var body: some View {
        Group {
            if let note = selectedNote {
                HStack(spacing: 0) {
                    NoteEditorContent(note: note, editorState: editorState)
                    if isInspectorShown {
                        Divider()
                        NoteInspectorView(note: note)
                            .id(note.id)
                    }
                }
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
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isInspectorShown.toggle()
                } label: {
                    Label("Inspector", systemImage: "sidebar.right")
                }
                .disabled(selectedNote == nil)
                .help("Toggle Inspector")
            }
        }
    }
}
