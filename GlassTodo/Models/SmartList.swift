import Foundation

enum SmartList: String, CaseIterable, Identifiable {
    case all       = "All"
    case today     = "Today"
    case completed = "Completed"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all:       return "tray.full"
        case .today:     return "calendar"
        case .completed: return "checkmark.circle"
        }
    }

    func filter(_ todos: [Todo]) -> [Todo] {
        switch self {
        case .all:
            return todos.filter { !$0.isDone }
                .sorted { ($0.priority, $0.createdAt) > ($1.priority, $1.createdAt) }
        case .today:
            return todos.filter { $0.isDueToday && !$0.isDone }
                .sorted { $0.priority > $1.priority }
        case .completed:
            return todos.filter { $0.isDone }
                .sorted { ($0.completedAt ?? $0.createdAt) > ($1.completedAt ?? $1.createdAt) }
        }
    }
}
