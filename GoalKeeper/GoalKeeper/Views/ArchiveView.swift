import SwiftUI
import SwiftData

struct ArchiveView: View {
    private let columns = [GridItem(.flexible()), GridItem(.flexible())] // 2열 고정
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<Goal> { $0.isArchived }) private var archivedGoals: [Goal]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Button {
                    dismiss()
                } label: {
                    Text("‹ GOALKEEPER")
                        .font(.caption)
                        .foregroundStyle(Color.gkGray)
                }
                .buttonStyle(.plain)
                
                Text("보관함")
                    .font(.title)
                Text("끝났거나 기간이 지난 것들입니다. 지우지 않고 남겨 두어 다음 계획의 근거로 씁니다.")
                    .font(.caption)
                    .foregroundStyle(Color.gkGray)
                
                if archivedGoals.isEmpty {
                    Text("아직 보관된 항목이 없습니다.")
                        .font(.subheadline).foregroundStyle(Color.gkGray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.black.opacity(0.2),
                                        style: StrokeStyle(dash: [4]))
                        )
                } else {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(archivedGoals) { goal in
                            ArchivedGoalCard(goal: goal)
                        }
                    }
                }
            }
            .padding(.horizontal, 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gkSurface)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct ArchivedGoalCard: View {
    var goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("완료")
                    .font(.caption)
                    .foregroundStyle(Color.gkGreen)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color.gkGreen.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Spacer()
                
                Text(goal.archivedLabel)
                    .font(.caption)
                    .foregroundStyle(Color.gkGray)
            }
            .padding(.bottom, 8)
            
            Text(goal.title).font(.headline)
            Text("\(goal.period) · 마일스톤 \(goal.milestones.count)")
                .font(.caption)
                .foregroundStyle(Color.gkGray)
        }
        .padding(.horizontal, 20).padding(.vertical, 16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.1), lineWidth: 0.5))
    }
}

#Preview {
    let container = try! ModelContainer(for: Goal.self, configurations: .init(isStoredInMemoryOnly: true))
    for goal in Goal.samples {
        container.mainContext.insert(goal)
    }
    return ArchiveView()
        .modelContainer(container)
}
