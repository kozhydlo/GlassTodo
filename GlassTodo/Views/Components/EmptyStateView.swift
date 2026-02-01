import SwiftUI

struct EmptyStateView: View {
    @EnvironmentObject var tm: ThemeManager
    let list: SmartList
    @State private var pulse = false

    var body: some View {
        let t = tm.current

        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 44, weight: .light))
                .foregroundColor(t.textTertiary)
                .scaleEffect(pulse ? 1.06 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulse)

            Text(title)
                .font(.headline)
                .foregroundColor(t.textPrimary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(t.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)
        }
        .padding(.vertical, 48)
        .frame(maxWidth: .infinity)
        .onAppear { pulse = true }
    }

    private var icon: String {
        switch list {
        case .all:       return "tray"
        case .today:     return "sun.max"
        case .completed: return "party.popper"
        }
    }

    private var title: String {
        switch list {
        case .all:       return "No tasks yet"
        case .today:     return "Nothing for today"
        case .completed: return "Nothing completed yet"
        }
    }

    private var subtitle: String {
        switch list {
        case .all:       return "Tap + to add your first task"
        case .today:     return "Tasks with today's due date will show here"
        case .completed: return "Completed tasks will appear here"
        }
    }
}
