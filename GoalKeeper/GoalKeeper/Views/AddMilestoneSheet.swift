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
                DatePicker("마감일", selection: $dueDate, displayedComponents: .date)
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
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
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
        }
    }
    
    private func saveMilestone() {
        if let editingMilestone {
            // 수정하기
            editingMilestone.title = title
            editingMilestone.scheduleStart = startDate
            editingMilestone.dueDate = dueDate
        } else {
            // 새로 생성하기
            let newMilestone = Milestone(title: title,
                                          progress: 0,
                                          scheduleStart: startDate,
                                          dueDate: dueDate,
                                          categories: [])
            context.insert(newMilestone)
            goal.milestones.append(newMilestone)
        }
        
        try? context.save()
        dismiss()
    }
}

#Preview {
    AddMilestoneSheet(goal: Goal.samples[0])
}
