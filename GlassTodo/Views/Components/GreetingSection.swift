import SwiftUI

struct GreetingSection: View {
    @EnvironmentObject var tm: ThemeManager
    let userName: String
    let activeCount: Int
    let todayCount: Int
    let completionRate: Double

    var body: some View {
        let t = tm.current

        VStack(alignment: .leading, spacing: 16) {
            // Greeting
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.title2.weight(.bold))
                    .foregroundColor(t.textPrimary)

                if activeCount == 0 {
                    Text("No pending tasks — enjoy your day!")
                        .font(.subheadline)
                        .foregroundColor(t.textSecondary)
                } else {
                    Text("You have \(activeCount) task\(activeCount == 1 ? "" : "s") to complete")
                        .font(.subheadline)
                        .foregroundColor(t.textSecondary)
                }
            }

            // Summary cards row
            HStack(spacing: 10) {
                summaryPill(
                    icon: "calendar",
                    value: "\(todayCount)",
                    label: "Today",
                    color: t.accent
                )

                summaryPill(
                    icon: "flame.fill",
                    value: "\(Int(completionRate * 100))%",
                    label: "Done",
                    color: t.accentSecondary
                )
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: Summary pill
    private func summaryPill(icon: String, value: String, label: String, color: Color) -> some View {
        let t = tm.current
        return CardView {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 30, height: 30)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 1) {
                    Text(value)
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(t.textPrimary)
                    Text(label)
                        .font(.caption2)
                        .foregroundColor(t.textTertiary)
                }

                Spacer()
            }
            .padding(12)
        }
        .environmentObject(tm)
    }

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        let name = userName.isEmpty ? "" : ", \(userName)"
        switch h {
        case 5..<12:  return "Good morning\(name)"
        case 12..<17: return "Good afternoon\(name)"
        case 17..<22: return "Good evening\(name)"
        default:      return "Good night\(name)"
        }
    }
}
