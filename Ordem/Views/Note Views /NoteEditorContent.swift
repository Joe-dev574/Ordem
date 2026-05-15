import SwiftUI
import SwiftData

struct NoteEditorContent: View {
    let note: Note
    let editorState: TextEditorState

    @Environment(\.modelContext) private var context
    @AppStorage("workspaceTheme") private var themeRawValue = WorkspaceTheme.HAZ.rawValue
    private var theme: WorkspaceTheme { WorkspaceTheme(rawValue: themeRawValue) ?? .HAZ }


    private var contentBinding: Binding<Data> {
        Binding(
            get: { note.contentData },
            set: { newData in
                note.contentData = newData
                note.lastModified = .now
                syncTitleFromFirstLine(newData)
                syncPlainText(newData)          // keeps note.content current for search + task detection
                try? context.save()
            }
        )
    }

    var body: some View {
        RichTextEditor(
            contentData: contentBinding,
            editorState: editorState,
            backgroundColor: NSColor(theme.surfaceColor(.detail)),
            textColor: NSColor(theme.primaryTextColor)
        )
        .onAppear {
            ensureProperTitleAndDate()
        }
    }

    // MARK: - Title + Date Logic

    private func syncPlainText(_ data: Data) {
        guard let attrStr = NSAttributedString(rtf: data, documentAttributes: nil) else { return }
        let plain = attrStr.string
        if note.content != plain { note.content = plain }
    }

    private func syncTitleFromFirstLine(_ data: Data) {
        guard let attrStr = NSAttributedString(rtf: data, documentAttributes: nil) else { return }
        let lines = attrStr.string.components(separatedBy: .newlines)
        
        if let firstLine = lines.first {
            let cleanTitle = firstLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if note.title != cleanTitle {
                note.title = cleanTitle
            }
        }
    }

    private func ensureProperTitleAndDate() {
        guard let attrStr = NSAttributedString(rtf: note.contentData, documentAttributes: nil) else { return }
        
        let mutable = NSMutableAttributedString(attributedString: attrStr)
        let fullText = attrStr.string
        let lines = fullText.components(separatedBy: .newlines)
        
        var didChange = false

        // 1. Ensure first line is large bold heading
        if !lines.isEmpty {
            let firstParagraphRange = (fullText as NSString).paragraphRange(for: NSRange(location: 0, length: 0))
            let titleFont = NSFont.systemFont(ofSize: 26, weight: .bold)
            
            // Only apply if not already bold/large
            if mutable.attribute(.font, at: 0, effectiveRange: nil) as? NSFont != titleFont {
                mutable.addAttribute(.font, value: titleFont, range: firstParagraphRange)
                didChange = true
            }
        }

        // 2. Ensure a date line exists somewhere below the title
        // Check all lines — the leading "\n" in the inserted string puts the date on lines[2],
        // not lines[1], so checking only lines[1] always missed it and added a duplicate.
        let hasDateLine = lines.contains { $0.contains(", 20") }

        if !hasDateLine {
            let dateString = "\n" + formattedDate(note.lastModified) + "\n\n"
            let dateAttr = NSAttributedString(
                string: dateString,
                attributes: [
                    .font: NSFont.systemFont(ofSize: 13, weight: .regular),
                    .foregroundColor: NSColor.secondaryLabelColor
                ]
            )
            
            // Insert after first paragraph
            let firstParagraphEnd = (fullText as NSString).paragraphRange(for: NSRange(location: 0, length: 0)).length
            mutable.insert(dateAttr, at: firstParagraphEnd)
            didChange = true
        }

        // 3. Save only if we actually made changes
        if didChange, let newData = mutable.rtf(
            from: NSRange(location: 0, length: mutable.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
        ) {
            note.contentData = newData
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
