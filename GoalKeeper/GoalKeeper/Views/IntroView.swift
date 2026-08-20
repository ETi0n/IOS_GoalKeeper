import SwiftUI
import SwiftData

struct IntroView: View {
    @Environment(\.modelContext) private var context // 저장소 접근 통로
    @Query private var goals: [Goal]                 // 저장소에서 자동으로 읽어옴
    @State private var isAddingGoal = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24){
                    header
                    
                    ForEach(goals) { goal in
                        NavigationLink {
                            GoalDetailView(goal: goal)
                        } label: {
                            GoalCard(goal: goal)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    newGoal
                    
                    thisWeekActive
                }
                .padding(24)
            }
            .background(Color.gkSurface)
            .onAppear {
                if goals.isEmpty {
                    for goal in Goal.samples {
                        context.insert(goal)
                    }
                }
            }
        }
    }
    
    // MARK: 상단 제목 영역
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("GOALKEEPER")
                .font(.caption).foregroundStyle(Color.gkGray)
            Text("지금 붙잡고 있는 목표")
                .font(.largeTitle).fontWeight(.medium)
            Text("하나를 고르면 그 목표의 마일스톤과 할 일이 한 화면에 펼쳐집니다.")
                .font(.subheadline).foregroundStyle(Color.gkGray)
        }
    }
    
    // MARK: 새 목표
    private var newGoal: some View {
        Button("+ 새 목표 만들기") { isAddingGoal = true }
            .font(.subheadline).foregroundStyle(Color.gkGray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black.opacity(0.2),
                            style: StrokeStyle(dash: [4]))
            )
            .sheet(isPresented: $isAddingGoal) { AddGoalSheet() }
    }
    
    // MARK: 이번 주 활동
    private var thisWeekActive: some View {
        let days = [true, false, true, true, false, true, false]
        
        return HStack(spacing: 14) {
            Text("이번 주 활동 \(days.filter { $0 }.count)일")
                .font(.body).foregroundStyle(Color.black.opacity(0.5))
            
            HStack(spacing: 8) {
                ForEach(0..<7) { i in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(days[i] ? Color.gkGreen : Color.gkGray.opacity(0.2))
                        .frame(width: 28, height: 8)
                }
            }
        }
    }
}

// MARK: - 목표 카드 컴포넌트
struct GoalCard: View {
    let goal: Goal
    @Environment(\.modelContext) var context
    @State private var isEditingGoal = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if goal.isPrimary {
                Text("대표 목표")
                    .font(.caption).foregroundStyle(Color.gkGreen)
            }
            
            HStack {
                Text(goal.title)
                    .font(.title3).fontWeight(.medium)
                Spacer()
            
                Text(goal.dDay)
                    .font(.caption).foregroundStyle(Color.gkGray)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.black.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                
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
            
            HStack(spacing: 8) {
                Text("다음 마일스톤")
                    .font(.caption).foregroundStyle(Color.gkGray)
                Text(goal.nextMilestone).font(.footnote)
                
                Spacer()
                
                // 수정
                Button {
                    isEditingGoal = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray.opacity(0.4))
                }
                .foregroundStyle(Color.gkGray)
                .sheet(isPresented: $isEditingGoal) {
                    AddGoalSheet(editingGoal: goal)
                }
                
                // 삭제
                Button {
                    context.delete(goal)
                    try? context.save()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray.opacity(0.4))
                }
                .foregroundStyle(Color.gkGray)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(goal.isPrimary ? Color.gkGreen.opacity(0.4) : Color.black.opacity(0.1), lineWidth: 0.5)
        )
    }
}

#Preview {
    IntroView()
        .modelContainer(for: Goal.self, inMemory: true)
}
