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
}
