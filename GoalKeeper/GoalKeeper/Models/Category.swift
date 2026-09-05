import SwiftUI
import SwiftData

@Model
class Category: Identifiable {
    var name: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var tasks: [TaskItem] = []
    
    init(name: String, createdAt: Date = Date(), tasks: [TaskItem]) {
        self.name = name
        self.createdAt = createdAt
        self.tasks = tasks
    }
    
    // "지금은 안 함(Won't)" 태그는 진행도/개수 계산에서 제외
    var countedTasks: [TaskItem] {
        tasks.filter { $0.tag != .wont }
    }

    var progress: Double {
        guard !countedTasks.isEmpty else { return 0 }
        let doneCount = countedTasks.filter { $0.isDone }.count
        return Double(doneCount) / Double(countedTasks.count)
    }
}
