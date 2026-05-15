import Foundation

/// Parses natural-language date strings using NSDataDetector.
/// Handles: "tomorrow", "next Friday", "in 3 days", "Monday", "May 10", "5pm", etc.
enum NLPDateParser {

    static func parse(_ input: String) -> Date? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // Fast path: exact ISO date
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withFullDate]
        if let d = iso.date(from: trimmed) { return d }

        guard let detector = try? NSDataDetector(
            types: NSTextCheckingResult.CheckingType.date.rawValue
        ) else { return nil }

        let range = NSRange(trimmed.startIndex..., in: trimmed)
        let matches = detector.matches(in: trimmed, options: [], range: range)

        guard let match = matches.first, let date = match.date else { return nil }

        // Default to 5 PM when no explicit time was given
        if match.duration == 0 {
            return Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: date) ?? date
        }
        return date
    }

    /// Human-readable preview: "in 2 days — Fri, May 16 at 5:00 PM"
    static func preview(_ input: String) -> String? {
        guard let date = parse(input) else { return nil }
        let relative = RelativeDateTimeFormatter().localizedString(for: date, relativeTo: .now)
        let absolute = date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().hour().minute())
        return "\(relative) — \(absolute)"
    }
}
