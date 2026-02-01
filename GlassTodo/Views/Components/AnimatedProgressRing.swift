import SwiftUI

struct AnimatedProgressRing: View {
    @EnvironmentObject var tm: ThemeManager
    let progress: Double
    let streak: Int

    @State private var animatedProgress: Double = 0

    var body: some View {
        let t = tm.current

        CardView {
            HStack(spacing: 18) {
                // Ring
                ZStack {
                    Circle()
                        .stroke(t.textTertiary.opacity(0.08), lineWidth: 8)
                        .frame(width: 64, height: 64)

                    Circle()
                        .trim(from: 0, to: animatedProgress)
                        .stroke(
                            AngularGradient(
                                colors: [t.accent, t.accentSecondary, t.accent],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(-90))

                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(t.textPrimary)
                }

                // Stats column
                VStack(alignment: .leading, spacing: 6) {
                    Text("Daily Progress")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(t.textPrimary)

                    if streak > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            Text("\(streak) day streak")
                                .font(.caption.weight(.medium))
                                .foregroundColor(.orange)
                        }
                    }

                    Text(progressLabel)
                        .font(.caption)
                        .foregroundColor(t.textTertiary)
                }

                Spacer()
            }
            .padding(16)
        }
        .environmentObject(tm)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animatedProgress = newValue
            }
        }
    }

    private var progressLabel: String {
        switch progress {
        case 0:       return "Let's get started!"
        case 0.01..<0.25: return "Good start, keep going"
        case 0.25..<0.50: return "Quarter done!"
        case 0.50..<0.75: return "Halfway there!"
        case 0.75..<1.0:  return "Almost done!"
        default:          return "All complete! 🎉"
        }
    }
}
