//
//  MenuBarView.swift
//  Ordem
//
//  Created by Joseph DeWeese on 5/14/26.
//

import SwiftUI
import SwiftData

/// Menu Bar Extra view for Ordem.
/// Follows latest Apple HIG for MenuBarExtra with .menuBarExtraStyle(.window)
struct MenuBarView: View {
    @Environment(\.modelContext) private var context
    @Environment(ErrorManager.self) private var errorManager
    
    @Query(sort: \Note.lastModified, order: .reverse) private var recentNotes: [Note]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Ordem")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button {
                    createNewNote()
                } label: {
                    Label("New Note", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            
            Divider()
            
            // Recent Notes Section
            if !recentNotes.isEmpty {
                Section {
                    ForEach(recentNotes) { note in
                        Button {
                            openNote(note)
                        } label: {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundStyle(.secondary)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(note.title.isEmpty ? "Untitled Note" : note.title)
                                        .lineLimit(1)
                                        .foregroundStyle(.primary)
                                    
                                    Text(note.lastModified, style: .relative)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }
                } header: {
                    Text("Recent Notes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                }
            } else {
                ContentUnavailableView(
                    "No Recent Notes",
                    systemImage: "note.text",
                    description: Text("Create your first note to get started.")
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            
            Divider()
                .padding(.top, 8)
            
            // Bottom Actions (HIG compliant)
            VStack(spacing: 4) {
                Button("Open Ordem") {
                    NSApp.activate(ignoringOtherApps: true)
                }
                
                Button("Settings…") {
                    openSettings()
                }
                
                Divider()
                
                Button("Quit Ordem", role: .destructive) {
                    NSApp.terminate(nil)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 280)
    }
    
    // MARK: - Actions
    
    private func createNewNote() {
        let newNote = Note(title: "Untitled", content: "")
        context.insert(newNote)
        
        // Open the main window and select the new note
        NSApp.activate(ignoringOtherApps: true)
        
        // TODO: In future, we can post a notification to select this note automatically
        try? context.save()
    }
    
    private func openNote(_ note: Note) {
        // This will be improved once we have deep linking / notification system
        NSApp.activate(ignoringOtherApps: true)
        // For now, user can manually select the note from the list
    }
    
    private func openSettings() {
        // Opens the native Settings window
        if let settingsWindow = NSApp.windows.first(where: { $0.identifier?.rawValue.contains("Settings") ?? false }) {
            settingsWindow.makeKeyAndOrderFront(nil)
        } else {
            // Fallback: post notification or use Settings API if available
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        }
    }
}
