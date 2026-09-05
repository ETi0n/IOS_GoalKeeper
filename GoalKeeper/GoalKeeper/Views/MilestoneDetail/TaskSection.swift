import SwiftUI
import SwiftData

struct TaskSection: View {
    let category: Category
    @State private var draftTaskTitle = ""
    @State private var draftTag: Moscow = .should
    @State private var filter: Moscow? = nil
    @State private var isBacklogExpanded = false
    @Environment(\.modelContext) private var context
    
    private var isWide: Bool {
        UIDevice.current.userInterfaceIdiom != .phone
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack(spacing: Metrics.Spacing.xs) {
                    Text(category.name)
                        .font(.subheadline).fontWeight(.medium)
                    Text("\(category.tasks.filter { $0.isDone }.count)/\(category.tasks.count)")
                        .font(.caption)
                        .foregroundStyle(Color.gkGray)
                }
                .padding(.bottom, Metrics.Spacing.xs)
                
                filterChips
                
                ForEach(visibleTasks) { task in
                    TaskRow(task: task, category: category)
                }
                
                HStack(spacing: Metrics.Spacing.sm) {
                    if isWide {
                        taskInputField
                    }
                    
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
                    
                    if isWide {
                        addButton
                    }
                }
                
                if !isWide {
                    HStack {
                        taskInputField
                        addButton
                    }
                }
                
                backlogSection
            }
            .padding(Metrics.Spacing.xxl)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    private var taskInputField: some View {
        TextField("+ 할 일 추가", text: $draftTaskTitle)
            .textFieldStyle(.plain)
            .padding(.horizontal, Metrics.Spacing.md)
            .frame(height: 36)
            .background(.clear)
            .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.control))
            .overlay(RoundedRectangle(cornerRadius: Metrics.Radius.control).stroke(Color.gkHairline, style: StrokeStyle(lineWidth: Metrics.Stroke.dashed, dash: [4])))
            .onSubmit(addTask)
    }
    
    private var addButton: some View {
        Button("추가", action: addTask)
            .disabled(draftTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            .foregroundStyle(draftTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gkGray : .gkGreen )
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
        .padding(.top, Metrics.Spacing.sm)
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

#Preview {
    TaskSection(category: Goal.samples[0].milestones[1].categories[0])
        .modelContainer(for: Goal.self, inMemory: true)
}
