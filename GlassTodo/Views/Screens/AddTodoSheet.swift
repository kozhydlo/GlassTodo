import SwiftUI

struct AddTodoSheet: View {
    @EnvironmentObject var tm: ThemeManager
    @ObservedObject var vm: TodoViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var category: TodoCategory = .personal
    @State private var priority: TodoPriority = .medium
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var subtaskTexts: [String] = [""]
    @State private var notes = ""
    @FocusState private var focused: Bool

    var body: some View {
        let t = tm.current

        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Task")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(t.textTertiary)
                            .textCase(.uppercase)

                        CardView {
                            TextField("What needs to be done?", text: $title)
                                .font(.body)
                                .foregroundColor(t.textPrimary)
                                .padding(14)
                                .focused($focused)
                                .submitLabel(.done)
                                .onSubmit { addTask() }
                        }
                        .environmentObject(tm)
                    }

                    // Category
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Category")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(t.textTertiary)
                            .textCase(.uppercase)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(TodoCategory.allCases) { cat in
                                    Button {
                                        category = cat
                                        Haptic.selection()
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: cat.icon)
                                                .font(.system(size: 12, weight: .semibold))
                                            Text(cat.rawValue)
                                                .font(.subheadline.weight(.medium))
                                        }
                                        .foregroundColor(category == cat ? .white : t.textSecondary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 9)
                                        .background(
                                            category == cat
                                            ? t.categoryColor(cat)
                                            : t.textSecondary.opacity(0.08)
                                        )
                                        .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    // Priority
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Priority")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(t.textTertiary)
                            .textCase(.uppercase)

                        HStack(spacing: 8) {
                            ForEach(TodoPriority.allCases) { p in
                                Button {
                                    priority = p
                                    Haptic.selection()
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: p.icon)
                                            .font(.system(size: 11, weight: .bold))
                                        Text(p.label)
                                            .font(.subheadline.weight(.medium))
                                    }
                                    .foregroundColor(priority == p ? .white : t.textSecondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 9)
                                    .background(
                                        priority == p
                                        ? t.priorityColor(p)
                                        : t.textSecondary.opacity(0.08)
                                    )
                                    .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                            Spacer()
                        }
                    }

                    // Due date
                    VStack(alignment: .leading, spacing: 6) {
                        Toggle(isOn: $hasDueDate.animation(.easeInOut(duration: 0.2))) {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(t.accent)
                                Text("Due date")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(t.textPrimary)
                            }
                        }
                        .tint(t.accent)

                        if hasDueDate {
                            DatePicker("", selection: $dueDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(t.accent)
                                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                        }
                    }

                    // Subtasks
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Subtasks")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(t.textTertiary)
                            .textCase(.uppercase)

                        ForEach(subtaskTexts.indices, id: \.self) { i in
                            HStack(spacing: 8) {
                                Circle()
                                    .stroke(t.textTertiary, lineWidth: 1)
                                    .frame(width: 16, height: 16)

                                TextField("Subtask", text: $subtaskTexts[i])
                                    .font(.subheadline)
                                    .foregroundColor(t.textPrimary)
                                    .textFieldStyle(.plain)
                                    .onSubmit {
                                        if i == subtaskTexts.count - 1 && !subtaskTexts[i].isEmpty {
                                            subtaskTexts.append("")
                                        }
                                    }

                                if subtaskTexts.count > 1 {
                                    Button {
                                        subtaskTexts.remove(at: i)
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundColor(t.textTertiary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 4)
                        }

                        Button {
                            subtaskTexts.append("")
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .semibold))
                                Text("Add subtask")
                                    .font(.caption.weight(.medium))
                            }
                            .foregroundColor(t.accent)
                        }
                        .buttonStyle(.plain)
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notes")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(t.textTertiary)
                            .textCase(.uppercase)

                        TextEditor(text: $notes)
                            .font(.subheadline)
                            .foregroundColor(t.textPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 60)
                            .padding(10)
                            .background(t.textTertiary.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
                .padding(20)
            }
            .background(t.backgroundColor.ignoresSafeArea())
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(t.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addTask() }
                        .font(.body.weight(.semibold))
                        .foregroundColor(t.accent)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { focused = true }
        }
        .presentationDetents([.large])
    }

    private func addTask() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let subs = subtaskTexts
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { Subtask(title: $0) }
        vm.add(title: trimmed, category: category, priority: priority,
               dueDate: hasDueDate ? dueDate : nil,
               subtasks: subs, notes: notes.trimmingCharacters(in: .whitespacesAndNewlines))
        dismiss()
    }
}
