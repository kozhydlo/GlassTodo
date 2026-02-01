import SwiftUI

struct QuickAddBar: View {
    @EnvironmentObject var tm: ThemeManager
    @ObservedObject var vm: TodoViewModel

    @State private var text = ""
    @FocusState private var focused: Bool
    let onExpandTap: () -> Void

    var body: some View {
        let t = tm.current

        HStack(spacing: 10) {
            // Quick text field
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(t.accent)

                TextField("Quick add task...", text: $text)
                    .font(.subheadline)
                    .foregroundColor(t.textPrimary)
                    .textFieldStyle(.plain)
                    .focused($focused)
                    .submitLabel(.done)
                    .onSubmit { quickAdd() }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(t.usesGlass ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(t.cardBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: -2)

            // Expand button (full add sheet)
            if focused || !text.isEmpty {
                Button {
                    focused = false
                    onExpandTap()
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(t.accent)
                        .frame(width: 38, height: 38)
                        .background(t.accent.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            t.backgroundColor.opacity(0.95)
                .shadow(.drop(color: .black.opacity(0.05), radius: 12, x: 0, y: -4))
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: focused)
    }

    private func quickAdd() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        vm.add(title: text)
        text = ""
        focused = false
    }
}
