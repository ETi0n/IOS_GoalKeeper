import SwiftUI
import SwiftData

struct CategoryChipBar: View {
    let milestone: Milestone
    @Binding var selectedCategory: Category?
    @State private var isAddingCategory = false
    @State private var draftTitle = ""
    @State private var editingCategory: Category?
    @State private var draftEditTitle = ""
    @State private var categoryPendingDelete: Category?
    @FocusState private var isAddFieldFocused: Bool
    @Environment(\.modelContext) private var context
    @Environment(UndoManager.self) private var undoManager

    private var visibleCategories: [Category] {
        milestone.orderedCategories.filter { !undoManager.isPending($0.id) }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading) {
                Text("카테고리 \(visibleCategories.count)개")
                    .font(.caption)
                    .foregroundStyle(Color.gkGray)

                HStack(spacing: Metrics.Spacing.sm) {
                    ForEach(visibleCategories) { category in
                        if editingCategory?.id == category.id {
                            TextField("카테고리 이름", text: $draftEditTitle)
                                .font(.caption)
                                .tint(Color.gkGray)
                                .textFieldStyle(.plain)
                                .frame(width: 100)
                                .padding(.horizontal, Metrics.Spacing.sm).padding(.vertical, Metrics.Spacing.xs)
                                .background(Color.gkSurface)
                                .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.control))
                                .onSubmit { saveEdit(for: category) }
                        } else {
                            chip(for: category)
                        }
                    }

                    if isAddingCategory {
                        TextField("카테고리 이름", text: $draftTitle)
                            .font(.caption)
                            .tint(Color.gkGray)
                            .textFieldStyle(.plain)
                            .frame(width: 100)
                            .padding(.horizontal, Metrics.Spacing.sm).padding(.vertical, Metrics.Spacing.xs)
                            .background(Color.gkSurface)
                            .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.control))
                            .focused($isAddFieldFocused)
                            .onSubmit(addCategory)
                    } else {
                        Button {
                            withAnimation { isAddingCategory = true }
                            isAddFieldFocused = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.caption)
                                .foregroundStyle(Color.gkHairline)
                                .padding(Metrics.Spacing.xs)
                                .overlay(RoundedRectangle(cornerRadius: Metrics.Radius.chip)
                                    .stroke(Color.gkHairline, style: StrokeStyle(lineWidth: Metrics.Stroke.dashed, dash: [4])))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("카테고리 추가")
                    }
                }
            }
        }
        .padding(.horizontal, Metrics.Spacing.xxl)
        .padding(.top, Metrics.Spacing.lg)
        .onChange(of: milestone.id) { _, _ in
            isAddingCategory = false
            draftTitle = ""
            editingCategory = nil
            categoryPendingDelete = nil
        }
        .onChange(of: isAddFieldFocused) { _, isFocused in
            if !isFocused && isAddingCategory { // 다른 곳을 눌렀을 때 입력 값이 있다면 저장
                addCategory()
            }
        }
        .confirmationDialog(
            "이 카테고리를 삭제할까요?",
            isPresented: Binding(
                get: { categoryPendingDelete != nil },
                set: { if !$0 { categoryPendingDelete = nil } }
            ),
            titleVisibility: .visible,
            presenting: categoryPendingDelete
        ) { category in
            Button("삭제", role: .destructive) {
                undoManager.scheduleDelete(id: category.id, message: "\"\(category.name)\" 삭제됨") {
                    context.delete(category)
                    milestone.categories?.removeAll { $0.id == category.id }
                    try? context.save()
                    if selectedCategory?.id == category.id {
                        selectedCategory = nil
                    }
                }
            }
            Button("취소", role: .cancel) {}
        }
    }

    private func chip(for category: Category) -> some View {
        let isOn = selectedCategory?.id == category.id
        return Button {
            selectedCategory = category
        } label: {
            Text(category.name)
                .font(.caption)
                .foregroundStyle(isOn ? Color.gkGreen : Color.gkGray)
                .padding(.horizontal, Metrics.Spacing.sm).padding(.vertical, Metrics.Spacing.xs)
                .background(isOn ? Color.gkGreenBG : .gkSurface)
                .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.control))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("수정") {
                draftEditTitle = category.name
                editingCategory = category
            }
            Button("삭제", role: .destructive) {
                categoryPendingDelete = category
            }
        }
    }

    private func addCategory() {
        let trimmed = draftTitle.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            let newCategory = Category(name: trimmed, tasks: [])
            context.insert(newCategory)
            milestone.categories?.append(newCategory)
            try? context.save()
        }
        draftTitle = ""
        isAddingCategory = false
    }

    private func saveEdit(for category: Category) {
        let trimmed = draftEditTitle.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            category.name = trimmed
            try? context.save()
        }
        editingCategory = nil
    }
}
