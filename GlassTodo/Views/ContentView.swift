import SwiftUI

struct ContentView: View {
    @EnvironmentObject var tm: ThemeManager
    @State private var showOnboarding: Bool

    init() {
        _showOnboarding = State(initialValue: !StorageService.shared.isOnboardingDone)
    }

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showOnboarding = false
                    }
                }
                .environmentObject(tm)
                .transition(.opacity)
            } else {
                HomeView()
                    .environmentObject(tm)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showOnboarding)
    }
}
