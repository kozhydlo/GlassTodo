import SwiftUI

struct TodoDetailSheet: View {
    @EnvironmentObject var tm: ThemeManager
    @ObservedObject var vm: TodoViewModel
    @Environment(\.dismiss) private var dismiss

    let todo: Todo

    @State private var newSubtask = ""
    @State private var notes: String = ""
    @FocusState private var subtaskFocused: Bool

    var body: some View {
        let t = tm.current

        // Find the live version of this todo
        let liveTodo = vm.todos.first(where: { $0.id == todo.id }) ?? todo

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Status + Category
                    HStack(spacing: 10) {
                        // Category badge
                        HStack(spacing: 5) {
                            Image(systemName: liveTodo.category.icon)
                                .font(.system(size: 11, weight: .semibold))
                            Text(liveTodo.category.rawValue)
                                .font(.caption.weight(.medium))
                        }
                        .foregroundColor(t.categoryColor(liveTodo.category))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(t.categoryColor(liveTodo.category).opacity(0.1))
                        .clipShape(Capsule())

                        // Priority badge
                        HStack(spacing: 4) {
                            Image(systemName: liveTodo.priority.icon)
                                .font(.system(size: 10, weight: .bold))
                            Text(liveTodo.priority.label)
                                .font(.caption.weight(.medium))
                        }
                        .foregroundColor(t.priorityColor(liveTodo.priority))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(t.priorityColor(liveTodo.priority).opacity(0.1))
                        .clipShape(Capsule())

                        // Done badge
                        if liveTodo.isDone {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                Text("Done")
                                    .font(.caption.weight(.medium))
                            }
                            .foregroundColor(t.accentSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(t.accentSecondary.opacity(0.1))
                            .clipShape(Capsule())
                        }

                        Spacer()
                    }

                    // Due date
                    if let due = liveTodo.dueDate {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 13))
                            Text("Due: \(due, style: .date)")
                                .font(.subheadline)
                        }
                        .foregroundColor(liveTodo.isOverdue ? .red : t.textSecondary)
                    }

                    // Created
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        Text("Created \(liveTodo.createdAt, style: .relative) ago")
                            .font(.caption)
                    }
                    .foregroundColor(t.textTertiary)

                    Divider()

                    // MARK: Subtasks
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Subtasks")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(t.textPrimary)
                            Spacer()
                            if liveTodo.hasSubtasks {
                                Text("\(liveTodo.subtasks.filter(\.isDone).count)/\(liveTodo.subtasks.count)")
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(t.textTertiary)
                            }
                        }

                        // Subtask progress bar
                        if liveTodo.hasSubtasks {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(t.textTertiary.opacity(0.1))
                                        .frame(height: 4)
                                    Capsule()
                                        .fill(t.accent)
                                        .frame(width: geo.size.width * liveTodo.subtaskProgress, height: 4)
                                        .animation(.spring(response: 0.4), value: liveTodo.subtaskProgress)
                                }
                            }
                            .frame(height: 4)
                        }

                        // Existing subtasks
                        ForEach(liveTodo.subtasks) { sub in
                            HStack(spacing: 10) {
                                Button {
                                    vm.toggleSubtask(liveTodo, subtaskId: sub.id)
                                } label: {
                                    Image(systemName: sub.isDone ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 16))
                                        .foregroundColor(sub.isDone ? t.accent : t.textTertiary)
                                }
                                .buttonStyle(.plain)

                                Text(sub.title)
                                    .font(.subheadline)
                                    .foregroundColor(sub.isDone ? t.textTertiary : t.textPrimary)
                                    .strikethrough(sub.isDone, color: t.textTertiary)

                                Spacer()

                                Button {
                                    vm.deleteSubtask(liveTodo, subtaskId: sub.id)
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(t.textTertiary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 4)
                        }

                        // Add subtask
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 16))
                                .foregroundColor(t.textTertiary)

                            TextField("Add subtask...", text: $newSubtask)
                                .font(.subheadline)
                                .foregroundColor(t.textPrimary)
                                .textFieldStyle(.plain)
                                .focused($subtaskFocused)
                                .onSubmit {
                                    vm.addSubtask(liveTodo, title: newSubtask)
                                    newSubtask = ""
                                }
                        }
                        .padding(.vertical, 4)
                    }

                    Divider()

                    // MARK: Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(t.textPrimary)

                        TextEditor(text: $notes)
                            .font(.subheadline)
                            .foregroundColor(t.textPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 80)
                            .padding(10)
                            .background(t.textTertiary.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .onChange(of: notes) { _, newValue in
                                vm.updateNotes(liveTodo, notes: newValue)
                            }
                    }
                }
                .padding(20)
            }
            .background(t.backgroundColor.ignoresSafeArea())
            .navigationTitle(liveTodo.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(t.accent)
                }
            }
        }
        .onAppear { notes = todo.notes }
    }
}
