import SwiftUI
import SwiftData

struct MilestoneDetailView: View {
    let milestone: Milestone
    @State private var draftTitle = ""
    @Environment(\.modelContext) private var context
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // == 헤더 ==
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
                
                // == 카테고리별 ==
                ForEach(milestone.categories) { category in
                    CategorySection(category: category)
                }
                
                Divider()
            
                // == 카테고리 추가 ==
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
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.gkSurface)
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

private struct CategorySection: View {
    let category: Category
    @Environment(\.modelContext) private var context
    @State private var draftTaskTitle = ""
    @State private var draftCategoryName = ""
    @State private var isEditingCategory = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isEditingCategory {
                TextField("카테고리 제목", text: $draftCategoryName)
                    .textFieldStyle(.plain)
                    .font(.caption).foregroundStyle(Color.gkGray)
                    .onSubmit { saveTitle() }
            } else {
                Text(category.name)
                    .font(.caption).foregroundStyle(Color.gkGray)
                    .onTapGesture {
                        draftCategoryName = category.name
                        isEditingCategory = true
                    }
            }
            
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
    }
    
    private func addTask() {
        if draftTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty { return }
        
        let newTask = TaskItem(title: draftTaskTitle, tag: "Should", isDone: false)
        context.insert(newTask) // 저장소에 새로 등록
        category.tasks.append(newTask)
        try? context.save() // 디스크에 반영
        draftTaskTitle = "" // 입력창 초기화
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
