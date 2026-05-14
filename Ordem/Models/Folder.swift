import Foundation
import SwiftData
import SwiftUI
import CoreGraphics

@Model
final class Folder {
    var name: String
    var colorHex: String = "#FFD166"
    var isArchived: Bool = false
    var sortIndex: Int = 0

    var color: Color { Color(hex: colorHex) ?? .yellow }

    @Relationship(deleteRule: .cascade, inverse: \Note.folder)
    var notes: [Note] = []

    init(name: String) {
        self.name = name
    }
}

private extension Color {
    init?(rgb: UInt32) {
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self = Color(red: r, green: g, blue: b)
    }
}

extension Color {
    init?(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }
        guard cleaned.count == 6, let value = UInt32(cleaned, radix: 16) else { return nil }
        self.init(rgb: value)
    }
}
