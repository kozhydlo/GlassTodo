import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var tm: ThemeManager
    @Binding var showSearch: Bool
    @Binding var showSettings: Bool
    @Binding var showAdd: Bool

    var body: some View {
        let t = tm.current

        HStack(spacing: 16) {
            // Date chip
            VStack(alignment: .leading, spacing: 1) {
                Text(dayOfWeek)
                    .font(.caption2.weight(.medium))
                    .foregroundColor(t.textTertiary)
                    .textCase(.uppercase)
                Text(dateString)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(t.textPrimary)
            }

            Spacer()

            // Action buttons
            HStack(spacing: 4) {
                headerButton(icon: "magnifyingglass") {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showSearch.toggle()
                    }
                    Haptic.light()
                }

                headerButton(icon: "plus") {
                    showAdd = true
                    Haptic.light()
                }

                headerButton(icon: "gearshape") {
                    showSettings = true
                    Haptic.light()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    private func headerButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(tm.current.textSecondary)
                .frame(width: 36, height: 36)
                .background(tm.current.textSecondary.opacity(0.08))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var dayOfWeek: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "uk_UA")
        f.dateFormat = "EEEE"
        return f.string(from: Date())
    }

    private var dateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "uk_UA")
        f.dateFormat = "d MMMM"
        return f.string(from: Date())
    }
}
