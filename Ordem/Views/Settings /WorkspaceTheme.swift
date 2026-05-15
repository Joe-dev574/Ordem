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
        case .Airman:     "Aim High, Fly Fight Win"
        case .Soldier:    "Resilient Ground Force"
        case .DevilDog:   "Elite & Tough"
        case .Sailor:     "Global Reach"
        case .Guardian:   "Semper Paratus"
        }
    }

    var tint: Color {
        switch self {
        case .HAZ:        Color(hex: "#3B82F6") ?? .blue
        case .Fusion:     Color(hex: "#F97316") ?? .orange
        case .Martensite: Color(hex: "#64748B") ?? .gray
        case .WeldPool:   Color(hex: "#0EA5E9") ?? .cyan
        case .RootPass:   Color(hex: "#B45309") ?? .brown
        case .Airman:     Color(hex: "#60A5FA") ?? .blue   // USAF silver-blue
        case .Soldier:    Color(hex: "#6B8E4E") ?? .green
        case .DevilDog:   Color(hex: "#9F1239") ?? .red
        case .Sailor:     Color(hex: "#3B82F6") ?? .blue
        case .Guardian:   Color(hex: "#FF6B35") ?? .orange // USCG International Orange
        }
    }

    // MARK: - Surface Colors (full role support)
    func surfaceColor(_ role: WorkspaceSurfaceRole) -> Color {
        switch self {
        case .HAZ:
            switch role {
            case .canvas:   return Color(hex: "#0B1220") ?? .black
            case .sidebar:  return Color(hex: "#1E2937") ?? .gray
            case .list:     return Color(hex: "#152030") ?? .black
            case .detail:   return Color(hex: "#192540") ?? .black
            case .chrome:   return Color(hex: "#1E2937") ?? .gray
            case .elevated: return Color(hex: "#253550") ?? .gray
            case .card:     return Color(hex: "#1C2E45") ?? .gray
            case .row:      return Color(hex: "#162535") ?? .black
            }
        case .Fusion:
            switch role {
            case .canvas:   return Color(hex: "#181614") ?? .black
            case .sidebar:  return Color(hex: "#292524") ?? .gray
            case .list:     return Color(hex: "#211E1C") ?? .black
            case .detail:   return Color(hex: "#252020") ?? .black
            case .chrome:   return Color(hex: "#292524") ?? .gray
            case .elevated: return Color(hex: "#332924") ?? .gray
            case .card:     return Color(hex: "#2C2320") ?? .gray
            case .row:      return Color(hex: "#1E1B19") ?? .black
            }
        case .Martensite:
            switch role {
            case .canvas:   return Color(hex: "#0D1117") ?? .black
            case .sidebar:  return Color(hex: "#1A2030") ?? .gray
            case .list:     return Color(hex: "#151B27") ?? .black
            case .detail:   return Color(hex: "#1B2133") ?? .black
            case .chrome:   return Color(hex: "#1A2030") ?? .gray
            case .elevated: return Color(hex: "#222A3C") ?? .gray
            case .card:     return Color(hex: "#1D2435") ?? .gray
            case .row:      return Color(hex: "#141924") ?? .black
            }
        case .WeldPool:
            switch role {
            case .canvas:   return Color(hex: "#091E1D") ?? .black
            case .sidebar:  return Color(hex: "#134E4B") ?? .teal
            case .list:     return Color(hex: "#0E3B38") ?? .black
            case .detail:   return Color(hex: "#0D2C29") ?? .black
            case .chrome:   return Color(hex: "#134E4B") ?? .teal
            case .elevated: return Color(hex: "#1A5E5B") ?? .teal
            case .card:     return Color(hex: "#154F4C") ?? .teal
            case .row:      return Color(hex: "#0F3835") ?? .black
            }
        case .RootPass:
            switch role {
            case .canvas:   return Color(hex: "#191714") ?? .black
            case .sidebar:  return Color(hex: "#2A2622") ?? .gray
            case .list:     return Color(hex: "#221E1B") ?? .black
            case .detail:   return Color(hex: "#26201D") ?? .black
            case .chrome:   return Color(hex: "#2A2622") ?? .gray
            case .elevated: return Color(hex: "#352822") ?? .gray
            case .card:     return Color(hex: "#2D2421") ?? .gray
            case .row:      return Color(hex: "#1F1C19") ?? .black
            }
        case .Airman: // USAF: deep midnight navy + silver-blue accents
            switch role {
            case .canvas:   return Color(hex: "#000C28") ?? .black
            case .sidebar:  return Color(hex: "#001848") ?? .blue
            case .list:     return Color(hex: "#001235") ?? .black
            case .detail:   return Color(hex: "#001B4A") ?? .black
            case .chrome:   return Color(hex: "#001F56") ?? .blue
            case .elevated: return Color(hex: "#002570") ?? .blue
            case .card:     return Color(hex: "#001C50") ?? .blue
            case .row:      return Color(hex: "#001030") ?? .black
            }
        case .Soldier:
            switch role {
            case .canvas:   return Color(hex: "#171C12") ?? .black
            case .sidebar:  return Color(hex: "#272F1F") ?? .green
            case .list:     return Color(hex: "#20281A") ?? .black
            case .detail:   return Color(hex: "#1D2417") ?? .black
            case .chrome:   return Color(hex: "#272F1F") ?? .green
            case .elevated: return Color(hex: "#2E3822") ?? .green
            case .card:     return Color(hex: "#273020") ?? .green
            case .row:      return Color(hex: "#1D2618") ?? .black
            }
        case .DevilDog:
            switch role {
            case .canvas:   return Color(hex: "#170D0D") ?? .black
            case .sidebar:  return Color(hex: "#2A1515") ?? .red
            case .list:     return Color(hex: "#221010") ?? .black
            case .detail:   return Color(hex: "#1F0E0E") ?? .black
            case .chrome:   return Color(hex: "#2A1515") ?? .red
            case .elevated: return Color(hex: "#331818") ?? .red
            case .card:     return Color(hex: "#2C1414") ?? .red
            case .row:      return Color(hex: "#1B0D0D") ?? .black
            }
        case .Sailor:
            switch role {
            case .canvas:   return Color(hex: "#080F1E") ?? .black
            case .sidebar:  return Color(hex: "#0F2744") ?? .blue
            case .list:     return Color(hex: "#0B1C35") ?? .black
            case .detail:   return Color(hex: "#0D2040") ?? .black
            case .chrome:   return Color(hex: "#0F2744") ?? .blue
            case .elevated: return Color(hex: "#142D52") ?? .blue
            case .card:     return Color(hex: "#102845") ?? .blue
            case .row:      return Color(hex: "#0A1A2E") ?? .black
            }
        case .Guardian: // USCG: deep navy + International Orange
            switch role {
            case .canvas:   return Color(hex: "#000B1E") ?? .black
            case .sidebar:  return Color(hex: "#00183A") ?? .blue
            case .list:     return Color(hex: "#00122D") ?? .black
            case .detail:   return Color(hex: "#001A40") ?? .black
            case .chrome:   return Color(hex: "#001D48") ?? .blue
            case .elevated: return Color(hex: "#002460") ?? .blue
            case .card:     return Color(hex: "#001B45") ?? .blue
            case .row:      return Color(hex: "#000F28") ?? .black
            }
        }
    }

    var primaryTextColor: Color {
        Color.white.opacity(0.92)
    }

    var secondaryTextColor: Color {
        switch self {
        case .Airman:     Color(hex: "#93C5FD") ?? .blue    // USAF silver-blue
        case .Guardian:   Color(hex: "#FF9B6A") ?? .orange  // USCG light orange
        case .Soldier:    Color(hex: "#6B8E4E") ?? .green
        case .DevilDog:   Color(hex: "#8B3A3A") ?? .red
        case .Sailor:     Color(hex: "#60A5FA") ?? .blue
        case .HAZ:        Color.white.opacity(0.75)
        case .Fusion:     Color.white.opacity(0.75)
        case .Martensite: Color.white.opacity(0.75)
        case .WeldPool:   Color.white.opacity(0.75)
        case .RootPass:   Color.white.opacity(0.75)
        }
    }

    var tertiaryTextColor: Color {
        Color.white.opacity(0.45)
    }

    // MARK: - Card Chrome

    var strokeColor: Color { Color.white.opacity(0.08) }
    var strokeWidth: CGFloat { 0.5 }
    var cardShadowColor: Color { Color.black.opacity(0.22) }
    var cardShadowRadius: CGFloat { 4 }
    var cardShadowY: CGFloat { 2 }
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
