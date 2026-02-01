import SwiftUI

struct WeeklyHeatmap: View {
    @EnvironmentObject var tm: ThemeManager
    let data: [(String, Int)]  // (day label, count)
    let maxCount: Int

    var body: some View {
        let t = tm.current

        CardView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("This week")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(t.textTertiary)
                        .textCase(.uppercase)
                    Spacer()
                    Image(systemName: "chart.bar.fill")
                        .font(.caption)
                        .foregroundColor(t.textTertiary)
                }

                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                        VStack(spacing: 4) {
                            // Bar
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(barColor(count: item.1))
                                .frame(width: barWidth, height: barHeight(item.1))
                                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: item.1)

                            // Day label
                            Text(item.0)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(isToday(item.0) ? t.accent : t.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 70)
            }
            .padding(14)
        }
        .environmentObject(tm)
    }

    private var barWidth: CGFloat { 24 }

    private func barHeight(_ count: Int) -> CGFloat {
        let maxH: CGFloat = 52
        let minH: CGFloat = 4
        guard maxCount > 0 else { return minH }
        return max(minH, maxH * CGFloat(count) / CGFloat(maxCount))
    }

    private func barColor(count: Int) -> Color {
        let t = tm.current
        if count == 0 { return t.textTertiary.opacity(0.12) }
        let intensity = min(Double(count) / Double(max(maxCount, 1)), 1.0)
        return t.accent.opacity(0.3 + intensity * 0.7)
    }

    private func isToday(_ label: String) -> Bool {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: Date()) == label
    }
}
