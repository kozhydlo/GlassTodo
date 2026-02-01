import Foundation

final class StorageService {
    static let shared = StorageService()

    private let fm = FileManager.default
    private let defaults = UserDefaults.standard

    private enum Key {
        static let onboarding = "gt_onboarding_done"
        static let profile    = "gt_user_profile"
        static let theme      = "gt_theme"
    }

    private var todosURL: URL {
        fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("todos_v2.json")
    }

    private init() {}

    // MARK: Todos
    func saveTodos(_ todos: [Todo]) {
        do {
            let data = try JSONEncoder().encode(todos)
            try data.write(to: todosURL, options: .atomic)
        } catch {
            print("[Storage] save todos failed: \(error)")
        }
    }

    func loadTodos() -> [Todo] {
        guard fm.fileExists(atPath: todosURL.path) else { return [] }
        do {
            let data = try Data(contentsOf: todosURL)
            return try JSONDecoder().decode([Todo].self, from: data)
        } catch {
            print("[Storage] load todos failed: \(error)")
            return []
        }
    }

    // MARK: Onboarding
    var isOnboardingDone: Bool {
        get { defaults.bool(forKey: Key.onboarding) }
        set { defaults.set(newValue, forKey: Key.onboarding) }
    }

    // MARK: Profile
    func saveProfile(_ p: UserProfile) {
        if let d = try? JSONEncoder().encode(p) { defaults.set(d, forKey: Key.profile) }
    }

    func loadProfile() -> UserProfile? {
        guard let d = defaults.data(forKey: Key.profile) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: d)
    }

    // MARK: Theme
    func saveTheme(_ t: AppThemeType) { defaults.set(t.rawValue, forKey: Key.theme) }

    func loadTheme() -> AppThemeType {
        guard let r = defaults.string(forKey: Key.theme),
              let t = AppThemeType(rawValue: r) else { return .system }
        return t
    }

    // MARK: Reset
    func resetAll() {
        try? fm.removeItem(at: todosURL)
        [Key.onboarding, Key.profile, Key.theme].forEach { defaults.removeObject(forKey: $0) }
    }
}
