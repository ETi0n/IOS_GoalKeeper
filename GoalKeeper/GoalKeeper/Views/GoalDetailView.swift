import SwiftUI
import SwiftData

struct GoalDetailView: View {
    let goal: Goal
    var initialMilestone: Milestone? = nil
    var initialCategory: Category? = nil
    @State private var selectedMilestone: Milestone?
    @State private var isAddingMilestone: Bool = false
    @Environment(\.dismiss) private var dismiss
    @Environment(UndoManager.self) private var undoManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                dismiss()
            } label: {
                Text("‹ GOALKEEPER")
                    .font(.caption)
                    .foregroundStyle(Color.gkGray)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, Metrics.Spacing.xxl)
            
            // == 헤더 ==
            HStack(alignment: .firstTextBaseline, spacing: Metrics.Spacing.sm) {
                Text(goal.title)
                    .font(.title)
                    .fontWeight(.medium)
                
                Text(goal.period)
                    .font(.caption)
                    .foregroundStyle(Color.gkGray)
            }
            .padding(.horizontal, Metrics.Spacing.xxl).padding(.vertical, Metrics.Spacing.md)
            
            
            Divider()
            
            HStack(alignment: .top, spacing: 0) {
                // == 왼쪽: 마일스톤 목록 ==
                VStack(alignment: .leading, spacing: Metrics.Spacing.md) {
                    Text("마일스톤 \(goal.milestones.count)개")
                        .font(.caption)
                        .foregroundStyle(Color.gkGray)
                    
                    ForEach (goal.milestones.filter { !undoManager.isPending($0.id) }) { milestone in
                        MilestoneCard(goal: goal, milestone: milestone,
                                      isSelected: selectedMilestone?.id == milestone.id,
                                      onDelete: {
                                if selectedMilestone?.id == milestone.id {
                                    selectedMilestone = nil
                                }
                            }
                        )
                        .onTapGesture {
                            selectedMilestone = milestone
                        }
                    }
                    
                    Button("+ 마일스톤 추가") { isAddingMilestone = true }
                        .foregroundStyle(Color.gkGray)
                        .buttonStyle(.plain)
                        .padding(.vertical, Metrics.Spacing.md)
                        .frame(maxWidth: .infinity)
                        .background(.clear)
                        .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.card))
                        .overlay(RoundedRectangle(cornerRadius: Metrics.Radius.card).stroke(Color.gkHairline, style: StrokeStyle(lineWidth: Metrics.Stroke.dashed, dash: [4])))
                        .sheet(isPresented: $isAddingMilestone, content: {
                            AddMilestoneSheet(goal: goal)
                        })
                }
                .padding(Metrics.Spacing.xxl)
                .frame(width: 300)
                .frame(maxHeight: .infinity, alignment: .top) // 높이를 채워 상단에 붙도록 유도
                
                Divider()
                
                // == 오른쪽: 선택 마일스톤의 할 일 ==
                if let selectedMilestone {
                    MilestoneDetailView(milestone: selectedMilestone, initialCategory: initialCategory)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("마일스톤을 고르세요.")
                        .foregroundStyle(Color.gkGray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .background(Color.gkSurface)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            // 처음 진입 시 마일스톤 자동선택
            selectedMilestone = initialMilestone ?? goal.milestones.first
        }
    }
}

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
                    .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.card))
                    .overlay(RoundedRectangle(cornerRadius: Metrics.Radius.card).stroke(milestone.status == "대기" ? Color.gkHairline : .gkGreenBorder, lineWidth: Metrics.Stroke.outline))
                
                Spacer()
                
                // 기간
                Text(milestone.due)
                    .font(.caption)
                    .foregroundStyle(Color.gkGray)
            }
            
            HStack {
                // 제목
                Text(milestone.title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                OverflowMenu {
                    Button("수정") { isEditingMilestone = true }
                    Button("삭제", role: .destructive) { isConfirmingDelete = true }
                }
            }
            
            // 진행바
            ProgressView(value: milestone.progress)
                .tint(Color.gkGreen)
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
                    goal.milestones.removeAll() { $0.id == milestone.id }
                    try? context.save()
                    onDelete()
                }
            }
            Button("취소", role: .cancel) {}
        }
    }
}

#Preview {
    GoalDetailView(goal: Goal.samples[0])
        .environment(UndoManager())
}
