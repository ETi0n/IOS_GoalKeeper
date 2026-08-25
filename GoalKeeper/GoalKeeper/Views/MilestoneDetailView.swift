import SwiftUI
import SwiftData

struct MilestoneDetailView: View {
    let milestone: Milestone
    var initialCategory: Category? = nil
    @State private var selectedCategory: Category?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // == 헤더 ==
            VStack(spacing: 16) {
                HStack {
                    Text(milestone.status)
                        .font(.caption)
                        .foregroundStyle(milestone.status == "대기" ? Color.gkGray : .gkGreen)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(milestone.status == "대기" ? Color.gkGray.opacity(0.4) : .gkGreen.opacity(0.4), lineWidth: 1))
                    Text(milestone.due).font(.caption).foregroundStyle(Color.gkGray)
                }
                Text(milestone.title).font(.title2).fontWeight(.medium)
            }
            .padding(.horizontal, 24).padding(.vertical, 12)
            
            Divider()
            
            HStack(alignment: .top, spacing: 0) {
                // == 왼쪽: 카테고리 ==
                CategorySection(milestone: milestone, selectedCategory: $selectedCategory)
                
                Divider()
                
                // == 오른쪽: 선택 카테고리의 할 일 목록 ==
                if let selectedCategory {
                    TaskSection(category: selectedCategory)
                } else {
                    Text("카테고리를 고르세요.").foregroundStyle(Color.gkGray)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .background(Color.white)
        .onAppear {
            selectedCategory = initialCategory ?? milestone.categories.first
        }
        .onChange(of: milestone.id) { _, _ in
            selectedCategory = milestone.categories.first // 마일스톤이 바뀌면 딥링크 무시하고 첫 카테고리로
        }
    }
}

private struct CategorySection: View {
    let milestone: Milestone
    @State private var draftTitle = ""
    @Binding var selectedCategory: Category?
    @Environment(\.modelContext) private var context
    @Environment(UndoManager.self) private var undoManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12){
                Text("카테고리")
                    .font(.caption).foregroundStyle(Color.gkGray)
                
                ForEach(milestone.categories.filter { !undoManager.isPending($0.id) }) { category in
                    let isSelected = selectedCategory?.id == category.id

                    CategoryRow(milestone: milestone, category: category,
                                isSelected: isSelected, onDelete: {
                        if selectedCategory?.id == category.id {
                            selectedCategory = nil
                        }
                    })
                    .onTapGesture {
                        selectedCategory = category
                    }
                }
                
                HStack {
                    TextField("+ 카테고리 추가", text: $draftTitle)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 12)
                        .frame(height: 36)
                        .background(.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black.opacity(0.1), style: StrokeStyle(lineWidth: 1.5, dash: [4])))
                        .onSubmit(addCategory)
                    
                    Button("추가", action: addCategory)
                        .disabled(draftTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                        .foregroundStyle(draftTitle.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gkGray.opacity(0.6) : .gkGreen )
                }
            }
            .padding(24)
        }
        .frame(width: 280)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.gkSurface.opacity(0.8))
    }
    
    private func addCategory() {
        if draftTitle.trimmingCharacters(in: .whitespaces).isEmpty { return }
        
        let newCategory = Category(name: draftTitle, tasks: [])
        context.insert(newCategory)
        milestone.categories.append(newCategory)
        try? context.save()
        draftTitle = ""
    }
}

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
            HStack(spacing: 8) {
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
                
                Text("\(category.tasks.filter { $0.isDone }.count)/\(category.tasks.count)")
                    .font(.caption)
                    .foregroundStyle(Color.gkGreen)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color.gkGreen.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            ProgressView(value: category.progress)
                .tint(Color.gkGreen)
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
        .background(isSelected ? Color.white : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(isSelected ? Color.gkGreen : Color.black.opacity(0.1), lineWidth: 0.5))
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

struct TaskSection: View {
    let category: Category
    @State private var draftTaskTitle = ""
    @State private var draftTag: Moscow = .should
    @State private var filter: Moscow? = nil
    @State private var isBacklogExpanded = false
    @Environment(\.modelContext) private var context
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                filterChips
                
                ForEach(visibleTasks) { task in
                    TaskRow(task: task, category: category)
                }
                
                HStack(spacing: 8) {
                    TextField("+ 할 일 추가", text: $draftTaskTitle)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 12)
                        .frame(height: 36)
                        .background(.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black.opacity(0.1), style: StrokeStyle(lineWidth: 1.5, dash: [4])))
                        .onSubmit(addTask)
                    
                    ForEach(Moscow.allCases) { option in
                        Button {
                            draftTag = option
                        } label: {
                            Text(option.rawValue)
                                .font(.caption)
                                .foregroundStyle(option == draftTag ? .white : Color.gkGray)
                                .padding(.horizontal, 8).padding(.vertical, 6)
                                .background(option == draftTag ? Color.gkInk : .clear)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Button("추가", action: addTask)
                        .disabled(draftTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                        .foregroundStyle(draftTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gkGray.opacity(0.6) : .gkGreen )
                }
                
                backlogSection
            }
            .padding(24)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    // MARK: - 필터
    private var filterChips: some View {
        HStack(spacing: 4) {
            chip(title: "전체", value: nil)
            ForEach(Moscow.allCases.filter { $0 != .wont }) { option in
                chip(title: option.rawValue, value: option)
            }
        }
        .padding(3)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.05)))
    }

    private func chip(title: String, value: Moscow?) -> some View {
        let isOn = filter == value
        return Button {
            filter = value
        } label: {
            Text(title)
                .font(.caption)
                .foregroundStyle(isOn ? Color.gkInk : Color.gkGray)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(isOn ? Color.white : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
    
    private var visibleTasks: [TaskItem] {
        let notWont = category.tasks.filter { $0.tag != .wont }
        guard let filter else { return notWont }
        return notWont.filter { $0.tag == filter }
    }
    
    // MARK: - Won't 백로그
    private var backlogTasks: [TaskItem] {
        category.tasks.filter { $0.tag == .wont }
    }
    
    private var backlogSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                isBacklogExpanded.toggle()
            } label: {
                HStack {
                    Text("지금은 안 함 보관함")
                        .font(.caption)
                        .foregroundStyle(Color.gkGray)
                    Spacer()
                    Text("\(backlogTasks.count)개")
                        .font(.caption)
                        .foregroundStyle(Color.gkGray)
                }
            }
            .buttonStyle(.plain)

            if isBacklogExpanded {
                ForEach(backlogTasks) { task in
                    TaskRow(task: task, category: category)
                }
            }
        }
        .padding(.top, 8)
    }
    
    private func addTask() {
        if draftTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty { return }
        
        let newTask = TaskItem(title: draftTaskTitle, tag: draftTag, isDone: false)
        context.insert(newTask) // 저장소에 새로 등록
        category.tasks.append(newTask)
        try? context.save() // 디스크에 반영
        draftTaskTitle = "" // 입력창 초기화
    }
}

