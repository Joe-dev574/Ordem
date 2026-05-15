import SwiftUI

/// A due-date input that accepts natural language ("tomorrow", "next Friday", "in 3 days")
/// with a live preview line and an optional DatePicker fallback via calendar icon.
struct NLPDateField: View {
    @Binding var date: Date?

    @State private var text = ""
    @State private var showPicker = false
    @FocusState private var focused: Bool

    private var parsed: Date? { NLPDateParser.parse(text) }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .foregroundStyle(date != nil ? .blue : .secondary)
                    .font(.callout)

                TextField(#"Due — "tomorrow", "next Friday", "May 15""#, text: $text)
                    .textFieldStyle(.plain)
                    .font(.callout)
                    .focused($focused)
                    .onChange(of: text) { _, new in
                        date = new.isEmpty ? nil : NLPDateParser.parse(new)
                    }

                if !text.isEmpty {
                    Button { text = ""; date = nil } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                }

                Button { showPicker.toggle() } label: {
                    Image(systemName: "calendar.badge.clock").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showPicker, arrowEdge: .bottom) {
                    VStack(spacing: 12) {
                        DatePicker(
                            "Pick a date",
                            selection: Binding(
                                get: { date ?? .now },
                                set: { d in
                                    date = d
                                    text = d.formatted(.dateTime.month(.abbreviated).day().year())
                                    showPicker = false
                                }
                            ),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.graphical)
                        .frame(width: 300)
                    }
                    .padding()
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.quaternary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 7))

            if !text.isEmpty {
                if let preview = NLPDateParser.preview(text) {
                    Text(preview)
                        .font(.caption)
                        .foregroundStyle(.green)
                        .padding(.horizontal, 4)
                } else {
                    Text(#"Can't parse that — try "tomorrow" or "May 15""#)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 4)
                }
            } else if let d = date {
                Text(d.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().hour().minute()))
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 4)
            }
        }
        .onAppear {
            if let d = date {
                text = d.formatted(.dateTime.month(.abbreviated).day().year())
            }
        }
    }
}
