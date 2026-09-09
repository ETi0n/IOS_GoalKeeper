import SwiftUI
import SwiftData

struct MilestoneDetailView: View {
    let milestone: Milestone
    var initialCategory: Category? = nil
    @State private var selectedCategory: Category?
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dismiss) private var dismiss

    // 아이폰에서만 GoalDetailView가 이 화면을 push로 보여주고,
    // 아이패드에서는 옆에 나란히 끼워 넣는 방식이라 뒤로가기 버튼이 따로 필요 없음
    private var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }

    var body: some View {
        GeometryReader { geometry in
            let isWide = sizeClass == .regular && geometry.size.width > Metrics.Layout.milestoneDetailMinWidth

            VStack(alignment: .leading, spacing: 0) {

                // == 헤더 ==
                VStack(alignment: .leading, spacing: Metrics.Spacing.lg) {
                    if isPhone {
                        Button { dismiss() } label: {
                            Text("‹ \(milestone.goal?.title ?? "목표")")
                                .font(.caption)
                                .foregroundStyle(Color.gkGray)
                        }
                        .buttonStyle(.plain)
                    }
                    HStack {
                        Text(milestone.status)
                            .font(.caption)
                            .foregroundStyle(statusTextColor)
                            .padding(.horizontal, Metrics.Spacing.sm).padding(.vertical, Metrics.Spacing.xs)
                            .background(statusBackgroundColor)
                            .overlay(RoundedRectangle(cornerRadius: Metrics.Radius.chip)
                                .stroke(statusBorderColor, lineWidth: Metrics.Stroke.outline))
                        Text(milestone.due).font(.caption).foregroundStyle(Color.gkGray)
                    }
                    Text(milestone.title).font(.title2).fontWeight(.medium)

                    CriteriaSection(milestone: milestone)
                }
                .padding(.horizontal, Metrics.Spacing.xxl).padding(.vertical, Metrics.Spacing.md)
                
                Divider()
                
                if isWide {
                    HStack(alignment: .top, spacing: 0) {
                        // == 왼쪽: 카테고리 ==
                        CategorySection(milestone: milestone, selectedCategory: $selectedCategory)
                        
                        Divider()
                        
                        // == 오른쪽: 선택 카테고리의 할 일 목록 ==
                        if let selectedCategory {
                            TaskSection(category: selectedCategory)
                        } else {
                            Text("카테고리를 고르세요.")
                                .foregroundStyle(Color.gkGray)
                                .padding(Metrics.Spacing.xxl)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        }
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        CategoryChipBar(milestone: milestone, selectedCategory: $selectedCategory)
                        
                        if let selectedCategory {
                            TaskSection(category: selectedCategory)
                        } else {
                            Text("카테고리를 고르세요.")
                                .foregroundStyle(Color.gkGray)
                                .padding(Metrics.Spacing.xxl)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .background(Color.gkCard)
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                selectedCategory = initialCategory ?? milestone.categories?.first
            }
            .onChange(of: milestone.id) { _, _ in
                selectedCategory = milestone.categories?.first // 마일스톤이 바뀌면 딥링크 무시하고 첫 카테고리로
            }
        }
    }

    private var statusTextColor: Color {
        switch milestone.status {
        case "대기": return Color.gkGray
        case "지연": return Color.gkRed
        default: return Color.gkGreen
        }
    }

    private var statusBackgroundColor: Color {
        switch milestone.status {
        case "완료": return Color.gkGreenBG
        case "지연": return Color.gkRedBG
        default: return .clear
        }
    }

    private var statusBorderColor: Color {
        switch milestone.status {
        case "대기": return Color.gkHairline
        case "지연": return Color.gkRedBorder
        default: return Color.gkGreenBorder
        }
    }
}

#Preview {
    MilestoneDetailView(milestone: Goal.samples[0].milestones![0])
        .environment(UndoManager())
}
