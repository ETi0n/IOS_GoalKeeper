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
    
    var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        let doneCount = tasks.filter { $0.isDone }.count
        return Double(doneCount) / Double(tasks.count)
    }
}
