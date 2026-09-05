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

    private var isWide: Bool {
        UIDevice.current.userInterfaceIdiom != .phone
    }

    var body: some View {
        Group {
            if isWide {
                HStack(alignment: .top, spacing: 0) {
                    milestoneColumn(isWide: true)
                        .frame(width: 300)
                        .frame(maxHeight: .infinity, alignment: .top)

                    Divider()

                    if let selectedMilestone {
                        MilestoneDetailView(milestone: selectedMilestone, initialCategory: initialCategory)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Text("마일스톤을 고르세요.")
                            .foregroundStyle(Color.gkGray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            } else {
                milestoneColumn(isWide: false)
            }
        }
        .background(Color.gkSurface)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            selectedMilestone = initialMilestone ?? goal.milestones.first
        }
    }

    @ViewBuilder
    private func milestoneColumn(isWide: Bool) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Metrics.Spacing.md) {
                Button { dismiss() } label: {
                    Text("‹ GOALKEEPER")
                        .font(.caption)
                        .foregroundStyle(Color.gkGray)
                }
                .buttonStyle(.plain)

                Text(goal.title).font(.title).fontWeight(.medium)
                Text("\(goal.period)   ·   \(goal.dDay)")
                    .font(.caption).foregroundStyle(Color.gkInk)

                ProgressView(value: goal.progress).tint(Color.gkGreen)

                GanttChart(goal: goal, selectedMilestone: selectedMilestone)
                    .padding(.top, Metrics.Spacing.xs)

                Text("마일스톤 \(goal.milestones.count)개")
                    .font(.caption).foregroundStyle(Color.gkGray)

                ForEach(goal.milestones.filter { !undoManager.isPending($0.id) }) { milestone in
                    if isWide {
                        MilestoneCard(goal: goal, milestone: milestone,
                                      isSelected: selectedMilestone?.id == milestone.id,
                                      onDelete: {
                                          if selectedMilestone?.id == milestone.id {
                                              selectedMilestone = nil
                                          }
                                      })
                            .onTapGesture { selectedMilestone = milestone }
                    } else {
                        NavigationLink {
                            MilestoneDetailView(milestone: milestone)
                        } label: {
                            MilestoneCard(goal: goal, milestone: milestone,
                                          isSelected: false, onDelete: {})
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button("+ 마일스톤 추가") { isAddingMilestone = true }
                    .foregroundStyle(Color.gkGray)
                    .buttonStyle(.plain)
                    .padding(.vertical, Metrics.Spacing.md)
                    .frame(maxWidth: .infinity)
                    .background(.clear)
                    .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.card))
                    .overlay(RoundedRectangle(cornerRadius: Metrics.Radius.card)
                        .stroke(Color.gkHairline, style: StrokeStyle(lineWidth: Metrics.Stroke.dashed, dash: [4])))
                    .sheet(isPresented: $isAddingMilestone) {
                        AddMilestoneSheet(goal: goal)
                    }
            }
            .padding(Metrics.Spacing.xxl)
        }
    }
}

#Preview {
    GoalDetailView(goal: Goal.samples[0])
        .environment(UndoManager())
}
