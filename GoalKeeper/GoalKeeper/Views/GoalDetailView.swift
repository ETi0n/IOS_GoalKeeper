import SwiftUI
import SwiftData

struct GoalDetailView: View {
    let goal: Goal
    @State private var selectedMilestone: Milestone?
    @State private var isAddingMilestone: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            
            // == 왼쪽: 마일스톤 목록 ==
            VStack(alignment: .leading, spacing: 16) {
                Text(goal.title)
                    .font(.title)
                    .fontWeight(.medium)
                
                Divider()
                
                Text(goal.period)
                    .font(.caption)
                    .foregroundStyle(Color.gkGray)
                
                Text("마일스톤 \(goal.milestones.count)개")
                    .font(.caption)
                    .foregroundStyle(Color.gkGray)
                
                ForEach (goal.milestones) { milestone in
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
                
                Divider()
                
                Button("+ 마일스톤 추가") { isAddingMilestone = true }
                    .foregroundStyle(Color.gkGray)
                    .buttonStyle(.plain)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black.opacity(0.1), style: StrokeStyle(lineWidth: 1.5, dash: [4])))
                    .sheet(isPresented: $isAddingMilestone, content: {
                        AddMilestoneSheet(goal: goal)
                    })
            }
            .padding(24)
            .frame(width: 320)
            .frame(maxHeight: .infinity, alignment: .top) // 높이를 채워 상단에 붙도록 유도
            .background(Color.gkSurface)
            
            Divider()
            
            // == 오른쪽: 선택 마일스톤의 할 일 ==
            if let selectedMilestone {
                MilestoneDetailView(milestone: selectedMilestone)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("마일스톤을 고르세요.")
                    .foregroundStyle(Color.gkGray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            // 처음 진입 시 마일스톤 자동선택
            selectedMilestone = goal.milestones.first
        }
    }
}

struct MilestoneCard: View {
    let goal: Goal
    let milestone: Milestone
    var isSelected: Bool = false
    var onDelete: () -> Void
    @Environment(\.modelContext) private var context
    @State private var isEditingMilestone: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // 진행 상태
                Text(milestone.status)
                    .font(.caption)
                    .foregroundStyle(milestone.status == "대기" ? Color.gkGray : .gkGreen)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(milestone.status == "완료" ? Color.gkGreen.opacity(0.1) : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(milestone.status == "대기" ? Color.gkGray.opacity(0.4) : .gkGreen.opacity(0.4), lineWidth: 1))
                
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
                
                // 수정
                Button {
                    isEditingMilestone = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray.opacity(0.4))
                }
                .sheet(isPresented: $isEditingMilestone) {
                    AddMilestoneSheet(goal: goal, editingMilestone: milestone)
                }
                
                // 삭제
                Button {
                    context.delete(milestone)
                    goal.milestones.removeAll() { $0.id == milestone.id }
                    try? context.save()
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray.opacity(0.4))
                }
                .foregroundStyle(Color.gkGray)
            }
            
            // 진행바
            ProgressView(value: milestone.progress)
                .tint(Color.gkGreen)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(isSelected ? Color.gkGreen : Color.black.opacity(0.1),
                    lineWidth: 0.5))
    }
    
    
}

#Preview {
    GoalDetailView(goal: Goal.samples[0])
}
