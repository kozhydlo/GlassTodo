import SwiftUI

struct CardView<Content: View>: View {
    @EnvironmentObject var tm: ThemeManager
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        let t = tm.current
        if t.usesGlass {
            content()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: t.cornerRadius, style: .continuous))
        } else {
            content()
                .background(t.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: t.cornerRadius, style: .continuous))
                .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
        }
    }
}
