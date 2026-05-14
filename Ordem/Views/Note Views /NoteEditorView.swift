import SwiftUI

struct NoteEditorView: View {
    @Binding var selectedNote: Note?
    
    var body: some View {
        if let note = selectedNote {
            NoteEditorContent(note: note)
        } else {
            ContentUnavailableView("No Note Selected", systemImage: "note.text")
        }
    }
}
