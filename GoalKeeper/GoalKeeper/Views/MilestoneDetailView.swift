import SwiftUI
import SwiftData

struct MilestoneDetailView: View {
    let milestone: Milestone
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
            selectedCategory = milestone.categories.first
        }
    }
}

private struct CategorySection: View {
    let milestone: Milestone
    @State private var draftTitle = ""
    @Binding var selectedCategory: Category?
    @Environment(\.modelContext) private var context
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12){
                Text("카테고리")
                    .font(.caption).foregroundStyle(Color.gkGray)
                
                ForEach(milestone.categories) { category in
                    CategoryRow(category: category,
                                isSelected: selectedCategory?.id == category.id)
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
    let category: Category
    let isSelected: Bool
    @State private var draftCategoryName = ""
    @State private var isEditingCategory = false
    @Environment(\.modelContext) private var context
    
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
                
                Button {
                    draftCategoryName = category.name
                    isEditingCategory = true
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray.opacity(0.4))
                }
                .buttonStyle(.plain)
                
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
    @Environment(\.modelContext) private var context
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(category.tasks) { task in
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
                    
                    Button("추가", action: addTask)
                        .disabled(draftTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                        .foregroundStyle(draftTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gkGray.opacity(0.6) : .gkGreen )
                }
            }
            .padding(24)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    private func addTask() {
        if draftTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty { return }
        
        let newTask = TaskItem(title: draftTaskTitle, tag: "Should", isDone: false)
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
                    .onTapGesture {
                        draftTitle = task.title
                        isEditingTask = true
                    }
            }
            
            // 삭제
            Button {
                context.delete(task)
                category.tasks.removeAll { $0.id == task.id }
                try? context.save()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundStyle(.gray.opacity(0.4))
            }
            .buttonStyle(.plain)
            
            // 태그 배지
            Text(task.tag)
                .font(.caption)
                .foregroundStyle(tagColor)
                .padding(.horizontal, 7).padding(.vertical, 4)
                .background(tagBackground)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.1), lineWidth: 0.5))
    }
    
    // MARK: - helper
    private var tagColor: Color {
        switch task.tag {
        case "Must":    return .gkRed
        case "Should":  return .gkGreen
        default:        return .gkGray
        }
    }
    
    private var tagBackground: Color {
        switch task.tag {
        case "Must":    return .gkRedBG
        case "Should":  return .gkGreen.opacity(0.1)
        default:        return .clear
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
