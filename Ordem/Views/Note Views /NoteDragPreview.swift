//
//  NoteDragPreview.swift
//  Ordem
//
//  Created by Joseph DeWeese on 5/13/26.
//

import SwiftUI

struct NoteDragPreview: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Title
            Text(note.title.isEmpty ? "Untitled" : note.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            // Content snippet
            Text(note.content.prefix(120) + (note.content.count > 120 ? "…" : ""))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .padding(12)
        .frame(maxWidth: 320)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 10, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}
