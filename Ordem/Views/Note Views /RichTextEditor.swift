import SwiftUI
import AppKit

// MARK: - TextEditorState

@MainActor
final class TextEditorState {
    weak var textView: NSTextView?

    func applyBold() {
        guard let tv = focused() else { return }
        toggleSymbolicTrait(.bold, in: tv)
    }

    func applyItalic() {
        guard let tv = focused() else { return }
        toggleSymbolicTrait(.italic, in: tv)
    }

    private func toggleSymbolicTrait(_ trait: NSFontDescriptor.SymbolicTraits, in textView: NSTextView) {
        guard let storage = textView.textStorage else { return }
        let range = textView.selectedRange()
        guard range.length > 0 else { return }

        // Determine if every run in the selection already has the trait
        var allHaveTrait = true
        storage.enumerateAttribute(.font, in: range, options: []) { value, _, stop in
            if let font = value as? NSFont, !font.fontDescriptor.symbolicTraits.contains(trait) {
                allHaveTrait = false
                stop.pointee = true
            }
        }

        guard textView.shouldChangeText(in: range, replacementString: nil) else { return }
        storage.beginEditing()
        storage.enumerateAttribute(.font, in: range, options: []) { value, attrRange, _ in
            let font = (value as? NSFont) ?? NSFont.systemFont(ofSize: 14)
            var traits = font.fontDescriptor.symbolicTraits
            if allHaveTrait { traits.remove(trait) } else { traits.insert(trait) }
            let descriptor = font.fontDescriptor.withSymbolicTraits(traits)
            if let newFont = NSFont(descriptor: descriptor, size: font.pointSize) {
                storage.addAttribute(.font, value: newFont, range: attrRange)
            }
        }
        storage.endEditing()
        textView.didChangeText()
    }

    func applyUnderline() {
        guard let tv = focused(), let storage = tv.textStorage else { return }
        let range = tv.selectedRange()
        guard range.length > 0 else { return }
        let current = storage.attribute(.underlineStyle, at: range.location, effectiveRange: nil) as? Int
        let value = current == NSUnderlineStyle.single.rawValue ? 0 : NSUnderlineStyle.single.rawValue
        storage.addAttribute(.underlineStyle, value: value, range: range)
        tv.didChangeText()
    }

    func applyStrikethrough() {
        guard let tv = focused(), let storage = tv.textStorage else { return }
        let range = tv.selectedRange()
        guard range.length > 0 else { return }
        let current = storage.attribute(.strikethroughStyle, at: range.location, effectiveRange: nil) as? Int
        let value = current == NSUnderlineStyle.single.rawValue ? 0 : NSUnderlineStyle.single.rawValue
        storage.addAttribute(.strikethroughStyle, value: value, range: range)
        tv.didChangeText()
    }

    func applyHeading(_ style: HeadingStyle) {
        guard let tv = focused(), let storage = tv.textStorage else { return }
        let paraRange = (tv.string as NSString).paragraphRange(for: tv.selectedRange())
        storage.addAttributes(style.attributes, range: paraRange)
        tv.didChangeText()
    }

    func applyBulletList()    { insertListPrefix("• ") }
    func applyNumberedList()  { insertListPrefix("1. ") }
    func applyChecklist()     { insertListPrefix("☐ ") }

    private func focused() -> NSTextView? {
        guard let tv = textView else { return nil }
        tv.window?.makeFirstResponder(tv)
        return tv
    }

    private func insertListPrefix(_ prefix: String) {
        guard let tv = focused(), let storage = tv.textStorage else { return }
        let paraRange = (tv.string as NSString).paragraphRange(for: tv.selectedRange())
        let paraText  = (tv.string as NSString).substring(with: paraRange)

        if paraText.hasPrefix(prefix) {
            let removeRange = NSRange(location: paraRange.location, length: (prefix as NSString).length)
            if tv.shouldChangeText(in: removeRange, replacementString: "") {
                storage.deleteCharacters(in: removeRange)
                tv.didChangeText()
            }
        } else {
            let insertRange = NSRange(location: paraRange.location, length: 0)
            if tv.shouldChangeText(in: insertRange, replacementString: prefix) {
                storage.insert(NSAttributedString(string: prefix), at: paraRange.location)
                tv.didChangeText()
            }
        }
    }
}

