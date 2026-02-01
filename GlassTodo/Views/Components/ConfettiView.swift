import SwiftUI

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let color: Color
    let size: CGFloat
    let rotation: Double
    let velocity: CGFloat
    let drift: CGFloat
}

struct ConfettiView: View {
    @State private var pieces: [ConfettiPiece] = []
    @State private var animate = false

    let colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink, .mint, .cyan
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size * 0.4)
                        .rotationEffect(.degrees(animate ? piece.rotation + 360 : piece.rotation))
                        .position(
                            x: piece.x + (animate ? piece.drift : 0),
                            y: animate ? geo.size.height + 40 : piece.y
                        )
                        .opacity(animate ? 0 : 1)
                }
            }
            .onAppear {
                pieces = (0..<50).map { _ in
                    ConfettiPiece(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: -60...(-10)),
                        color: colors.randomElement()!,
                        size: CGFloat.random(in: 5...10),
                        rotation: Double.random(in: 0...360),
                        velocity: CGFloat.random(in: 0.5...1.5),
                        drift: CGFloat.random(in: -60...60)
                    )
                }
                withAnimation(.easeIn(duration: 2.5)) {
                    animate = true
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
