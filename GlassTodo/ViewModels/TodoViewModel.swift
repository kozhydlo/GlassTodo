import Foundation
import Combine

final class TodoViewModel: ObservableObject {
    @Published private(set) var todos: [Todo] = []
    @Published var searchText: String = ""
    @Published var activeList: SmartList = .all
    @Published var focusMode: Bool = false
    @Published var selectedCategory: TodoCategory? = nil

    private let storage = StorageService.shared

    // MARK: Computed
    var filteredTodos: [Todo] {
        var result = activeList.filter(todos)

        if let cat = selectedCategory {
            result = result.filter { $0.category == cat }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { $0.title.lowercased().contains(query) }
        }

        if focusMode {
            result = result.filter { !$0.isDone }
        }

        return result
    }

    var todayCount: Int {
        todos.filter { $0.isDueToday && !$0.isDone }.count
    }

    var activeCount: Int {
        todos.filter { !$0.isDone }.count
    }

    var completedCount: Int {
        todos.filter { $0.isDone }.count
    }

    var totalCount: Int { todos.count }

    var completionRate: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    var overdueCount: Int {
        todos.filter { $0.isOverdue }.count
    }

    // Stats: completed this week
    var completedThisWeek: Int {
        let cal = Calendar.current
        let startOfWeek = cal.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return todos.filter {
            $0.isDone && ($0.completedAt ?? $0.createdAt) >= startOfWeek
        }.count
    }

    // Category breakdown
    var categoryBreakdown: [(TodoCategory, Int)] {
        TodoCategory.allCases.compactMap { cat in
            let count = todos.filter { $0.category == cat && !$0.isDone }.count
            return count > 0 ? (cat, count) : nil
        }
    }

    // Streak: consecutive days with at least 1 completion
    var currentStreak: Int {
        let cal = Calendar.current
        let completedDates = Set(
            todos.compactMap { $0.completedAt }
                .map { cal.startOfDay(for: $0) }
        )
        var streak = 0
        var day = cal.startOfDay(for: Date())

        while completedDates.contains(day) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }

    // Weekly heatmap: last 7 days → completed count per day
    var weeklyHeatmap: [(String, Int)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        return (0..<7).reversed().map { daysAgo in
            let day = cal.date(byAdding: .day, value: -daysAgo, to: today)!
            let count = todos.filter {
                guard let c = $0.completedAt else { return false }
                return cal.isDate(c, inSameDayAs: day)
            }.count
            return (formatter.string(from: day), count)
        }
    }

    var maxWeeklyCount: Int {
        max(weeklyHeatmap.map(\.1).max() ?? 1, 1)
    }

    // Motivational quote based on state
    var motivationalMessage: String {
        if todos.isEmpty {
            return quotes.randomElement() ?? ""
        }
        if activeCount == 0 && completedCount > 0 {
            return celebrationMessages.randomElement() ?? ""
        }
        if currentStreak >= 7 {
            return "🔥 \(currentStreak)-day streak! You're unstoppable."
        }
        if overdueCount > 0 {
            return "You have \(overdueCount) overdue — tackle them first!"
        }
        if todayCount > 0 {
            return "\(todayCount) task\(todayCount == 1 ? "" : "s") due today. You got this!"
        }
        return quotes.randomElement() ?? ""
    }

    private var quotes: [String] {[
        "Small steps every day lead to big changes.",
        "Focus on progress, not perfection.",
        "The secret of getting ahead is getting started.",
        "One task at a time. You've got this.",
        "Discipline is choosing what you want most over what you want now.",
        "Done is better than perfect."
    ]}

    private var celebrationMessages: [String] {[
        "🎉 All tasks complete! Take a well-deserved break.",
        "✨ Inbox zero achieved. You're amazing!",
        "🏆 Everything's done. What a productive day!",
        "💪 All clear! Time to set new goals."
    ]}

    // MARK: Init
    init() { todos = storage.loadTodos() }

    // MARK: CRUD
    func add(title: String, category: TodoCategory = .personal,
             priority: TodoPriority = .medium, dueDate: Date? = nil,
             subtasks: [Subtask] = [], notes: String = "") {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let todo = Todo(title: trimmed, category: category,
                        priority: priority, dueDate: dueDate,
                        subtasks: subtasks, notes: notes)
        todos.insert(todo, at: 0)
        save()
        Haptic.success()
    }

    func toggle(_ todo: Todo) {
        guard let i = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[i].isDone.toggle()
        todos[i].completedAt = todos[i].isDone ? Date() : nil
        save()
        Haptic.light()
    }

    func update(_ todo: Todo, title: String) {
        guard let i = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[i].title = title.trimmingCharacters(in: .whitespaces)
        save()
    }

    func updateCategory(_ todo: Todo, category: TodoCategory) {
        guard let i = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[i].category = category
        save()
        Haptic.selection()
    }

    func updatePriority(_ todo: Todo, priority: TodoPriority) {
        guard let i = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[i].priority = priority
        save()
        Haptic.selection()
    }

    func delete(_ todo: Todo) {
        todos.removeAll { $0.id == todo.id }
        save()
        Haptic.warning()
    }

    func toggleSubtask(_ todo: Todo, subtaskId: UUID) {
        guard let i = todos.firstIndex(where: { $0.id == todo.id }),
              let si = todos[i].subtasks.firstIndex(where: { $0.id == subtaskId }) else { return }
        todos[i].subtasks[si].isDone.toggle()
        save()
        Haptic.light()
    }

    func addSubtask(_ todo: Todo, title: String) {
        guard let i = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        todos[i].subtasks.append(Subtask(title: trimmed))
        save()
        Haptic.light()
    }

    func deleteSubtask(_ todo: Todo, subtaskId: UUID) {
        guard let i = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[i].subtasks.removeAll { $0.id == subtaskId }
        save()
    }

    func updateNotes(_ todo: Todo, notes: String) {
        guard let i = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[i].notes = notes
        save()
    }

    private func save() { storage.saveTodos(todos) }
}
