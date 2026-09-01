import SwiftUI
import SwiftData

struct MilestoneDetailView: View {
    let milestone: Milestone
    var initialCategory: Category? = nil
    @State private var selectedCategory: Category?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // == 헤더 ==
            VStack(alignment: .leading, spacing: Metrics.Spacing.lg) {
                HStack {
                    Text(milestone.status)
                        .font(.caption)
                        .foregroundStyle(milestone.status == "대기" ? Color.gkGray : .gkGreen)
                        .padding(.horizontal, Metrics.Spacing.sm).padding(.vertical, Metrics.Spacing.xs)
                        .overlay(RoundedRectangle(cornerRadius: Metrics.Radius.chip)
                            .stroke(milestone.status == "대기" ? Color.gkHairline : .gkGreenBorder, lineWidth: Metrics.Stroke.outline))
                    Text(milestone.due).font(.caption).foregroundStyle(Color.gkGray)
                }
                Text(milestone.title).font(.title2).fontWeight(.medium)
            }
            .padding(.horizontal, Metrics.Spacing.xxl).padding(.vertical, Metrics.Spacing.md)
            
            Divider()
            
            HStack(alignment: .top, spacing: 0) {
                // == 왼쪽: 카테고리 ==
                CategorySection(milestone: milestone, selectedCategory: $selectedCategory)
                
                Divider()
                
                // == 오른쪽: 선택 카테고리의 할 일 목록 ==
                if let selectedCategory {
                    TaskSection(category: selectedCategory)
                } else {
                    Text("카테고리를 고르세요.").foregroundStyle(Color.gkGray)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .background(Color.gkCard)
        .onAppear {
            selectedCategory = initialCategory ?? milestone.categories.first
        }
        .onChange(of: milestone.id) { _, _ in
            selectedCategory = milestone.categories.first // 마일스톤이 바뀌면 딥링크 무시하고 첫 카테고리로
        }
    }
}

#Preview {
    MilestoneDetailView(milestone: Goal.samples[0].milestones[0])
        .environment(UndoManager())
}
