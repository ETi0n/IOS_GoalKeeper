import SwiftUI
import SwiftData

struct IntroView: View {
    @Environment(\.modelContext) private var context // 저장소 접근 통로
    @Environment(UndoManager.self) private var undoManager
    @Query private var allGoals: [Goal]
    @Query(filter: #Predicate<Goal> { !$0.isArchived }) private var goals: [Goal]                 // 저장소에서 자동으로 읽어옴
    @State private var isAddingGoal = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Metrics.Spacing.xxl){
                    header
                    
                    HStack(alignment: .top, spacing: Metrics.Spacing.xl) {
                        VStack(spacing: Metrics.Spacing.lg) {
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
                        
                        TodayPanel(entries: todayEntries)
                    }
                    
                    recentActivity
                }
                .padding(Metrics.Spacing.xxl)
            }
            .background(Color.gkSurface)
            .onAppear {
                // TODO: 추후 목데이터 지우기
                if allGoals.isEmpty {
                    for goal in Goal.samples {
                        context.insert(goal)
                    }
                }
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
            Text("최근 7일간 활동 \(activity.filter { $0 }.count)일")
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
        let allTasks = allGoals.flatMap { $0.milestones.flatMap { $0.categories.flatMap { $0.tasks }}}
        
        return (0..<7).reversed().map { offset in
            guard let targetDay = calendar.date(byAdding: .day, value: -offset, to: Date())
            else { return false }
            
            return allTasks.contains { task in
                guard let doneDate = task.doneDate else { return false }
                return calendar.isDate(doneDate, inSameDayAs: targetDay)
            }
        }
    }
    
    // MARK: 오늘의 Task
    private struct TodayEntry: Identifiable {
        let id: PersistentIdentifier
        let goal: Goal
        let milestone: Milestone
        let category: Category
        let task: TaskItem
    }
    
    private var todayEntries: [TodayEntry] {
        goals.flatMap { entries(in: $0) }
    }

    private func entries(in goal: Goal) -> [TodayEntry] {
        let activeMilestones = goal.milestones.filter { $0.status == "진행중" }

        return activeMilestones.flatMap { milestone -> [TodayEntry] in
            milestone.categories.flatMap { category -> [TodayEntry] in
                category.tasks
                    .filter { $0.tag == .must && !$0.isDone }
                    .map { task in
                        TodayEntry(id: task.id, goal: goal, milestone: milestone, category: category, task: task)
                    }
            }
        }
    }
    
    private struct TodayPanel: View {
        let entries: [TodayEntry]
        
        var body: some View {
            VStack(alignment: .leading, spacing: Metrics.Spacing.md) {
                HStack {
                    Text("진행중인 MUST")
                        .font(.subheadline)
                    Spacer()
                    Text("\(entries.count)개 남음")
                        .font(.caption)
                        .foregroundStyle(Color.gkGray)
                }
                .padding(.vertical, Metrics.Spacing.sm)
                
                if entries.isEmpty {
                    Text("오늘 아무것도 없습니다")
                        .font(.caption)
                        .foregroundStyle(Color.gkGray)
                } else {
                    VStack(alignment: .leading, spacing: Metrics.Spacing.xs) {
                        ForEach(entries) { entry in
                            NavigationLink {
                                GoalDetailView(goal: entry.goal,
                                               initialMilestone: entry.milestone,
                                               initialCategory: entry.category)
                            } label: {
                                HStack {
                                    Image(systemName: entry.task.isDone ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(entry.task.isDone ? Color.gkGreen : .gkMutedIcon)
                                    
                                    Text(entry.task.title)
                                        .font(.caption)
                                        .foregroundStyle(Color.gkInk)
                                }
                            }
                        }
                    }
                }
                
                Divider()
                Text("여러 목표에 흩어진 주요 할 일을 모았습니다. 항목을 누르면 그 목표로 들어갑니다.")
                    .font(.caption)
                    .foregroundStyle(Color.gkGray)
            }
            .padding(Metrics.Spacing.xl)
            .frame(width: 280)
            .background(Color.gkCard)
            .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.panel))
            .overlay(
                RoundedRectangle(cornerRadius: Metrics.Radius.panel)
                    .stroke(Color.gkHairline, lineWidth: Metrics.Stroke.hairline)
            )
        }
    }
}

// MARK: - 목표 카드 컴포넌트
struct GoalCard: View {
    let goal: Goal
    var onTogglePrimary: () -> Void
    @Environment(\.modelContext) var context
    @Environment(UndoManager.self) private var undoManager
    @State private var isEditingGoal = false
    @State private var isConfirmingDelete = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.Spacing.md) {
            if goal.isPrimary {
                Text("대표 목표")
                    .font(.caption).foregroundStyle(Color.gkGreen)
            }
            
            HStack {
                Text(goal.title)
                    .font(.title3).fontWeight(.medium)
                Spacer()
            
                Button {
                    onTogglePrimary()
                } label: {
                    Image(systemName: goal.isPrimary ? "star.fill" : "star")
                        .font(.caption).foregroundStyle(goal.isPrimary ? Color.gkGreen : .gkMutedIcon)
                }
                
                Text(goal.dDay)
                    .font(.caption).foregroundStyle(Color.gkGray)
                    .padding(.horizontal, Metrics.Spacing.sm).padding(.vertical, Metrics.Spacing.xs)
                    .background(Color.gkFaintFill)
                    .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.chip))
                
            }
            
            ProgressView(value: goal.progress)
                .tint(Color.gkGreen)
            
            HStack {
                Text("전체 \(Int(goal.progress * 100))%")
                Spacer()
                Text(goal.period)
            }
            .font(.footnote).foregroundStyle(Color.gkGray)
            
            Divider()
            
            HStack(spacing: Metrics.Spacing.sm) {
                Text("다음 마일스톤")
                    .font(.caption).foregroundStyle(Color.gkGray)
                Text(goal.nextMilestone).font(.footnote)
                
                Spacer()
                
                OverflowMenu {
                    Button("수정") { isEditingGoal = true }
                    Button("보관") {
                        goal.isArchived = true
                        goal.archivedDate = Date()
                        try? context.save()
                    }
                    Button("삭제", role: .destructive) { isConfirmingDelete = true }
                }
            }
        }
        .padding(Metrics.Spacing.xl)
        .background(Color.gkCard)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.panel))
        .overlay(
            RoundedRectangle(cornerRadius: Metrics.Radius.panel)
                .stroke(goal.isPrimary ? Color.gkGreenBorder : Color.gkHairline, lineWidth: Metrics.Stroke.hairline)
        )
        .sheet(isPresented: $isEditingGoal) {
            AddGoalSheet(editingGoal: goal)
        }
        .confirmationDialog("이 목표를 삭제할까요?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
                Button("삭제", role: .destructive) {
                    undoManager.scheduleDelete(id: goal.id, message: "\"\(goal.title)\" 삭제됨") {
                        context.delete(goal)
                        try? context.save()
                    }
                }
                Button("취소", role: .cancel) {}
        }
    }
}

#Preview {
    IntroView()
        .modelContainer(for: Goal.self, inMemory: true)
        .environment(UndoManager())
}