// MARK: - Heading Style

enum HeadingStyle {
    case title, heading, body, monospaced

    var attributes: [NSAttributedString.Key: Any] {
        switch self {
        case .title:      return [.font: NSFont.systemFont(ofSize: 24, weight: .bold)]
        case .heading:    return [.font: NSFont.systemFont(ofSize: 18, weight: .semibold)]
        case .body:       return [.font: NSFont.systemFont(ofSize: 14, weight: .regular)]
        case .monospaced: return [.font: NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)]
        }
    }
}

// MARK: - Checklist-aware NSTextView

final class ChecklistTextView: NSTextView {
    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        let index = charIndex(for: point)
        if index < string.count {
            let char = (string as NSString).substring(with: NSRange(location: index, length: 1))
            if char == "☐" || char == "☑" {
                let replacement = char == "☐" ? "☑" : "☐"
                let range = NSRange(location: index, length: 1)
                if shouldChangeText(in: range, replacementString: replacement) {
                    textStorage?.replaceCharacters(in: range, with: replacement)
                    didChangeText()
                }
                return
            }
        }
        super.mouseDown(with: event)
    }

    private func charIndex(for point: NSPoint) -> Int {
        guard let lm = layoutManager, let tc = textContainer else { return string.count }
        let adjusted = NSPoint(x: point.x - textContainerInset.width,
                               y: point.y - textContainerInset.height)
        let glyph = lm.glyphIndex(for: adjusted, in: tc, fractionOfDistanceThroughGlyph: nil)
        return lm.characterIndexForGlyph(at: glyph)
    }
}

// MARK: - RichTextEditor

struct RichTextEditor: NSViewRepresentable {
    @Binding var contentData: Data
    let editorState: TextEditorState

    func makeNSView(context: Context) -> NSScrollView {
        let textView = ChecklistTextView(frame: .zero)
        configure(textView, coordinator: context.coordinator)
        loadContent(into: textView)
        context.coordinator.lastPushedData = contentData
        editorState.textView = textView

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false
        scrollView.documentView = textView
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        editorState.textView = textView
        // Skip if this update originated from the editor itself
        guard contentData != context.coordinator.lastPushedData else { return }
        let savedRange = textView.selectedRange()
        loadContent(into: textView)
        let safeRange = NSRange(location: min(savedRange.location, textView.string.count), length: 0)
        textView.setSelectedRange(safeRange)
        context.coordinator.lastPushedData = contentData
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    // MARK: - Helpers

    private func configure(_ textView: NSTextView, coordinator: Coordinator) {
        textView.delegate = coordinator
        textView.isRichText = true
        textView.allowsUndo = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude,
                                                       height: CGFloat.greatestFiniteMagnitude)
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = true
        textView.typingAttributes = [
            .font: NSFont.systemFont(ofSize: 14),
            .foregroundColor: NSColor.textColor
        ]
    }

    private func loadContent(into textView: NSTextView) {
        if contentData.isEmpty {
            textView.textStorage?.setAttributedString(NSAttributedString())
        } else if let attrStr = NSAttributedString(rtf: contentData, documentAttributes: nil) {
            textView.textStorage?.setAttributedString(attrStr)
        }
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextEditor
        var lastPushedData: Data = Data()

        init(_ parent: RichTextEditor) { self.parent = parent }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView,
                  let storage = textView.textStorage else { return }
            let data = storage.rtf(
                from: NSRange(location: 0, length: storage.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
            ) ?? Data()
            lastPushedData = data
            parent.contentData = data
        }
    }
}
