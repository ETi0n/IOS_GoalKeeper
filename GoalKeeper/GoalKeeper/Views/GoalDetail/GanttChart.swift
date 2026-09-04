import SwiftUI

struct CanttChart: View {
    let goal: Goal
    let selectedMilestone: Milestone?
    
    var body: some View {
        VStack {
            ForEach(goal.milestones.sorted { $0.scheduleStart > $1.scheduleStart }) { milestone in
                bar(for: milestone)
            }
        }
        .accessibilityHidden(true) // 시각적 보조 요소 - VoiceOver에 읽히지 않도록
    }
    
    private func bar(for milestone: Milestone) -> some View {
        let span = ganttSpan
    }
    
    private func barColor(for milestone: Milestone, isSelected: Bool) -> Color {
        
    }
    
    private func canttSpan(for milestone: Milestone, in goal: Goal) -> () {
        
    }
    
    private func todayMarkerRatio(in goal: Goal) -> Double? {
        
    }
}

#Preview {
    CanttChart()
}
