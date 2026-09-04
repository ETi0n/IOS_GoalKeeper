import SwiftUI
import SwiftData

struct TodayPanel: View {
    let goals: [Goal]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.Spacing.md) {
            HStack {
                Text("진행중인 MUST")
                    .font(.subheadline)
                Spacer()
                Text("\(todayEntries.count)개 남음")
                    .font(.caption)
                    .foregroundStyle(Color.gkGray)
            }
            .padding(.vertical, Metrics.Spacing.sm)
            
            if todayEntries.isEmpty {
                Text("오늘 아무것도 없습니다")
                    .font(.caption)
                    .foregroundStyle(Color.gkGray)
            } else {
                VStack(alignment: .leading, spacing: Metrics.Spacing.xs) {
                    ForEach(todayEntries) { entry in
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
                                
                                Spacer()
                                
                                Text(entry.goal.title)
                                    .font(.caption2)
                                    .foregroundStyle(Color.gkGray)
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
        .frame(width: 300)
        .background(Color.gkCard)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.panel))
        .overlay(
            RoundedRectangle(cornerRadius: Metrics.Radius.panel)
                .stroke(Color.gkHairline, lineWidth: Metrics.Stroke.hairline)
        )
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
}

#Preview {
    TodayPanel(goals: Goal.samples)
        .padding()
}
