import SwiftUI

struct CategoryFilter: View {
    @EnvironmentObject var tm: ThemeManager
    @Binding var selected: TodoCategory?

    var body: some View {
        let t = tm.current

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "All" chip
                chipButton(
                    label: "All",
                    icon: "square.grid.2x2",
                    isSelected: selected == nil,
                    color: t.accent
                ) {
                    selected = nil
                }

                ForEach(TodoCategory.allCases) { cat in
                    chipButton(
                        label: cat.rawValue,
                        icon: cat.icon,
                        isSelected: selected == cat,
                        color: t.categoryColor(cat)
                    ) {
                        selected = (selected == cat) ? nil : cat
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func chipButton(label: String, icon: String, isSelected: Bool,
                            color: Color, action: @escaping () -> Void) -> some View {
        let t = tm.current
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { action() }
            Haptic.selection()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
                Text(label)
                    .font(.caption.weight(.medium))
            }
            .foregroundColor(isSelected ? .white : t.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? color : t.textSecondary.opacity(0.06))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
