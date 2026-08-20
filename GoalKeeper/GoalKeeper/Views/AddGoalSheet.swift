import SwiftUI
import SwiftData

struct AddGoalSheet: View {
    var editingGoal: Goal? = nil
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
                .navigationTitle(editingGoal == nil ? "새 목표" : "목표 수정")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("취소") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(editingGoal == nil ? "추가" : "저장") {
                            saveGoal()
                        }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                .onAppear {
                    if let editingGoal {
                        title = editingGoal.title
                        startDate = editingGoal.scheduleStart
                        dueDate = editingGoal.dueDate
                    }
                }
            }
        }
    
    private func saveGoal() {
        if let editingGoal {
            // 수정하기
            editingGoal.title = title
            editingGoal.scheduleStart = startDate
            editingGoal.dueDate = dueDate
        } else {
            // 새로 생성하기
            let newGoal = Goal(title: title, progress: 0,
                              scheduleStart: startDate, dueDate: dueDate)
            context.insert(newGoal)
        }
        
        try? context.save()
        dismiss()
    }
}

#Preview {
    AddGoalSheet()
}
