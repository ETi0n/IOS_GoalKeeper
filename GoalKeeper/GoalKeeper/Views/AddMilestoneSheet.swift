import SwiftUI
import SwiftData

struct AddMilestoneSheet: View {
    let goal: Goal
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
            .navigationTitle("마일스톤 추가")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        let newMilestone = Milestone(title: title,
                                                      progress: 0,
                                                      scheduleStart: startDate,
                                                      dueDate: dueDate,
                                                      categories: [])
                        context.insert(newMilestone)
                        goal.milestones.append(newMilestone)
                        try? context.save()
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddMilestoneSheet(goal: Goal.samples[0])
}
