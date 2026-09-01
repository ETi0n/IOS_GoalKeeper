import SwiftUI
import SwiftData

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
    GoalCard(goal: Goal.samples[0], onTogglePrimary: {})
        .padding()
        .environment(UndoManager())
        .modelContainer(for: Goal.self, inMemory: true)
}
