import SwiftUI
import SwiftData

struct CategoryRow: View {
    let milestone: Milestone
    let category: Category
    let isSelected: Bool
    var onDelete: () -> Void
    @State private var draftCategoryName = ""
    @State private var isEditingCategory = false
    @State private var isConfirmingDelete = false
    @Environment(\.modelContext) private var context
    @Environment(UndoManager.self) private var undoManager
    
    var body: some View {
        VStack{
            HStack(spacing: Metrics.Spacing.sm) {
                if isEditingCategory {
                    TextField("카테고리 제목", text: $draftCategoryName)
                        .textFieldStyle(.plain)
                        .onSubmit { saveTitle() }
                } else {
                    Text(category.name)
                }
                
                Spacer()
                
                OverflowMenu {
                    Button("수정") {
                        draftCategoryName = category.name
                        isEditingCategory = true
                    }
                    Button("삭제", role: .destructive) { isConfirmingDelete = true }
                }
                
                Text("\(category.countedTasks.filter { $0.isDone }.count)/\(category.countedTasks.count)")
                    .font(.caption)
                    .foregroundStyle(Color.gkGreen)
                    .padding(.horizontal, Metrics.Spacing.md).padding(.vertical, Metrics.Spacing.xs)
                    .background(Color.gkGreenBG)
                    .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.chip))
            }
            
            ProgressView(value: category.progress)
                .tint(Color.gkGreen)
        }
        .padding(.horizontal, Metrics.Spacing.lg).padding(.vertical, Metrics.Spacing.md)
        .background(isSelected ? Color.white : .clear)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.card))
        .overlay(RoundedRectangle(cornerRadius: Metrics.Radius.card).stroke(isSelected ? Color.gkGreenBorder : Color.gkHairline, lineWidth: Metrics.Stroke.hairline))
        .confirmationDialog("이 카테고리를 삭제할까요?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("삭제", role: .destructive) {
                undoManager.scheduleDelete(id: category.id, message: "\"\(category.name)\" 삭제됨") {
                    context.delete(category)
                    milestone.categories.removeAll { $0.id == category.id }
                    try? context.save()
                    onDelete()
                }
            }
            Button("취소", role: .cancel) {}
        }
    }
    
    private func saveTitle() {
        let trimmed = draftCategoryName.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            category.name = draftCategoryName
            try? context.save()
        }
        isEditingCategory = false
    }
}

#Preview {
    CategoryRow(milestone: Goal.samples[0].milestones[0],
                category: Goal.samples[0].milestones[0].categories[0],
                isSelected: true,
                onDelete: {})
        .padding()
        .environment(UndoManager())
        .modelContainer(for: Goal.self, inMemory: true)
}
