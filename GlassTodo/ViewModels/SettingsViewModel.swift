import SwiftUI
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var userName: String
    @Published var showReset = false

    private let storage = StorageService.shared

    init() {
        self.userName = storage.loadProfile()?.displayName ?? "User"
    }

    func saveName(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        userName = trimmed
        if var p = storage.loadProfile() {
            p.displayName = trimmed
            storage.saveProfile(p)
        }
        Haptic.selection()
    }

    func resetApp() {
        storage.resetAll()
        Haptic.heavy()
    }
}
