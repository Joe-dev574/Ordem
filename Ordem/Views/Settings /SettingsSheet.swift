//
//  SettingsSheet.swift
//  Ordem
//
//  Copyright © 2026 Ordem. All rights reserved.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// MARK: - Pane Enum

private enum SettingsPane: String, CaseIterable, Identifiable {
    case appearance, editor, datesTime, iCloud, data, support, about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .appearance: "Appearance"
        case .editor:     "Editor"
        case .datesTime:  "Dates & Time"
        case .iCloud:     "iCloud"
        case .data:       "Data"
        case .support:    "Support"
        case .about:      "About"
        }
    }

    var icon: String {
        switch self {
        case .appearance: "paintpalette.fill"
        case .editor:     "doc.text.fill"
        case .datesTime:  "calendar"
        case .iCloud:     "icloud.fill"
        case .data:       "externaldrive.fill"
        case .support:    "questionmark.circle.fill"
        case .about:      "info.circle.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .appearance: Color(hex: "#9B59B6") ?? .purple
        case .editor:     Color(hex: "#3B82F6") ?? .blue
        case .datesTime:  Color(hex: "#F97316") ?? .orange
        case .iCloud:     Color(hex: "#0EA5E9") ?? .cyan
        case .data:       Color(hex: "#6B7280") ?? .gray
        case .support:    Color(hex: "#10B981") ?? .green
        case .about:      Color(hex: "#64748B") ?? .gray
        }
    }

    var description: String {
        switch self {
        case .appearance: "Customize the look and feel of Ordem."
        case .editor:     "Configure note editing and sorting behavior."
        case .datesTime:  "Control how dates and times appear across notes."
        case .iCloud:     "Manage iCloud sync across your devices."
        case .data:       "Export or permanently delete your notes."
        case .support:    "Get help, share feedback, and review Ordem."
        case .about:      "Version information and legal documents."
        }
    }
}

// MARK: - SettingsSheet

struct SettingsSheet: View {
    @Environment(\.modelContext) private var context
    @State private var selectedPane: SettingsPane? = .appearance

    // Editor
    @AppStorage("noteSort") private var noteSort: NoteSort = .dateEdited
    @AppStorage("spellCheckEnabled") private var spellCheckEnabled = true
    @AppStorage("smartPunctuationEnabled") private var smartPunctuationEnabled = false

    // Dates & Time
    @AppStorage("use24HourTime") private var use24HourTime = false
    @AppStorage("showRelativeDates") private var showRelativeDates = true

    // iCloud
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = true

    @State private var showingDeleteConfirmation = false
    @Query private var allNotes: [Note]

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    // MARK: - Body

    var body: some View {
        NavigationSplitView {
            List(SettingsPane.allCases, selection: $selectedPane) { pane in
                sidebarRow(for: pane).tag(pane)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            if let pane = selectedPane {
                detailView(for: pane)
                    .navigationTitle(pane.title)
            } else {
                ContentUnavailableView("Select a Setting", systemImage: "gearshape")
            }
        }
        .frame(minWidth: 680, minHeight: 480)
        .confirmationDialog(
            "Delete All Notes?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete All Notes", role: .destructive) { deleteAllNotes() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete all \(allNotes.count) notes and cannot be undone.")
        }
    }

    // MARK: - Sidebar Row

    private func sidebarRow(for pane: SettingsPane) -> some View {
        Label {
            Text(pane.title)
        } icon: {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(pane.iconColor)
                    .frame(width: 24, height: 24)
                Image(systemName: pane.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
    }

    // MARK: - Detail View

    @ViewBuilder
    private func detailView(for pane: SettingsPane) -> some View {
        Form {
            paneHeader(for: pane)

            switch pane {
            case .appearance:
                Section {
                    ThemePickerRow()
                } footer: {
                    Text("Themes inspired by welding metallurgy and US military service branches.")
                }

            case .editor:
                Section {
                    Picker("Default Sort", selection: $noteSort) {
                        ForEach(NoteSort.allCases, id: \.self) { sort in
                            Text(sort.rawValue).tag(sort)
                        }
                    }
                    Toggle("Spell Check", isOn: $spellCheckEnabled)
                    Toggle("Smart Punctuation", isOn: $smartPunctuationEnabled)
                } footer: {
                    Text("Smart Punctuation converts straight quotes and dashes into typographic equivalents.")
                }

            case .datesTime:
                Section {
                    Toggle("Use 24-Hour Time", isOn: $use24HourTime)
                    Toggle("Show Relative Dates", isOn: $showRelativeDates)
                } footer: {
                    Text("Relative dates display \u{201C}Today\u{201D} and \u{201C}Yesterday\u{201D} instead of exact dates.")
                }

            case .iCloud:
                Section {
                    Toggle("Sync with iCloud", isOn: $iCloudSyncEnabled)
                } footer: {
                    Text(iCloudSyncEnabled
                        ? "Notes are synced across all your devices signed in to iCloud."
                        : "Notes are stored on this device only and will not appear elsewhere.")
                }

            case .data:
                Section {
                    Button {
                        exportNotes()
                    } label: {
                        Label("Export All Notes\u{2026}", systemImage: "square.and.arrow.up")
                    }
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete All Notes", systemImage: "trash")
                    }
                    .disabled(allNotes.isEmpty)
                } footer: {
                    Text("Export saves all notes as a plain-text archive. Deletion is permanent and cannot be undone.")
                }

            case .support:
                // Replace id 000000000 with your real App Store ID before submission
                Section {
                    Link(destination: URL(string: "https://apps.apple.com/app/id000000000?action=write-review")!) {
                        Label("Rate Ordem", systemImage: "star")
                    }
                    Link(destination: URL(string: "mailto:support@ordem.app")!) {
                        Label("Send Feedback", systemImage: "envelope")
                    }
                    Link(destination: URL(string: "https://ordem.app/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    Link(destination: URL(string: "https://ordem.app/terms")!) {
                        Label("Terms of Use", systemImage: "doc.text")
                    }
                }

            case .about:
                Section {
                    LabeledContent("Version", value: "\(appVersion) (\(buildNumber))")
                    LabeledContent("Developer", value: "Joseph DeWeese")
                }
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - Pane Header

    private func paneHeader(for pane: SettingsPane) -> some View {
        Section {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(pane.iconColor)
                        .frame(width: 60, height: 60)
                    Image(systemName: pane.icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.white)
                }
                Text(pane.title)
                    .font(.title2.weight(.semibold))
                Text(pane.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 320)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }

    // MARK: - Actions

    private func deleteAllNotes() {
        for note in allNotes { context.delete(note) }
        try? context.save()
    }

    private func exportNotes() {
        let text = allNotes
            .sorted { $0.lastModified > $1.lastModified }
            .map { "# \($0.title)\n\($0.content)" }
            .joined(separator: "\n\n---\n\n")

        let panel = NSSavePanel()
        panel.nameFieldStringValue = "Ordem Notes.txt"
        panel.allowedContentTypes = [.plainText]
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            try? text.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}
