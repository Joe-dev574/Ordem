import SwiftUI



// MARK: - WorkspaceTheme (Weld + Military Names)
enum WorkspaceTheme: String, CaseIterable, Identifiable {
    
    // Weld Metallurgy
    case HAZ
    case Fusion
    case Martensite
    case WeldPool
    case RootPass
    
    // US Military
    case Airman
    case Soldier
    case DevilDog
    case Sailor
    case Guardian
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .HAZ:        "HAZ"
        case .Fusion:     "Fusion"
        case .Martensite: "Martensite"
        case .WeldPool:   "Weld Pool"
        case .RootPass:   "Root Pass"
        case .Airman:     "Airman"
        case .Soldier:    "Soldier"
        case .DevilDog:   "Devil Dog"
        case .Sailor:     "Sailor"
        case .Guardian:   "Guardian"
        }
    }
    
    var subtitle: String {
        switch self {
        case .HAZ:        "Heat Affected Zone"
        case .Fusion:     "Molten Core"
        case .Martensite: "Hardest Steel"
        case .WeldPool:   "Liquid Metal"
        case .RootPass:   "First Critical Pass"
        case .Airman:     "Precision & Altitude"
        case .Soldier:    "Resilient Ground Force"
        case .DevilDog:   "Elite & Tough"
        case .Sailor:     "Global Reach"
        case .Guardian:   "Search & Rescue"
        }
    }
    var tint: Color {
        switch self {
        case .HAZ:        Color(hex: "#3B82F6") ?? .blue
        case .Fusion:     Color(hex: "#F97316") ?? .orange
        case .Martensite: Color(hex: "#64748B") ?? .gray
        case .WeldPool:   Color(hex: "#0EA5E9") ?? .cyan
        case .RootPass:   Color(hex: "#B45309") ?? .brown
        case .Airman:     Color(hex: "#0EA5E9") ?? .blue
        case .Soldier:    Color(hex: "#4B5320") ?? .green
        case .DevilDog:   Color(hex: "#9F1239") ?? .red
        case .Sailor:     Color(hex: "#1E3A8A") ?? .blue
        case .Guardian:   Color(hex: "#0D9488") ?? .teal
        }
    }
    
    func surfaceColor(_ role: WorkspaceSurfaceRole) -> Color {
        // Simplified version for now — full version available if needed
        switch self {
        case .HAZ:        return role == .sidebar ? Color(hex: "#1E2937") ?? .gray : Color(hex: "#0F172A") ?? .black
        case .Fusion:     return role == .sidebar ? Color(hex: "#292524") ?? .gray : Color(hex: "#1C1917") ?? .black
        case .Martensite: return role == .sidebar ? Color(hex: "#1E2937") ?? .gray : Color(hex: "#0F172A") ?? .black
        case .WeldPool:   return role == .sidebar ? Color(hex: "#134E4B") ?? .teal : Color(hex: "#0F172A") ?? .black
        case .RootPass:   return role == .sidebar ? Color(hex: "#292524") ?? .gray : Color(hex: "#1C1917") ?? .black
        case .Airman:     return role == .sidebar ? Color(hex: "#E0F2FE") ?? .blue : Color(hex: "#F0F9FF") ?? .white
        case .Soldier:    return role == .sidebar ? Color(hex: "#272F1F") ?? .green : Color(hex: "#1A1F15") ?? .black
        case .DevilDog:   return role == .sidebar ? Color(hex: "#2A1515") ?? .red : Color(hex: "#1A0F0F") ?? .black
        case .Sailor:     return role == .sidebar ? Color(hex: "#0F2744") ?? .blue : Color(hex: "#0A1628") ?? .black
        case .Guardian:   return role == .sidebar ? Color(hex: "#CCFBF1") ?? .teal : Color(hex: "#F0FDFA") ?? .white
        }
    }
    
    var primaryTextColor: Color {
        switch self {
        case .Airman, .Guardian: Color(hex: "#0F172A") ?? .black
        default: Color.white.opacity(0.92)
        }
    }
    
    var secondaryTextColor: Color {
        switch self {
        case .Airman:     Color(hex: "#334155") ?? .gray      // Sky blue theme
        case .Guardian:   Color(hex: "#134E4B") ?? .teal      // Teal theme
        case .Soldier:    Color(hex: "#6B8E4E") ?? .green     // Olive theme
        case .DevilDog:   Color(hex: "#8B3A3A") ?? .red       // Red theme
        case .Sailor:     Color(hex: "#60A5FA") ?? .blue      // Navy theme
        case .HAZ:        Color.white.opacity(0.75)
        case .Fusion:     Color.white.opacity(0.75)
        case .Martensite: Color.white.opacity(0.75)
        case .WeldPool:   Color.white.opacity(0.75)
        case .RootPass:   Color.white.opacity(0.75)
        }
    }
    
    var tertiaryTextColor: Color {
        switch self {
        case .Airman, .Guardian: Color(hex: "#64748B") ?? .gray
        default: Color.white.opacity(0.45)
        }
    }
}
// MARK: - View Extension
extension View {
    func workspaceSurface(_ role: WorkspaceSurfaceRole) -> some View {
        modifier(WorkspaceSurfaceModifier(role: role))
    }
}

private struct WorkspaceSurfaceModifier: ViewModifier {
    @AppStorage("workspaceTheme") private var workspaceThemeRawValue = WorkspaceTheme.HAZ.rawValue
    let role: WorkspaceSurfaceRole

    private var theme: WorkspaceTheme {
        WorkspaceTheme(rawValue: workspaceThemeRawValue) ?? .HAZ
    }

    func body(content: Content) -> some View {
        content.background(theme.surfaceColor(role))
    }
}
