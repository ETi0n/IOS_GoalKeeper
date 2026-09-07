import SwiftUI
import SwiftData

struct TaskRow: View {
    let task: TaskItem
    let category: Category
    @State private var isEditingTask = false
    @State private var isConfirmingDelete = false
    @State private var draftTitle = ""
    @State private var draftNote = ""
    @Environment(\.modelContext) private var context
    
    var body: some View {
        HStack(spacing: Metrics.Spacing.md) {
            // 체크 아이콘
            Button {
                task.isDone.toggle()
                task.doneDate = task.isDone ? Date() : nil
                try? context.save()
            } label: {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isDone ? Color.gkGreen : .gkMutedIcon)
            }
            .buttonStyle(.plain)
            
            // 제목 + 메모
            if isEditingTask {
                VStack(alignment: .leading, spacing: Metrics.Spacing.xs) {
                    TextField("할 일 제목", text: $draftTitle)
                        .textFieldStyle(.plain)
                        .onSubmit { saveEdits() }
                    TextField("메모 (선택)", text: $draftNote)
                        .textFieldStyle(.plain)
                        .font(.caption)
                        .foregroundStyle(Color.gkGray)
                        .onSubmit { saveEdits() }
                }
            } else {
                VStack(alignment: .leading, spacing: Metrics.Spacing.xs) {
                    Text(task.title)
                        .strikethrough(task.isDone)
                        .foregroundStyle(task.isDone ? Color.gkGray : .gkInk)
                    if let note = task.note, !note.isEmpty {
                        HStack(spacing: Metrics.Spacing.xs) {
                            Image(systemName: "note.text")
                                .font(.caption2)
                                .foregroundStyle(Color.gkMutedIcon)
                            Text(note)
                                .font(.caption)
                                .foregroundStyle(Color.gkGray)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading) // 남는 공간 처리
            }
            
            // 태그 배지
            Text(task.tag.rawValue)
                .font(.caption)
                .foregroundStyle(tagColor)
                .padding(.horizontal, Metrics.Spacing.sm).padding(.vertical, Metrics.Spacing.xs)
                .background(tagBackground)
                .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.chip))
                .contextMenu {
                    ForEach(Moscow.allCases) { option in
                        Button(option.rawValue) {
                            task.tag = option
                            try? context.save()
                        }
                    }
                }
            
            OverflowMenu {
                Button("수정") {
                    draftTitle = task.title
                    draftNote = task.note ?? ""
                    isEditingTask = true
                }
                Button("삭제", role: .destructive) { isConfirmingDelete = true }
            }
        }
        .padding(.horizontal, Metrics.Spacing.lg).padding(.vertical, Metrics.Spacing.md)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.card))
        .overlay(RoundedRectangle(cornerRadius: Metrics.Radius.card).stroke(Color.gkHairline, lineWidth: Metrics.Stroke.hairline))
        .confirmationDialog("이 할 일을 삭제할까요?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("삭제", role: .destructive) {
                context.delete(task)
                category.tasks?.removeAll { $0.id == task.id }
                try? context.save()
            }
            Button("취소", role: .cancel) {}
        }
    }
    
    // MARK: - helper
    private var tagColor: Color {
        switch task.tag {
        case .must:     return .gkRed
        case .should:   return .gkGreen
        case .could:    return .gkGray
        case .wont:     return .gkGray.opacity(0.6)
        }
    }
    
    private var tagBackground: Color {
        switch task.tag {
        case .must:             return .gkRedBG
        case .should:           return .gkGreenBG
        case .could, .wont:     return .clear
        }
    }
    
    private func saveEdits() {
        let trimmedTitle = draftTitle.trimmingCharacters(in: .whitespaces)
        if !trimmedTitle.isEmpty {
            task.title = trimmedTitle
        }
        let trimmedNote = draftNote.trimmingCharacters(in: .whitespaces)
        task.note = trimmedNote.isEmpty ? nil : trimmedNote
        try? context.save()
        isEditingTask = false
    }
}

#Preview {
    let category = Goal.samples[0].milestones![1].categories![0]
    return TaskRow(task: category.tasks![0], category: category)
        .padding()
        .modelContainer(for: Goal.self, inMemory: true)
}
