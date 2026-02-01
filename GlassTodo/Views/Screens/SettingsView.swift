import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var tm: ThemeManager
    @StateObject private var vm = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var editingName = false
    @State private var nameText = ""

    var body: some View {
        let t = tm.current

        NavigationStack {
            List {
                // Profile
                Section {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(t.accent.opacity(0.12))
                                .frame(width: 44, height: 44)
                            Text(String(vm.userName.prefix(1)).uppercased())
                                .font(.title3.weight(.semibold))
                                .foregroundColor(t.accent)
                        }

                        if editingName {
                            TextField("Name", text: $nameText)
                                .font(.body)
                                .onSubmit {
                                    vm.saveName(nameText)
                                    editingName = false
                                }
                        } else {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(vm.userName)
                                    .font(.body.weight(.medium))
                                Text("Tap to edit")
                                    .font(.caption)
                                    .foregroundColor(t.textTertiary)
                            }
                        }

                        Spacer()

                        Button {
                            if editingName {
                                vm.saveName(nameText)
                                editingName = false
                            } else {
                                nameText = vm.userName
                                editingName = true
                            }
                        } label: {
                            Image(systemName: editingName ? "checkmark" : "pencil")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(t.accent)
                        }
                    }
                } header: {
                    Text("Profile")
                }

                // Theme
                Section {
                    ForEach(AppThemeType.allCases) { type in
                        Button {
                            tm.set(type)
                        } label: {
                            HStack(spacing: 12) {
                                // Preview swatch
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(themePreviewColor(type))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: type.icon)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(themePreviewForeground(type))
                                    )

                                VStack(alignment: .leading, spacing: 1) {
                                    Text(type.rawValue)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(t.textPrimary)
                                    Text(type.subtitle)
                                        .font(.caption)
                                        .foregroundColor(t.textTertiary)
                                }

                                Spacer()

                                if tm.themeType == type {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(t.accent)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Appearance")
                }

                // Danger
                Section {
                    Button(role: .destructive) {
                        vm.showReset = true
                    } label: {
                        Label("Reset Everything", systemImage: "trash")
                    }
                } header: {
                    Text("Data")
                } footer: {
                    Text("Version 2.0 • SwiftUI • MVVM")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 20)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(t.usesGlass ? .hidden : .automatic)
            .background(t.backgroundColor.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(t.accent)
                }
            }
            .alert("Reset Everything?", isPresented: $vm.showReset) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    vm.resetApp()
                    dismiss()
                }
            } message: {
                Text("All tasks, settings, and profile will be permanently deleted.")
            }
        }
    }

    private func themePreviewColor(_ type: AppThemeType) -> Color {
        switch type {
        case .system:       return Color(uiColor: .systemGray5)
        case .light:        return .white
        case .dark:         return Color(white: 0.15)
        case .softGlass:    return Color(uiColor: .systemGray5)
        case .highContrast: return .black
        }
    }

    private func themePreviewForeground(_ type: AppThemeType) -> Color {
        switch type {
        case .dark, .highContrast: return .white
        default: return Color(uiColor: .secondaryLabel)
        }
    }
}
