import SwiftUI
import Combine

final class OnboardingViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var selectedTheme: AppThemeType = .system
    @Published var page: Int = 0

    let totalPages = 3

    var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func complete(themeManager: ThemeManager) {
        let profile = UserProfile(
            displayName: name.trimmingCharacters(in: .whitespaces),
            selectedTheme: selectedTheme
        )
        StorageService.shared.saveProfile(profile)
        StorageService.shared.isOnboardingDone = true
        themeManager.set(selectedTheme)
        Haptic.success()
    }

    func next() {
        guard page < totalPages - 1 else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { page += 1 }
        Haptic.light()
    }

    func back() {
        guard page > 0 else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { page -= 1 }
        Haptic.light()
    }
}
