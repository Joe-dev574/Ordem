import Foundation

/// A candidate action item detected inside note content.
struct DetectedTask: Identifiable {
    let id = UUID()
    let text: String
    let dueDate: Date?
}

/// Scans a note's synced plain-text `content` field and returns action items.
///
/// Detection strategy:
///   1. Explicit checkbox syntax  (- [ ], * [ ])
///   2. Keyword prefixes          (TODO:, REMINDER:, ACTION:, FIXME:, MUST:, …)
///   3. Date-anchored lines       (any line containing "due", "by", "deadline"
///                                 that also yields a parseable NSDataDetector date)
///
/// Date extraction uses NSDataDetector, which handles relative expressions like
/// "next Friday", "in 3 days", "May 15 at 5pm", and bare weekday names.
enum NoteTaskParser {

    // MARK: - Public API

    static func detect(in content: String) -> [DetectedTask] {
        guard !content.isEmpty else { return [] }

        let lines = content.components(separatedBy: .newlines)
        var results: [DetectedTask] = []

        for (index, rawLine) in lines.enumerated() {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            guard line.count >= 3 else { continue }

            // Skip the title line (index 0) and the auto-inserted date stamp
            if index == 0 { continue }
            if isAutoDateLine(line) { continue }

            if let taskText = extractTaskText(from: line) {
                let due = extractDate(from: line)
                results.append(DetectedTask(text: taskText, dueDate: due))
            }
        }

        return results
    }

    // MARK: - Line classification

    /// Returns the clean task text if the line is an action item, nil otherwise.
    private static func extractTaskText(from line: String) -> String? {
        let lowered = line.lowercased()

        // 1. Markdown / plain-text checkboxes (unchecked only)
        let checkboxPrefixes = ["- [ ] ", "- [ ]", "* [ ] ", "* [ ]"]
        for prefix in checkboxPrefixes {
            if lowered.hasPrefix(prefix) {
                return stripped(line, prefix: prefix)
            }
        }

        // 2. Explicit keyword prefixes (case-insensitive)
        let keywordPrefixes: [String] = [
            "todo: ", "todo:", "todo - ", "todo -", "todo ",
            "reminder: ", "reminder:", "remind: ", "remind:",
            "action item: ", "action item:", "action: ", "action:",
            "fixme: ", "fixme:", "fix: ", "fix:",
            "must: ", "must:", "need to: ", "need to:",
            "needs to: ", "needs to:",
            "follow up: ", "follow up:",
            "→ ", "→",
        ]
        for prefix in keywordPrefixes {
            if lowered.hasPrefix(prefix) {
                return stripped(line, prefix: prefix)
            }
        }

        // 3. Date-anchored lines — lines that mention a time-sensitive trigger
        //    AND contain a parseable date. Treat the whole line as the task.
        let dateAnchors = ["due ", "due:", "by ", "deadline:", "deadline ",
                           "by eod", "by end of", "before "]
        for anchor in dateAnchors {
            if lowered.contains(anchor), extractDate(from: line) != nil {
                return line.trimmingCharacters(in: .whitespaces)
            }
        }

        return nil
    }

    /// True if this line is the auto-stamped date inserted by the editor.
    private static func isAutoDateLine(_ line: String) -> Bool {
        // Matches patterns like "May 14, 2026 at 7:05 PM" or "May 14, 2026"
        line.contains(", 20") && (line.contains(" at ") || line.range(of: #"\d{4}"#, options: .regularExpression) != nil)
    }

    private static func stripped(_ line: String, prefix: String) -> String? {
        let text = String(line.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
        return text.isEmpty ? nil : text
    }

    // MARK: - Date extraction (NSDataDetector)

    static func extractDate(from text: String) -> Date? {
        guard let detector = try? NSDataDetector(
            types: NSTextCheckingResult.CheckingType.date.rawValue
        ) else { return nil }

        let range = NSRange(text.startIndex..., in: text)
        let matches = detector.matches(in: text, options: [], range: range)

        guard let match = matches.first, let date = match.date else { return nil }

        // If no time component detected, default to 5 PM on that day
        if match.duration == 0 {
            return Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: date) ?? date
        }
        return date
    }
}
