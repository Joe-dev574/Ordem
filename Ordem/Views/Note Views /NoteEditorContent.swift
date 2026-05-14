import SwiftUI
import AppKit

struct NoteEditorContent: View {
    @Bindable var note: Note
    let editorState: TextEditorState
    @State private var saveTask: Task<Void, Never>?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("Title", text: $note.title)
                .font(.title2.bold())
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.top, 12)
            Text(note.lastModified.formatted(date: .long, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
            RichTextEditor(contentData: contentBinding, editorState: editorState)
                .padding(.horizontal, 4)
        }
        .onChange(of: note.title) { _, _ in scheduleSave() }
        .onDisappear { saveTask?.cancel() }
    }

    private var contentBinding: Binding<Data> {
        Binding(
            get: { note.contentData },
            set: { newData in
                note.contentData = newData
                if let attrStr = NSAttributedString(rtf: newData, documentAttributes: nil) {
                    note.content = attrStr.string
                }
                scheduleSave()
            }
        )
    }

    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .seconds(1))
            if !Task.isCancelled { note.lastModified = .now }
        }
    }
}
