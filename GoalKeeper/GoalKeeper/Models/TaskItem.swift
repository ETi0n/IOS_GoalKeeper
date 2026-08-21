import SwiftUI
import SwiftData

@Model
class TaskItem {
    var title: String
    var tag: String
    var isDone: Bool
    
    init(title: String, tag: String, isDone: Bool) {
        self.title = title
        self.tag = tag
        self.isDone = isDone
    }
}
