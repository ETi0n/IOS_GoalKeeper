import SwiftUI
import SwiftData

struct FinishGoalSheet: View {
    let goal: Goal
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var reviewText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("예: 계획보다 2주 늦었지만 끝냈다", text: $reviewText, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("한 줄 후기")
                } footer: {
                    Text("끝내며 한 줄만 남깁니다. 이 목표는 보관함으로 옮겨지고, 후기는 보관함에서 다시 볼 수 있어요.")
                }
            }
            .navigationTitle("목표 마무리")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("보관함으로", action: finish)
                }
            }
        }
    }

    private func finish() {
        goal.isArchived = true
        goal.archivedDate = Date()
        let trimmed = reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
        goal.reviewText = trimmed.isEmpty ? nil : trimmed
        try? context.save()
        dismiss()
    }
}

#Preview {
    FinishGoalSheet(goal: Goal.samples[0])
        .modelContainer(for: Goal.self, inMemory: true)
}
