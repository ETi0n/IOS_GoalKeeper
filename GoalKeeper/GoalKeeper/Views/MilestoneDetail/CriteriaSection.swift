import SwiftUI
import SwiftData

struct CriteriaSection: View {
    let milestone: Milestone
    @State private var isExpanded = false
    @State private var isAdding = false
    @State private var draftTitle = ""
    @FocusState private var isFieldFocused: Bool
    @Environment(\.modelContext) private var context
    @Environment(UndoManager.self) private var undoManager

    private var visibleCriteria: [Criterion] {
        milestone.orderedCriteria.filter { !undoManager.isPending($0.id) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.Spacing.sm) {
            Button {
                withAnimation { isExpanded.toggle() }
            } label: {
                HStack {
                    Text("완료 조건")
                        .font(.subheadline).fontWeight(.medium)
                        .foregroundStyle(Color.gkGray)
                    Spacer()
                    Text("\(visibleCriteria.filter { $0.isMet }.count) / \(visibleCriteria.count) 충족")
                        .font(.caption)
                        .foregroundStyle(Color.gkGray)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(Color.gkMutedIcon)
                        .accessibilityHidden(true)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                ForEach(visibleCriteria) { criterion in
                    CriterionRow(milestone: milestone, criterion: criterion)
                }

                if isAdding {
                    HStack(spacing: Metrics.Spacing.sm) {
                        TextField("완료 조건", text: $draftTitle)
                            .textFieldStyle(.plain)
                            .font(.subheadline)
                            .focused($isFieldFocused)
                            .onSubmit(addCriterion)

                        Button("추가", action: addCriterion)
                            .disabled(draftTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                            .foregroundStyle(draftTitle.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gkGray : .gkGreen)
                    }
                    .padding(.horizontal, Metrics.Spacing.md)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .overlay(RoundedRectangle(cornerRadius: Metrics.Radius.control)
                        .stroke(Color.gkHairline, style: StrokeStyle(lineWidth: Metrics.Stroke.dashed, dash: [4])))
                    .onChange(of: isFieldFocused) { _, isFocused in
                        if !isFocused { addCriterion() }
                    }
                } else {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { isAdding = true }
                        isFieldFocused = true
                    } label: {
                        Text("+ 조건 추가")
                            .font(.subheadline)
                            .foregroundStyle(Color.gkGray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Metrics.Spacing.md)
                            .overlay(RoundedRectangle(cornerRadius: Metrics.Radius.control)
                                .stroke(Color.gkHairline, style: StrokeStyle(lineWidth: Metrics.Stroke.dashed, dash: [4])))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Metrics.Spacing.lg)
        .background(Color.gkSurface)
        .overlay(RoundedRectangle(cornerRadius: Metrics.Radius.control)
            .stroke(Color.gkHairline, style: StrokeStyle(lineWidth: Metrics.Stroke.hairline)))
        .onChange(of: milestone.id) { _, _ in
            isExpanded = false
            isAdding = false
            draftTitle = ""
        }
    }

    private func addCriterion() {
        let trimmed = draftTitle.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            let newCriterion = Criterion(text: trimmed)
            context.insert(newCriterion)
            milestone.criteria?.append(newCriterion)
            try? context.save()
        }
        draftTitle = ""
        isAdding = false
    }
}

private struct CriterionRow: View {
    let milestone: Milestone
    let criterion: Criterion
    @State private var isConfirmingDelete = false
    @Environment(\.modelContext) private var context
    @Environment(UndoManager.self) private var undoManager

    var body: some View {
        HStack(spacing: Metrics.Spacing.sm) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { criterion.isMet.toggle() }
                try? context.save()
            } label: {
                Image(systemName: criterion.isMet ? "checkmark.square.fill" : "square")
                    .foregroundStyle(criterion.isMet ? Color.gkGreen : Color.gkMutedIcon)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(criterion.isMet ? "완료 조건 충족 취소" : "완료 조건 충족 처리")

            Text(criterion.text)
                .strikethrough(criterion.isMet)
                .foregroundStyle(criterion.isMet ? Color.gkGray : Color.gkInk)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button {
                isConfirmingDelete = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.gkMutedIcon)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("완료 조건 삭제")
        }
        .font(.subheadline)
        .confirmationDialog("이 완료 조건을 삭제할까요?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("삭제", role: .destructive) {
                undoManager.scheduleDelete(id: criterion.id, message: "완료 조건 삭제됨") {
                    context.delete(criterion)
                    milestone.criteria?.removeAll { $0.id == criterion.id }
                    try? context.save()
                }
            }
            Button("취소", role: .cancel) {}
        }
    }
}

#Preview {
    CriteriaSection(milestone: Goal.samples[0].milestones![1])
        .padding()
        .environment(UndoManager())
        .modelContainer(for: Goal.self, inMemory: true)
}
