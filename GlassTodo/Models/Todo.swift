import Foundation

// MARK: - Category
enum TodoCategory: String, Codable, CaseIterable, Identifiable {
    case personal   = "Personal"
    case work       = "Work"
    case health     = "Health"
    case learning   = "Learning"
    case errands    = "Errands"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .personal: return "person.fill"
        case .work:     return "briefcase.fill"
        case .health:   return "heart.fill"
        case .learning: return "book.fill"
        case .errands:  return "cart.fill"
        }
    }

    var color: String {
        switch self {
        case .personal: return "categoryPersonal"
        case .work:     return "categoryWork"
        case .health:   return "categoryHealth"
        case .learning: return "categoryLearning"
        case .errands:  return "categoryErrands"
        }
    }
}

// MARK: - Priority
enum TodoPriority: Int, Codable, CaseIterable, Identifiable, Comparable {
    case low    = 0
    case medium = 1
    case high   = 2

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .low:    return "Low"
        case .medium: return "Medium"
        case .high:   return "High"
        }
    }

    var icon: String {
        switch self {
        case .low:    return "arrow.down"
        case .medium: return "equal"
        case .high:   return "exclamationmark"
        }
    }

    static func < (lhs: TodoPriority, rhs: TodoPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Subtask
struct Subtask: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isDone: Bool

    init(id: UUID = UUID(), title: String, isDone: Bool = false) {
        self.id = id
        self.title = title
        self.isDone = isDone
    }
}

// MARK: - Todo
struct Todo: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isDone: Bool
    var category: TodoCategory
    var priority: TodoPriority
    var dueDate: Date?
    let createdAt: Date
    var completedAt: Date?
    var subtasks: [Subtask]
    var notes: String

    init(
        id: UUID = UUID(),
        title: String,
        isDone: Bool = false,
        category: TodoCategory = .personal,
        priority: TodoPriority = .medium,
        dueDate: Date? = nil,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        subtasks: [Subtask] = [],
        notes: String = ""
    ) {
        self.id = id
        self.title = title
        self.isDone = isDone
        self.category = category
        self.priority = priority
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.subtasks = subtasks
        self.notes = notes
    }

    var isOverdue: Bool {
        guard let due = dueDate, !isDone else { return false }
        return due < Date()
    }

    var isDueToday: Bool {
        guard let due = dueDate else { return false }
        return Calendar.current.isDateInToday(due)
    }

    var subtaskProgress: Double {
        guard !subtasks.isEmpty else { return 0 }
        return Double(subtasks.filter(\.isDone).count) / Double(subtasks.count)
    }

    var hasSubtasks: Bool { !subtasks.isEmpty }
}
