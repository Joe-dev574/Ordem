import SwiftUI

struct ThemePickerView: View {
    @AppStorage("workspaceTheme") private var workspaceThemeRawValue = WorkspaceTheme.HAZ.rawValue
    @Environment(\.dismiss) private var dismiss

    private var currentTheme: WorkspaceTheme {
        WorkspaceTheme(rawValue: workspaceThemeRawValue) ?? .HAZ
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 170))], spacing: 20) {
                    ForEach(WorkspaceTheme.allCases) { theme in
                        ThemeCard(theme: theme, isSelected: currentTheme == theme) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                workspaceThemeRawValue = theme.rawValue
                            }
                        }
                    }
                }
                .padding(24)
            }
            .navigationTitle("Choose Theme")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
