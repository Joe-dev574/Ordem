//
//  NoteRow.swift
//  Ordem
//
//  Created by Joseph DeWeese on 5/13/26.
//

import SwiftUI

struct NoteRow: View {
    let note: Note

    @AppStorage("workspaceTheme") private var themeRawValue = WorkspaceTheme.HAZ.rawValue
    @State private var isHovering = false

    private var theme: WorkspaceTheme { WorkspaceTheme(rawValue: themeRawValue) ?? .HAZ }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            // MARK: Header — title + pin
            HStack(spacing: 8) {
                Text(note.title.isEmpty ? "Untitled" : note.title)
                    .font(.headline.weight(.bold))
                    .lineLimit(2)
                    .foregroundStyle(theme.primaryTextColor)

                Spacer()

                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(theme.tint)
                        .shadow(color: theme.tint.opacity(0.4), radius: 2, x: 0, y: 1)
                }
            }

            // MARK: Content preview
            if !note.content.isEmpty {
                Text(note.content)
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryTextColor)
                    .lineLimit(3)
                    .padding(.top, 2)
            }

            // MARK: Metadata bar
            HStack(spacing: 6) {
                if let folder = note.folder {
                    HStack(spacing: 3) {
                        Image(systemName: "folder.fill")
                            .font(.caption2)
                        Text(folder.name)
                            .font(.caption2.weight(.medium))
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(theme.tint.opacity(0.14))
                    .foregroundStyle(theme.tint)
                    .clipShape(Capsule())
                }

                if !note.attachments.isEmpty {
                    HStack(spacing: 3) {
                        Image(systemName: "paperclip")
                            .font(.caption2.weight(.semibold))
                        Text("\(note.attachments.count)")
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(theme.tertiaryTextColor)
                }

                Spacer()

                Text(note.lastModified, format: .dateTime.month(.abbreviated).day())
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(theme.tertiaryTextColor)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        // Card background + subtle gloss gradient
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(theme.surfaceColor(.card))
                .overlay(
                    LinearGradient(
                        colors: [Color.white.opacity(0.04), Color.clear, Color.black.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                )
        )
        // Left spine accent
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [theme.tint, theme.tint.opacity(0.65)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4.5)
                .padding(.vertical, 4)
                .shadow(color: theme.tint.opacity(0.35), radius: 3, x: 1, y: 0)
        }
        // Stroke border
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(theme.strokeColor, lineWidth: theme.strokeWidth)
        }
        // Hover shadow + lift
        .shadow(
            color: isHovering ? theme.tint.opacity(0.28) : theme.cardShadowColor,
            radius: isHovering ? 10 : theme.cardShadowRadius,
            x: 0,
            y: isHovering ? 5 : theme.cardShadowY
        )
        .scaleEffect(isHovering ? 1.018 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.65), value: isHovering)
        .onHover { isHovering = $0 }
        .contentShape(Rectangle())
    }
}
