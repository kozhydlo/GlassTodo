import SwiftUI

@main
struct GlassTodoApp: App {
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.themeType.colorScheme)
        }
    }
}
