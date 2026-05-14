import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Appearance
                Section {
                    ThemePickerRow()
                } header: {
                    Text("Appearance")
                }

                // MARK: - Behavior
                Section("Behavior") {
                    Toggle("Use 24-hour time", isOn: .constant(true))
                    Toggle("Show relative dates", isOn: .constant(true))
                }

                // MARK: - Data & Privacy
                Section("Data & Privacy") {
                    Toggle("Enable iCloud Sync", isOn: .constant(true))
                    Toggle("Local-only Mode", isOn: .constant(false))
                }

                // MARK: - About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(.secondary)
                    }
                    Link("Privacy Policy", destination: URL(string: "https://ordem.app/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://ordem.app/terms")!)
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .frame(minWidth: 540, minHeight: 620)
    }
}


