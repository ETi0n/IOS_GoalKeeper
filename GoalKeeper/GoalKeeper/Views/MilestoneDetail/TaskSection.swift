import SwiftUI
import SwiftData

struct TaskSection: View {
    let category: Category
    @State private var draftTaskTitle = ""
    @State private var draftTaskNote = ""
    @State private var draftTag: Moscow = .should
    @State private var filter: Moscow? = nil
    @Environment(\.modelContext) private var context
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack(spacing: Metrics.Spacing.xs) {
                    Text(category.name)
                        .font(.subheadline).fontWeight(.medium)
                    Text("\(category.countedTasks.filter { $0.isDone }.count)/\(category.countedTasks.count)")
                        .font(.caption)
                        .foregroundStyle(Color.gkGray)
                }
                
                filterChips 
                
                ForEach(visibleTasks) { task in
                    TaskRow(task: task, category: category)
                }
                
                HStack(spacing: Metrics.Spacing.sm) {
                    ForEach(Moscow.allCases) { option in
                        Button {
                            draftTag = option
                        } label: {
                            Text(option.rawValue)
                                .font(.caption)
                                .foregroundStyle(option == draftTag ? .white : Color.gkGray)
                                .padding(.horizontal, Metrics.Spacing.sm).padding(.vertical, Metrics.Spacing.xs)
                                .background(option == draftTag ? Color.gkInk : .clear)
                                .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.chip))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, Metrics.Spacing.md)
                taskInputField
                backlogSection
            }
            .padding(Metrics.Spacing.xxl)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    private var taskInputField: some View {
        VStack(spacing: Metrics.Spacing.xs) {
            TextField("+ 할 일 추가", text: $draftTaskTitle)
                .textFieldStyle(.plain)
                .frame(height: 36)
                .padding(.horizontal, Metrics.Spacing.lg)
                .padding(.top, Metrics.Spacing.xs)
                .background(.clear)
                .onSubmit(addTask)
            
            Divider()
                .foregroundStyle(Color.gkHairline)
                .padding(.horizontal, Metrics.Spacing.md)
            
            HStack(spacing: Metrics.Spacing.xs) {
                Image(systemName: "note.text")
                    .font(.caption)
                    .foregroundStyle(Color.gkMutedIcon)
                TextField("메모 (선택)", text: $draftTaskNote)
                    .textFieldStyle(.plain)
                    .font(.caption)
                    .foregroundStyle(Color.gkGray)
                    .onSubmit(addTask)
            }
            .padding(.horizontal, Metrics.Spacing.lg)
            .padding(.top, Metrics.Spacing.xs)
            .padding(.bottom, Metrics.Spacing.sm)
        }
        .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.control))
        .overlay(RoundedRectangle(cornerRadius: Metrics.Radius.control).stroke(Color.gkHairline, style: StrokeStyle(lineWidth: Metrics.Stroke.dashed, dash: [4])))
    }
    
    // MARK: - 필터
    private var filterChips: some View {
        HStack(spacing: Metrics.Spacing.xs) {
            chip(title: "전체", value: nil)
            ForEach(Moscow.allCases.filter { $0 != .wont }) { option in
                chip(title: option.rawValue, value: option)
            }
        }
        .padding(Metrics.Spacing.xs)
        .background(RoundedRectangle(cornerRadius: Metrics.Radius.chip).fill(Color.gkFaintFill))
    }

    private func chip(title: String, value: Moscow?) -> some View {
        let isOn = filter == value
        return Button {
            filter = value
        } label: {
            Text(title)
                .font(.caption)
                .foregroundStyle(isOn ? Color.gkInk : Color.gkGray)
                .padding(.horizontal, Metrics.Spacing.sm).padding(.vertical, Metrics.Spacing.xs)
                .background(isOn ? Color.white : .clear)
                .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.control))
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
        VStack(alignment: .leading, spacing: Metrics.Spacing.sm) {
            HStack {
                Text("지금은 안 함 보관함")
                    .font(.caption)
                    .foregroundStyle(Color.gkGray)
                Spacer()
                Text("\(backlogTasks.count)개")
                    .font(.caption)
                    .foregroundStyle(Color.gkGray)
            }

            ForEach(backlogTasks) { task in
                TaskRow(task: task, category: category)
            }
        }
        .padding(.top, Metrics.Spacing.sm)
    }
    
    private func addTask() {
        if draftTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty { return }

        let trimmedNote = draftTaskNote.trimmingCharacters(in: .whitespaces)
        let newTask = TaskItem(title: draftTaskTitle, tag: draftTag, isDone: false,
                                note: trimmedNote.isEmpty ? nil : trimmedNote)
        context.insert(newTask) // 저장소에 새로 등록
        category.tasks.append(newTask)
        try? context.save() // 디스크에 반영
        draftTaskTitle = "" // 입력창 초기화
        draftTaskNote = ""
    }
}

#Preview {
    TaskSection(category: Goal.samples[0].milestones[1].categories[0])
        .modelContainer(for: Goal.self, inMemory: true)
}