struct TaskRow: View {
    let task: TaskItem
    let category: Category
    @State private var isEditingTask = false
    @State private var isConfirmingDelete = false
    @State private var draftTitle = ""
    @Environment(\.modelContext) private var context
    
    var body: some View {
        HStack(spacing: 11) {
            // 체크 아이콘
            Button {
                task.isDone.toggle()
                task.doneDate = task.isDone ? Date() : nil
                try? context.save()
            } label: {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isDone ? Color.gkGreen : .gray.opacity(0.4))
            }
            .buttonStyle(.plain)
            
            // 제목
            if isEditingTask {
                TextField("할 일 제목", text: $draftTitle)
                    .textFieldStyle(.plain)
                    .onSubmit { saveTitle() }
            } else {
                Text(task.title)
                    .frame(maxWidth: .infinity, alignment: .leading) // 남는 공간 처리
                    .strikethrough(task.isDone)
                    .foregroundStyle(task.isDone ? Color.gkGray : .gkInk)
            }
            
            // 태그 배지
            Text(task.tag.rawValue)
                .font(.caption)
                .foregroundStyle(tagColor)
                .padding(.horizontal, 7).padding(.vertical, 4)
                .background(tagBackground)
                .clipShape(RoundedRectangle(cornerRadius: 5))
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
                    isEditingTask = true
                }
                Button("삭제", role: .destructive) { isConfirmingDelete = true }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.1), lineWidth: 0.5))
        .confirmationDialog("이 할 일을 삭제할까요?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("삭제", role: .destructive) {
                context.delete(task)
                category.tasks.removeAll { $0.id == task.id }
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
        case .should:           return .gkGreen.opacity(0.1)
        case .could, .wont:     return .clear
        }
    }
    
    private func saveTitle() {
        let trimmed = draftTitle.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            task.title = trimmed
            try? context.save()
        }
        isEditingTask = false
    }
}

#Preview {
    MilestoneDetailView(milestone: Goal.samples[0].milestones[0])
}
