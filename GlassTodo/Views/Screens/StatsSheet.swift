import SwiftUI

struct StatsSheet: View {
    @EnvironmentObject var tm: ThemeManager
    @ObservedObject var vm: TodoViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let t = tm.current

        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Overview row
                    HStack(spacing: 12) {
                        statCard(value: "\(vm.totalCount)", label: "Total", icon: "list.bullet", color: t.accent)
                        statCard(value: "\(vm.completedCount)", label: "Done", icon: "checkmark", color: t.accentSecondary)
                        statCard(value: "\(vm.overdueCount)", label: "Overdue", icon: "exclamationmark.triangle", color: .red)
                    }

                    // Streak
                    CardView {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.12))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "flame.fill")
                                    .font(.title3)
                                    .foregroundColor(.orange)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(vm.currentStreak) day streak")
                                    .font(.headline)
                                    .foregroundColor(t.textPrimary)
                                Text("Keep it going! Complete tasks daily.")
                                    .font(.caption)
                                    .foregroundColor(t.textTertiary)
                            }

                            Spacer()
                        }
                        .padding(14)
                    }
                    .environmentObject(tm)

                    // Completed this week
                    CardView {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("This week")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(t.textTertiary)
                                    .textCase(.uppercase)
                                Text("\(vm.completedThisWeek) tasks completed")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(t.textPrimary)
                            }
                            Spacer()
                            Image(systemName: "chart.bar.fill")
                                .font(.title2)
                                .foregroundColor(t.accent.opacity(0.4))
                        }
                        .padding(14)
                    }
                    .environmentObject(tm)

                    // Progress ring
                    CardView {
                        VStack(spacing: 12) {
                            Text("Completion rate")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(t.textTertiary)
                                .textCase(.uppercase)

                            ZStack {
                                Circle()
                                    .stroke(t.textTertiary.opacity(0.1), lineWidth: 10)
                                    .frame(width: 100, height: 100)

                                Circle()
                                    .trim(from: 0, to: vm.completionRate)
                                    .stroke(
                                        t.accent,
                                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                    )
                                    .frame(width: 100, height: 100)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.spring(response: 0.6), value: vm.completionRate)

                                Text("\(Int(vm.completionRate * 100))%")
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(t.textPrimary)
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                    }
                    .environmentObject(tm)

                    // Category breakdown
                    if !vm.categoryBreakdown.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("By category")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(t.textTertiary)
                                .textCase(.uppercase)

                            ForEach(vm.categoryBreakdown, id: \.0) { cat, count in
                                CardView {
                                    HStack(spacing: 12) {
                                        Image(systemName: cat.icon)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(t.categoryColor(cat))
                                            .frame(width: 28, height: 28)
                                            .background(t.categoryColor(cat).opacity(0.12))
                                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

                                        Text(cat.rawValue)
                                            .font(.subheadline)
                                            .foregroundColor(t.textPrimary)

                                        Spacer()

                                        Text("\(count)")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(t.textSecondary)
                                    }
                                    .padding(12)
                                }
                                .environmentObject(tm)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(t.backgroundColor.ignoresSafeArea())
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(t.accent)
                }
            }
        }
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        let t = tm.current
        return CardView {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundColor(t.textPrimary)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(t.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .environmentObject(tm)
    }
}
