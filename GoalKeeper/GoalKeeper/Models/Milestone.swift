import SwiftUI
import SwiftData

@Model
class Milestone {
    var title: String
    var status: String
    var progress: Double
    var due: String
    
    @Relationship(deleteRule: .cascade)
    var categories: [Category] = []
    
    init(title: String, status: String, progress: Double, due: String, categories: [Category]) {
        self.title = title
        self.status = status
        self.progress = progress
        self.due = due
        self.categories = categories
    }
}
