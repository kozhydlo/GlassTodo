import SwiftUI

struct TodoRow: View {
    @EnvironmentObject var tm: ThemeManager
    @ObservedObject var vm: TodoViewModel
    let todo: Todo

    @State private var checkBounce: CGFloat = 1.0
    @State private var offset: CGFloat = 0
    @State private var showDelete = false
    @State private var showDetail = false
    @State private var appeared = false

    var body: some View {
        let t = tm.current

        ZStack(alignment: .trailing) {
            if showDelete || offset < -5 {
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            vm.delete(todo)
                        }
                    } label: {
                        Image(systemName: "trash.fill")
                            .font(.body.weight(.medium))
                            .foregroundColor(.white)
                            .frame(width: 52, height: 52)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: t.cornerRadius, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }

            CardView {
                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) {
                                vm.toggle(todo)
                                checkBounce = 1.25
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                                    checkBounce = 1.0
                                }
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .stroke(
                                        todo.isDone ? t.accent : t.categoryColor(todo.category).opacity(0.5),
                                        lineWidth: 1.5
                                    )
                                    .frame(width: 24, height: 24)

                                if todo.isDone {
                                    Circle()
                                        .fill(t.accent)
                                        .frame(width: 24, height: 24)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .scaleEffect(checkBounce)
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(todo.title)
                                .font(.subheadline.weight(.regular))
                                .foregroundColor(todo.isDone ? t.textTertiary : t.textPrimary)
                                .strikethrough(todo.isDone, color: t.textTertiary)
                                .lineLimit(2)

                            HStack(spacing: 8) {
                                HStack(spacing: 3) {
                                    Circle()
                                        .fill(t.categoryColor(todo.category))
                                        .frame(width: 6, height: 6)
                                    Text(todo.category.rawValue)
                                        .font(.caption2)
                                        .foregroundColor(t.textTertiary)
                                }

                                if todo.priority == .high {
                                    HStack(spacing: 2) {
                                        Image(systemName: "exclamationmark")
                                            .font(.system(size: 8, weight: .bold))
                                        Text("High")
                                            .font(.caption2.weight(.medium))
                                    }
                                    .foregroundColor(t.priorityColor(.high))
                                }

                                if let due = todo.dueDate {
                                    HStack(spacing: 2) {
                                        Image(systemName: "clock")
                                            .font(.system(size: 8))
                                        Text(formatDue(due))
                                            .font(.caption2)
                                    }
                                    .foregroundColor(todo.isOverdue ? .red : t.textTertiary)
                                }

                                if todo.hasSubtasks {
                                    HStack(spacing: 2) {
                                        Image(systemName: "list.bullet")
                                            .font(.system(size: 8))
                                        Text("\(todo.subtasks.filter(\.isDone).count)/\(todo.subtasks.count)")
                                            .font(.caption2.weight(.medium))
                                    }
                                    .foregroundColor(t.textTertiary)
                                }

                                if !todo.notes.isEmpty {
                                    Image(systemName: "note.text")
                                        .font(.system(size: 8))
                                        .foregroundColor(t.textTertiary)
                                }
                            }
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(t.textTertiary.opacity(0.4))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)

                    if todo.hasSubtasks && !todo.isDone {
                        GeometryReader { geo in
                            Capsule()
                                .fill(t.accent.opacity(0.6))
                                .frame(width: geo.size.width * todo.subtaskProgress, height: 2)
                                .animation(.spring(response: 0.4), value: todo.subtaskProgress)
                        }
                        .frame(height: 2)
                    }
                }
            }
            .offset(x: offset)
            .contentShape(Rectangle())
            .onTapGesture {
                if showDelete {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        offset = 0; showDelete = false
                    }
                } else {
                    showDetail = true; Haptic.light()
                }
            }
            .gesture(
                DragGesture(minimumDistance: 25)
                    .onChanged { v in
                        if v.translation.width < 0 { offset = v.translation.width * 0.5 }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if offset < -60 {
                                showDelete = true; offset = -65; Haptic.warning()
                            } else {
                                offset = 0; showDelete = false
                            }
                        }
                    }
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.03)) {
                appeared = true
            }
        }
        .contextMenu {
            Button { showDetail = true; Haptic.light() } label: {
                Label("Details", systemImage: "info.circle")
            }
            Menu {
                ForEach(TodoCategory.allCases) { cat in
                    Button { vm.updateCategory(todo, category: cat) } label: {
                        Label(cat.rawValue, systemImage: cat.icon)
                    }
                }
            } label: { Label("Category", systemImage: "tag") }
            Menu {
                ForEach(TodoPriority.allCases) { p in
                    Button { vm.updatePriority(todo, priority: p) } label: {
                        Label(p.label, systemImage: p.icon)
                    }
                }
            } label: { Label("Priority", systemImage: "flag") }
            Divider()
            Button { withAnimation { vm.toggle(todo) } } label: {
                Label(todo.isDone ? "Mark Active" : "Mark Done",
                      systemImage: todo.isDone ? "arrow.uturn.backward" : "checkmark")
            }
            Button(role: .destructive) { withAnimation { vm.delete(todo) } } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showDetail) {
            TodoDetailSheet(vm: vm, todo: todo)
                .environmentObject(tm)
        }
    }

    private func formatDue(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInTomorrow(date) { return "Tomorrow" }
        let f = DateFormatter()
        f.dateFormat = "d MMM"
        return f.string(from: date)
    }
}
