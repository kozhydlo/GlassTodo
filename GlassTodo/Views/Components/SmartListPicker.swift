import SwiftUI

struct SmartListPicker: View {
    @EnvironmentObject var tm: ThemeManager
    @Binding var selection: SmartList

    var body: some View {
        let t = tm.current

        HStack(spacing: 6) {
            ForEach(SmartList.allCases) { list in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selection = list
                    }
                    Haptic.selection()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: list.icon)
                            .font(.system(size: 11, weight: .semibold))
                        Text(list.rawValue)
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundColor(selection == list ? .white : t.textSecondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        selection == list
                            ? t.accent
                            : t.textSecondary.opacity(0.08)
                    )
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
