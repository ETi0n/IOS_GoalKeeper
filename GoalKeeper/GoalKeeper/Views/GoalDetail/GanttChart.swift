import SwiftUI

struct GanttChart: View {
    let goal: Goal
    let selectedMilestone: Milestone?
    
    var body: some View {
        VStack {
            ForEach(goal.milestones.sorted { $0.scheduleStart < $1.scheduleStart }) { milestone in
                bar(for: milestone)
            }
        }
        .accessibilityHidden(true) // 시각적 보조 요소 - VoiceOver에 읽히지 않도록
    }
    
    private func bar(for milestone: Milestone) -> some View {
        let span = ganttSpan(for: milestone, in: goal)
        let isSelected = selectedMilestone?.id == milestone.id
        
        return GeometryReader { geomtry in // 부모가 준 공간
            let width = geomtry.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(Color.gkFaintFill) // Capsule: 양 끝이 둥근 알약 모양
                
                Capsule()
                    .fill(barColor(for: milestone, isSelected: isSelected))
                    .frame(width: max(4, width * span.width)) // width(0~1 사이 비율)을 전체 넓이로 비례
                    .offset(x: width * span.start) // x축으로 이동
                
                if let ratio = todayMarkerRatio(in: goal) {
                    Rectangle()
                        .fill(Color.gkGray)
                        .frame(width: 0.8)
                        .offset(x: width * ratio - 0.4) // 선 두께 0.8에서 절반 0.4를 빼 중앙에 오도록 배치
                }
            }
        }
        .frame(height: 6) // "GeometryReader야, 너는 세로 6pt 안에서만 놀아"
    }
    
    private func barColor(for milestone: Milestone, isSelected: Bool) -> Color {
        if milestone.status == "완료" { return Color.gkHairline }
        return isSelected ? Color.gkGreen : Color.gkGray
    }
    
    private func ganttSpan(for milestone: Milestone, in goal: Goal) -> (start: Double, width: Double) {
        let totalStart = goal.scheduleStart.timeIntervalSince1970 // timeIntervalSince1970 : 1970년 이후 몇 초가 지났는지 숫자로 변경
        let totalEnd = goal.dueDate.timeIntervalSince1970
        let totalDuration = max(totalEnd - totalStart, 1) // 0이 되지 않도록(날짜끼리 뺄셈은 안되지만 숫자로 변경시 계산 가능)
        
        let milestoneStart = milestone.scheduleStart.timeIntervalSince1970
        let milestoneEnd = milestone.dueDate.timeIntervalSince1970
        
        let start = (milestoneStart - totalStart) / totalDuration // 0~1 사이, 전체 기간 중 시작 위치
        let width = (milestoneEnd - milestoneStart) / totalDuration // 0~1 사이, 전체 기간 중 차지 비율
        
        return (start, width)
    }
    
    private func todayMarkerRatio(in goal: Goal) -> Double? {
        let totalStart = goal.scheduleStart.timeIntervalSince1970
        let totalEnd = goal.dueDate.timeIntervalSince1970
        let totalDuration = max(totalEnd - totalStart, 1)
        let ratio = (Date().timeIntervalSince1970 - totalStart) / totalDuration
        return (0...1).contains(ratio) ? ratio : nil // 목표 기간 밖이라면 표시 안 함
    }
}

#Preview {
    GanttChart(goal: Goal.samples[0], selectedMilestone: Goal.samples[0].milestones[1])
        .padding()
        .frame(width: 300)
}
