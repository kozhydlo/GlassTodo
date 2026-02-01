import SwiftUI
import Combine

final class ThemeManager: ObservableObject {
    @Published var themeType: AppThemeType {
        didSet { StorageService.shared.saveTheme(themeType) }
    }

    var current: AppTheme { AppTheme(type: themeType) }

    init() {
        self.themeType = StorageService.shared.loadTheme()
    }

    func set(_ type: AppThemeType) {
        withAnimation(.easeInOut(duration: 0.3)) { themeType = type }
        Haptic.selection()
    }
}
