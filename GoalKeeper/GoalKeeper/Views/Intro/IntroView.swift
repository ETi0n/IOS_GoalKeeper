import SwiftUI
import SwiftData

struct IntroView: View {
    @Environment(\.modelContext) private var context // 저장소 접근 통로
    @Environment(UndoManager.self) private var undoManager
    @Environment(NotificationManager.self) private var notificationManager
    @Query private var allGoals: [Goal]
    @Query(filter: #Predicate<Goal> { !$0.isArchived }) private var goals: [Goal]                 // 저장소에서 자동으로 읽어옴
    @State private var isAddingGoal = false
    @State private var path: [Goal] = []           // 프로그래밍 방식 네비게이션 경로
    @State private var pendingMilestone: Milestone? // 알림으로 열어야 할 마일스톤 (와이드 화면에서 자동 선택용)

    private var isWide: Bool {
        UIDevice.current.userInterfaceIdiom != .phone
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: Metrics.Spacing.xxl){
                    header
                    
                    if !isWide { TodayPanel(goals: goals, width: .infinity) }
                    HStack(alignment: .top, spacing: Metrics.Spacing.xl) {
                        VStack(alignment: .leading, spacing: Metrics.Spacing.lg) {
                            Text("진행 중인 목표 \(goals.count)개")
                                .font(.caption)
                                .foregroundStyle(Color.gkGray)
                            
                            ForEach(sortedGoals) { goal in
                                NavigationLink {
                                    GoalDetailView(goal: goal)
                                } label: {
                                    GoalCard(goal: goal, onTogglePrimary: { togglePrimaryGoal(goal) })
                                }
                                .buttonStyle(.plain)
                            }
                            
                            newGoal
                        }
                        
                        if isWide { TodayPanel(goals: goals, width: 300) }
                    }
                    
                    recentActivity
                }
                .padding(Metrics.Spacing.xxl)
            }
            .background(Color.gkSurface)
            .navigationDestination(for: Goal.self) { goal in
                GoalDetailView(goal: goal, initialMilestone: pendingMilestone)
            }
            .onChange(of: notificationManager.pendingMilestoneNotificationID) {
                guard let targetID = notificationManager.pendingMilestoneNotificationID else { return }
                for goal in allGoals {
                    if let milestone = (goal.milestones ?? []).first(where: { $0.notificationID == targetID }) {
                        pendingMilestone = milestone
                        path = [goal] // 지금까지 쌓인 경로를 이 목표 하나로 교체 → 바로 그 화면으로 이동
                        break
                    }
                }
                notificationManager.pendingMilestoneNotificationID = nil // 처리 완료, 다음 탭을 위해 비워둠
            }
        }
    }

    private func togglePrimaryGoal(_ goal: Goal) {
        if goal.isPrimary {
            goal.isPrimary = false
        } else {
            for g in goals {
                g.isPrimary = false
            }
            goal.isPrimary = true
        }
        
        try? context.save()
    }
    
    private var sortedGoals: [Goal] {
        goals.filter { !undoManager.isPending($0.id) }
            .sorted { $0.isPrimary && !$1.isPrimary }
    }
    
    // MARK: 상단 제목 영역
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: Metrics.Spacing.sm) {
                Text("GOALKEEPER")
                    .font(.caption).foregroundStyle(Color.gkGray)
                Text("지금 붙잡고 있는 목표")
                    .font(.largeTitle).fontWeight(.medium)
                Text("하나를 고르면 그 목표의 마일스톤과 할 일이 한 화면에 펼쳐집니다.")
                    .font(.subheadline).foregroundStyle(Color.gkGray)
            }
            
            Spacer()
            
            NavigationLink {
                ArchiveView()
            } label: {
                if isWide {
                    Text("보관함")
                        .font(.caption)
                        .foregroundStyle(Color.gkGray)
                        .padding(.vertical, Metrics.Spacing.sm).padding(.horizontal, Metrics.Spacing.md)
                        .background(Color.gkCard)
                        .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.chip))
                        .overlay(
                            RoundedRectangle(cornerRadius: Metrics.Radius.chip)
                                .stroke(Color.gkHairline, lineWidth: Metrics.Stroke.hairline)
                        )
                } else {
                    Image(systemName: "archivebox")
                        .foregroundStyle(Color.gkMutedIcon)
                }
            }
        }
    }
    
    // MARK: 새 목표
    private var newGoal: some View {
        Button("+ 새 목표 만들기") { isAddingGoal = true }
            .font(.subheadline).foregroundStyle(Color.gkGray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Metrics.Spacing.lg)
            .overlay(
                RoundedRectangle(cornerRadius: Metrics.Radius.panel)
                    .stroke(Color.gkHairline,
                            style: StrokeStyle(lineWidth: Metrics.Stroke.dashed, dash: [4]))
            )
            .sheet(isPresented: $isAddingGoal) { AddGoalSheet() }
    }
    
    // MARK: 최근 7일 활동
    private var recentActivity: some View {
        let activity = recentActivityDays
        
        return HStack(spacing: Metrics.Spacing.lg) {
            Text(isWide ? "최근 7일간 활동 \(activity.filter { $0 }.count)일" : "최근 활동")
                .font(.subheadline).foregroundStyle(Color.gkGray)
            
            HStack(spacing: Metrics.Spacing.sm) {
                ForEach(0..<7) { i in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(activity[i] ? Color.gkGreen : Color.gkFaintFill)
                        .frame(width: 28, height: 8)
                }
            }
        }
    }
    
    // 최근 7일간 하루하루 활동 여부 계산
    private var recentActivityDays: [Bool] {
        let calendar = Calendar.current
        let allTasks = allGoals.flatMap { ($0.milestones ?? []).flatMap { ($0.categories ?? []).flatMap { $0.tasks ?? [] }}}
        
        return (0..<7).reversed().map { offset in
            guard let targetDay = calendar.date(byAdding: .day, value: -offset, to: Date())
            else { return false }
            
            return allTasks.contains { task in
                guard let doneDate = task.doneDate else { return false }
                return calendar.isDate(doneDate, inSameDayAs: targetDay)
            }
        }
    }
}


#Preview {
    IntroView()
        .modelContainer(for: Goal.self, inMemory: true)
        .environment(UndoManager())
        .environment(NotificationManager.shared)
}
