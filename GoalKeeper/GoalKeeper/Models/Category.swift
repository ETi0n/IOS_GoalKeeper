import SwiftUI
import SwiftData

@Model
class Category: Identifiable {
    var name: String
    
    @Relationship(deleteRule: .cascade)
    var tasks: [TaskItem] = []
    
    init(name: String, tasks: [TaskItem]) {
        self.name = name
        self.tasks = tasks
    }
    
    var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        let doneCount = tasks.filter { $0.isDone }.count
        return Double(doneCount) / Double(tasks.count)
    }
}
