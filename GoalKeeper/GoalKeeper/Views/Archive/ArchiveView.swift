import SwiftUI
import SwiftData

struct ArchiveView: View {
    private var isWide: Bool {
        UIDevice.current.userInterfaceIdiom != .phone
    }
    
    private var columns: [GridItem] {
        isWide ? [GridItem(.flexible()), GridItem(.flexible())] : [GridItem(.flexible())]
    }
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<Goal> { $0.isArchived }) private var archivedGoals: [Goal]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Metrics.Spacing.xl) {
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
                        .overlay(
                            RoundedRectangle(cornerRadius: Metrics.Radius.panel)
                                .stroke(Color.gkHairline, style: StrokeStyle(lineWidth: Metrics.Stroke.dashed, dash: [4]))
                        )
                } else {
                    LazyVGrid(columns: columns, spacing: Metrics.Spacing.md) {
                        ForEach(archivedGoals) { goal in
                            ArchivedGoalCard(goal: goal)
                        }
                    }
                }
            }
            .padding(.horizontal, isWide ? 100 : Metrics.Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gkSurface)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct ArchivedGoalCard: View {
    var goal: Goal
    @Environment(\.modelContext) private var context

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.Spacing.sm) {
            HStack {
                Text("완료")
                    .font(.caption)
                    .foregroundStyle(Color.gkGreen)
                    .padding(.horizontal, Metrics.Spacing.sm).padding(.vertical, Metrics.Spacing.xs)
                    .background(Color.gkGreenBG)
                    .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.chip))

                Spacer()

                Text(goal.archivedLabel)
                    .font(.caption)
                    .foregroundStyle(Color.gkGray)

                OverflowMenu {
                    Button("다시 꺼내기") {
                        goal.isArchived = false
                        try? context.save()
                    }
                }
            }
            .padding(.bottom, Metrics.Spacing.sm)

            Text(goal.title).font(.headline)
            Text("\(goal.period) · 마일스톤 \(goal.milestones?.count ?? 0)")
                .font(.caption)
                .foregroundStyle(Color.gkGray)

            if let reviewText = goal.reviewText, !reviewText.isEmpty {
                VStack(alignment: .leading, spacing: Metrics.Spacing.xs) {
                    Text("간단 후기")
                        .font(.caption2).fontWeight(.medium)
                        .foregroundStyle(Color.gkGreen)
                    Text(reviewText)
                        .font(.caption)
                        .foregroundStyle(Color.gkInk)
                }
                .padding(Metrics.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gkGreenBG)
                .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.control))
            }
        }
        .padding(.horizontal, Metrics.Spacing.xl).padding(.vertical, Metrics.Spacing.lg)
        .background(Color.gkCard)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.card))
        .overlay(RoundedRectangle(cornerRadius: Metrics.Radius.card).stroke(Color.gkHairline, lineWidth: Metrics.Stroke.hairline))
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
