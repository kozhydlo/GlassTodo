import Foundation

struct UserProfile: Codable, Equatable {
    var displayName: String
    var selectedTheme: AppThemeType

    init(displayName: String = "", selectedTheme: AppThemeType = .system) {
        self.displayName = displayName
        self.selectedTheme = selectedTheme
    }
}
