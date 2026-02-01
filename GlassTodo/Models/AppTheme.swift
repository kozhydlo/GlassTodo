import SwiftUI

// MARK: - Theme Types
enum AppThemeType: String, Codable, CaseIterable, Identifiable {
    case system       = "System"
    case light        = "Light"
    case dark         = "Dark"
    case softGlass    = "Soft Glass"
    case highContrast = "High Contrast"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .system:       return "Follows device"
        case .light:        return "Clean & minimal"
        case .dark:         return "Easy on the eyes"
        case .softGlass:    return "Subtle blur effects"
        case .highContrast: return "Maximum readability"
        }
    }

    var icon: String {
        switch self {
        case .system:       return "circle.lefthalf.filled"
        case .light:        return "sun.max"
        case .dark:         return "moon"
        case .softGlass:    return "drop"
        case .highContrast: return "textformat.size.larger"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:                     return nil
        case .light, .softGlass:          return .light
        case .dark:                       return .dark
        case .highContrast:               return .dark
        }
    }

    var usesGlass: Bool { self == .softGlass }
}

// MARK: - Resolved Theme
struct AppTheme {
    let type: AppThemeType

    // MARK: Backgrounds
    var backgroundColor: Color {
        switch type {
        case .system, .light, .softGlass:
            return Color(uiColor: .systemGroupedBackground)
        case .dark:
            return Color(uiColor: .systemBackground)
        case .highContrast:
            return .black
        }
    }

    var secondaryBackground: Color {
        switch type {
        case .system, .light, .softGlass:
            return Color(uiColor: .secondarySystemGroupedBackground)
        case .dark:
            return Color(uiColor: .secondarySystemBackground)
        case .highContrast:
            return Color(white: 0.1)
        }
    }

    // MARK: Text
    var textPrimary: Color {
        switch type {
        case .highContrast: return .white
        default:            return Color(uiColor: .label)
        }
    }

    var textSecondary: Color {
        switch type {
        case .highContrast: return Color(white: 0.75)
        default:            return Color(uiColor: .secondaryLabel)
        }
    }

    var textTertiary: Color {
        switch type {
        case .highContrast: return Color(white: 0.55)
        default:            return Color(uiColor: .tertiaryLabel)
        }
    }

    // MARK: Accent
    var accent: Color {
        switch type {
        case .highContrast: return .yellow
        default:            return Color(red: 0.25, green: 0.50, blue: 0.95)
        }
    }

    var accentSecondary: Color {
        switch type {
        case .highContrast: return .cyan
        default:            return Color(red: 0.35, green: 0.72, blue: 0.60)
        }
    }

    // MARK: Category Colors (resolved from semantic names)
    func categoryColor(_ category: TodoCategory) -> Color {
        switch category {
        case .personal: return Color(red: 0.35, green: 0.55, blue: 0.95)
        case .work:     return Color(red: 0.90, green: 0.55, blue: 0.25)
        case .health:   return Color(red: 0.90, green: 0.35, blue: 0.40)
        case .learning: return Color(red: 0.60, green: 0.45, blue: 0.90)
        case .errands:  return Color(red: 0.35, green: 0.72, blue: 0.55)
        }
    }

    func priorityColor(_ priority: TodoPriority) -> Color {
        switch priority {
        case .low:    return accentSecondary
        case .medium: return accent
        case .high:   return Color(red: 0.90, green: 0.30, blue: 0.30)
        }
    }

    // MARK: Card
    var cardBackground: Color {
        switch type {
        case .highContrast: return Color(white: 0.12)
        default:            return secondaryBackground
        }
    }

    var cardMaterial: Material { .regularMaterial }
    var cornerRadius: CGFloat { 14 }
    var usesGlass: Bool { type.usesGlass }
}
