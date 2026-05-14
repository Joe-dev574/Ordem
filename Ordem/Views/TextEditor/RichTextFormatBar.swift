import SwiftUI

struct RichTextFormatBar: ToolbarContent {
    let editorState: TextEditorState
    var isEnabled: Bool = true

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            Button { editorState.applyBold() } label: { Image(systemName: "bold") }
                .help("Bold ⌘B")
                .disabled(!isEnabled)

            Button { editorState.applyItalic() } label: { Image(systemName: "italic") }
                .help("Italic ⌘I")
                .disabled(!isEnabled)

            Button { editorState.applyUnderline() } label: { Image(systemName: "underline") }
                .help("Underline ⌘U")
                .disabled(!isEnabled)

            Button { editorState.applyStrikethrough() } label: { Image(systemName: "strikethrough") }
                .help("Strikethrough")
                .disabled(!isEnabled)

            Menu {
                Button("Title")      { editorState.applyHeading(.title) }
                Button("Heading")    { editorState.applyHeading(.heading) }
                Button("Body")       { editorState.applyHeading(.body) }
                Button("Monospaced") { editorState.applyHeading(.monospaced) }
            } label: {
                Image(systemName: "textformat")
            }
            .help("Text Style")
            .disabled(!isEnabled)

            Button { editorState.applyBulletList() } label: { Image(systemName: "list.bullet") }
                .help("Bullet List")
                .disabled(!isEnabled)

            Button { editorState.applyNumberedList() } label: { Image(systemName: "list.number") }
                .help("Numbered List")
                .disabled(!isEnabled)

            Button { editorState.applyChecklist() } label: { Image(systemName: "checklist") }
                .help("Checklist")
                .disabled(!isEnabled)
        }
    }
}
