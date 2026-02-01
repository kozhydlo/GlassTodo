import SwiftUI

struct HomeView: View {
    @EnvironmentObject var tm: ThemeManager
    @StateObject private var vm = TodoViewModel()

    @State private var showAdd = false
    @State private var showSettings = false
    @State private var showStats = false
    @State private var showSearch = false
    @State private var showConfetti = false
    @State private var prevCompleted = 0

    private var userName: String {
        StorageService.shared.loadProfile()?.displayName ?? "User"
    }

    var body: some View {
        let t = tm.current

        ZStack {
            t.backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Sticky header
                HeaderView(
                    showSearch: $showSearch,
                    showSettings: $showSettings,
                    showAdd: $showAdd
                )
                .environmentObject(tm)

                // Main scroll
                ScrollView {
                    VStack(spacing: 16) {
                        // Greeting
                        GreetingSection(
                            userName: userName,
                            activeCount: vm.activeCount,
                            todayCount: vm.todayCount,
                            completionRate: vm.completionRate
                        )
                        .environmentObject(tm)

                        // Progress ring + streak
                        AnimatedProgressRing(
                            progress: vm.completionRate,
                            streak: vm.currentStreak
                        )
                        .environmentObject(tm)
                        .padding(.horizontal, 20)

                        // Weekly heatmap
                        WeeklyHeatmap(
                            data: vm.weeklyHeatmap,
                            maxCount: vm.maxWeeklyCount
                        )
                        .environmentObject(tm)
                        .padding(.horizontal, 20)

                        // Motivational message
                        motivationalBanner(t: t)

                        // Search
                        if showSearch {
                            searchBar(t: t)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // Quick actions
                        quickActions(t: t)

                        // Smart list + Category filter
                        SmartListPicker(selection: $vm.activeList)
                            .environmentObject(tm)

                        CategoryFilter(selected: $vm.selectedCategory)
                            .environmentObject(tm)

                        // Task list
                        taskList(t: t)
                    }
                    .padding(.bottom, 90)
                }

                // Quick add bar (always visible)
                QuickAddBar(vm: vm) {
                    showAdd = true
                }
                .environmentObject(tm)
            }

            // Confetti overlay
            if showConfetti {
                ConfettiView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showConfetti = false
                        }
                    }
            }
        }
        .sheet(isPresented: $showAdd) {
            AddTodoSheet(vm: vm)
                .environmentObject(tm)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(tm)
        }
        .sheet(isPresented: $showStats) {
            StatsSheet(vm: vm)
                .environmentObject(tm)
        }
        .preferredColorScheme(tm.themeType.colorScheme)
        .onChange(of: vm.completedCount) { oldValue, newValue in
            // Trigger confetti when all tasks just got completed
            if newValue > oldValue && vm.activeCount == 0 && vm.totalCount > 0 {
                showConfetti = true
                Haptic.success()
            }
        }
    }

    // MARK: Motivational Banner
    @ViewBuilder
    private func motivationalBanner(t: AppTheme) -> some View {
        HStack(spacing: 10) {
            Image(systemName: motivationalIcon)
                .font(.system(size: 14))
                .foregroundColor(t.accent.opacity(0.7))

            Text(vm.motivationalMessage)
                .font(.caption)
                .foregroundColor(t.textSecondary)
                .lineLimit(2)

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(t.accent.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 20)
    }

    private var motivationalIcon: String {
        if vm.activeCount == 0 && vm.completedCount > 0 { return "sparkles" }
        if vm.overdueCount > 0 { return "exclamationmark.triangle" }
        if vm.currentStreak >= 7 { return "flame.fill" }
        return "lightbulb"
    }

    // MARK: Search Bar
    @ViewBuilder
    private func searchBar(t: AppTheme) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundColor(t.textTertiary)

            TextField("Search tasks...", text: $vm.searchText)
                .font(.subheadline)
                .foregroundColor(t.textPrimary)
                .textFieldStyle(.plain)

            if !vm.searchText.isEmpty {
                Button { vm.searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(t.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(t.textSecondary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 20)
    }

    // MARK: Quick Actions
    @ViewBuilder
    private func quickActions(t: AppTheme) -> some View {
        HStack(spacing: 10) {
            Button {
                showStats = true
                Haptic.light()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Stats")
                        .font(.caption.weight(.medium))
                }
                .foregroundColor(t.accent)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(t.accent.opacity(0.08))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    vm.focusMode.toggle()
                }
                Haptic.selection()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: vm.focusMode ? "eye.slash.fill" : "eye")
                        .font(.system(size: 12, weight: .semibold))
                    Text(vm.focusMode ? "Focused" : "Focus")
                        .font(.caption.weight(.medium))
                }
                .foregroundColor(vm.focusMode ? .white : t.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(vm.focusMode ? t.accent : t.textSecondary.opacity(0.08))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    // MARK: Task List
    @ViewBuilder
    private func taskList(t: AppTheme) -> some View {
        let tasks = vm.filteredTodos

        if tasks.isEmpty {
            EmptyStateView(list: vm.activeList)
                .environmentObject(tm)
        } else {
            LazyVStack(spacing: 8) {
                ForEach(tasks) { todo in
                    TodoRow(vm: vm, todo: todo)
                        .environmentObject(tm)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
