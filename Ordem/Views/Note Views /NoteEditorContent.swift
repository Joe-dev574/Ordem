import SwiftUI
import SwiftData

struct NoteEditorContent: View {
    let note: Note
    let editorState: TextEditorState

    @Environment(\.modelContext) private var context

    private var contentBinding: Binding<Data> {
        Binding(
            get: { note.contentData },
            set: { newData in
                note.contentData = newData
                note.lastModified = .now
                syncTitleFromFirstLine(newData)
                try? context.save()
            }
        )
    }

    var body: some View {
        RichTextEditor(contentData: contentBinding, editorState: editorState)
            .onAppear {
                ensureTitleAndSubtitle()
            }
    }

    // MARK: - Title + Subtitle Logic

    private func syncTitleFromFirstLine(_ data: Data) {
        guard let attrStr = NSAttributedString(rtf: data, documentAttributes: nil) else { return }
        let lines = attrStr.string.components(separatedBy: .newlines)
        
        if let firstLine = lines.first {
            note.title = firstLine.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    private func ensureTitleAndSubtitle() {
        guard let attrStr = NSAttributedString(rtf: note.contentData, documentAttributes: nil) else { return }
        let text = attrStr.string
        let lines = text.components(separatedBy: .newlines)

        // If first line is empty, insert title as large heading
        if lines.first?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true && !note.title.isEmpty {
            let titleAttr = NSAttributedString(
                string: note.title + "\n",
                attributes: [
                    .font: NSFont.systemFont(ofSize: 26, weight: .bold),
                    .foregroundColor: NSColor.labelColor
                ]
            )
            
            let mutable = NSMutableAttributedString(attributedString: attrStr)
            mutable.insert(titleAttr, at: 0)
            
            if let newData = mutable.rtf(from: NSRange(location: 0, length: mutable.length),
                                         documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]) {
                note.contentData = newData
            }
        }
    }
}
