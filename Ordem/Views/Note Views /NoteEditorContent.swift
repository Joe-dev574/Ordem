//
//  NoteEditorContent.swift
//  Ordem
//
//  Created by Joseph DeWeese on 5/13/26.
//
import SwiftUI
import SwiftData


struct NoteEditorContent: View {
    @Bindable var note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title - smaller, Apple Notes style
            TextField("Title", text: $note.title)
                .font(.title2)
                .textFieldStyle(.plain)
                .padding(.horizontal)
                .padding(.top, 12)
            
            // Date stamp at the top (exactly like Apple Notes)
            Text(note.lastModified.formatted(date: .long, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            // Content editor - clean and simple
            TextEditor(text: $note.content)
                .font(.body)
                .padding(.horizontal)
                .scrollContentBackground(.hidden)
        }
        .onChange(of: note.title) { _, _ in note.lastModified = .now }
        .onChange(of: note.content) { _, _ in note.lastModified = .now }
    }
}
