import SwiftUI
import SwiftData

@Model
class TaskItem {
    var title: String
    var tag: String
    var isDone: Bool
    var doneDate: Date?
    
    init(title: String, tag: String, isDone: Bool, doneDate: Date? = nil) {
        self.title = title
        self.tag = tag
        self.isDone = isDone
        self.doneDate = doneDate
    }
}
