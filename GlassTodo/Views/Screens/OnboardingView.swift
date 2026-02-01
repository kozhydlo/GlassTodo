import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var tm: ThemeManager
    @StateObject private var vm = OnboardingViewModel()
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Group {
                    switch vm.page {
                    case 0:  welcomePage
                    case 1:  namePage
                    default: themePage
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                Spacer()

                navigation
                    .padding(.bottom, 16)
            }
            .padding(28)
        }
    }

    // MARK: Pages
    private var welcomePage: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 60, weight: .light))
                .foregroundStyle(.blue.gradient)

            Text("Welcome")
                .font(.largeTitle.weight(.bold))

            Text("A simple, focused task manager\ndesigned for clarity.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var namePage: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 50, weight: .light))
                .foregroundStyle(.blue.gradient)

            Text("What's your name?")
                .font(.title2.weight(.bold))

            TextField("Your name", text: $vm.name)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal, 20)
        }
    }

    private var themePage: some View {
        VStack(spacing: 20) {
            Image(systemName: "paintpalette")
                .font(.system(size: 50, weight: .light))
                .foregroundStyle(.blue.gradient)

            Text("Choose a look")
                .font(.title2.weight(.bold))

            VStack(spacing: 8) {
                ForEach(AppThemeType.allCases) { type in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            vm.selectedTheme = type
                        }
                        Haptic.selection()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: type.icon)
                                .font(.body)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(type.rawValue)
                                    .font(.subheadline.weight(.medium))
                                Text(type.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if vm.selectedTheme == type {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .foregroundColor(.primary)
                        .padding(12)
                        .background(
                            vm.selectedTheme == type
                            ? Color.blue.opacity(0.08)
                            : Color(uiColor: .secondarySystemBackground)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: Navigation
    private var navigation: some View {
        HStack {
            if vm.page > 0 {
                Button { vm.back() } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(width: 44, height: 44)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(Circle())
                }
            }

            Spacer()

            // Dots
            HStack(spacing: 6) {
                ForEach(0..<vm.totalPages, id: \.self) { p in
                    Circle()
                        .fill(p == vm.page ? Color.blue : Color.secondary.opacity(0.25))
                        .frame(width: p == vm.page ? 8 : 6, height: p == vm.page ? 8 : 6)
                        .animation(.spring(response: 0.3), value: vm.page)
                }
            }

            Spacer()

            Button {
                if vm.page == vm.totalPages - 1 {
                    vm.complete(themeManager: tm)
                    onComplete()
                } else {
                    vm.next()
                }
            } label: {
                let isLast = vm.page == vm.totalPages - 1
                let disabled = vm.page == 1 && !vm.isNameValid

                Group {
                    if isLast {
                        Text("Get Started")
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .frame(width: 44, height: 44)
                    }
                }
                .foregroundColor(.white)
                .background(disabled ? Color.blue.opacity(0.4) : Color.blue)
                .clipShape(Capsule())
            }
            .disabled(vm.page == 1 && !vm.isNameValid)
        }
    }
}
