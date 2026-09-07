import SwiftUI
import SwiftData

struct MilestoneCard: View {
    let goal: Goal
    let milestone: Milestone
    var isSelected: Bool = false
    var onDelete: () -> Void
    @Environment(\.modelContext) private var context
    @Environment(UndoManager.self) private var undoManager
    @State private var isEditingMilestone: Bool = false
    @State private var isConfirmingDelete: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.Spacing.md) {
            HStack {
                // 진행 상태
                Text(milestone.status)
                    .font(.caption)
                    .foregroundStyle(milestone.status == "대기" ? Color.gkGray : .gkGreen)
                    .padding(.horizontal, Metrics.Spacing.sm).padding(.vertical, Metrics.Spacing.xs)
                    .background(milestone.status == "완료" ? Color.gkGreenBG : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.chip))
                    .overlay(RoundedRectangle(cornerRadius: Metrics.Radius.chip).stroke(milestone.status == "대기" ? Color.gkHairline : .gkGreenBorder, lineWidth: Metrics.Stroke.outline))
                
                Spacer()
                
                // 기간
                Text(milestone.due)
                    .font(.caption)
                    .foregroundStyle(Color.gkGray)
            }
            
            HStack(alignment: .center) {
                // 진행바
                ProgressRing(value: milestone.progress, tint: milestone.status == "대기" ? Color.gkGray : Color.gkGreen)
                    .padding(.horizontal, Metrics.Spacing.xs)
                    .animation(.easeInOut(duration: 0.3), value: milestone.progress)
                
                // 제목
                Text(milestone.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                OverflowMenu {
                    Button("수정") { isEditingMilestone = true }
                    Button("삭제", role: .destructive) { isConfirmingDelete = true }
                }
            }
        }
        .padding(Metrics.Spacing.lg)
        .background(Color.gkCard)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.card))
        .overlay(RoundedRectangle(cornerRadius: Metrics.Radius.card)
            .stroke(isSelected ? Color.gkGreen : Color.gkHairline,
                    lineWidth: Metrics.Stroke.hairline))
        .sheet(isPresented: $isEditingMilestone) {
            AddMilestoneSheet(goal: goal, editingMilestone: milestone)
        }
        .confirmationDialog("이 마일스톤을 삭제할까요?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("삭제", role: .destructive) {
                undoManager.scheduleDelete(id: milestone.id, message: "\"\(milestone.title)\" 삭제됨") {
                    context.delete(milestone)
                    goal.milestones?.removeAll { $0.id == milestone.id }
                    try? context.save()
                    NotificationManager.shared.cancelMilestoneReminder(id: milestone.notificationID)
                    onDelete()
                }
            }
            Button("취소", role: .cancel) {}
        }
    }
}


#Preview {
    MilestoneCard(goal: Goal.samples[0], milestone: Goal.samples[0].milestones![0],
                  isSelected: true, onDelete: {})
        .padding()
        .environment(UndoManager())
        .modelContainer(for: Goal.self, inMemory: true)
}
