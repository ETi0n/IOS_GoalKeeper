import SwiftUI
import SwiftData

struct AddMilestoneSheet: View {
    let goal: Goal
    var editingMilestone: Milestone? = nil
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var startDate = Date()
    @State private var dueDate = Date()

    var body: some View {
        NavigationStack {
            Form {
                TextField("제목", text: $title)
                DatePicker("시작일", selection: $startDate, displayedComponents: .date)
                DatePicker("마감일", selection: $dueDate, in: startDate..., displayedComponents: .date)
            }
            .navigationTitle(editingMilestone == nil ? "마일스톤 추가" : "마일스톤 수정")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingMilestone == nil ? "추가" : "저장") {
                        saveMilestone()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || dueDate < startDate)
                }
            }
            .onAppear {
                // 만약 수정이라면 사전값 대입
                if let editingMilestone {
                    title = editingMilestone.title
                    startDate = editingMilestone.scheduleStart
                    dueDate = editingMilestone.dueDate
                }
            }
            .onChange(of: startDate) { _, newValue in
                if dueDate < newValue { dueDate = newValue } // 시작일을 마감일보다 늦게 옮기면 마감일도 같이 밀어줌
            }
        }
    }
    
    private func saveMilestone() {
        if let editingMilestone {
            // 수정하기
            editingMilestone.title = title
            editingMilestone.scheduleStart = startDate
            editingMilestone.dueDate = dueDate
            NotificationManager.shared.cancelMilestoneReminder(id: editingMilestone.notificationID)
            NotificationManager.shared.scheduleMilestoneReminder(id: editingMilestone.notificationID, title: title, dueDate: dueDate)
        } else {
            // 새로 생성하기
            let newMilestone = Milestone(title: title,
                                          scheduleStart: startDate,
                                          dueDate: dueDate,
                                          categories: [])
            context.insert(newMilestone)
            goal.milestones?.append(newMilestone)
            NotificationManager.shared.scheduleMilestoneReminder(id: newMilestone.notificationID, title: title, dueDate: dueDate)
        }
        
        try? context.save()
        dismiss()
    }
}

#Preview {
    AddMilestoneSheet(goal: Goal.samples[0])
}
