import SwiftUI
import SwiftData

@Model
class Milestone {
    var title: String
    var scheduleStart: Date
    var dueDate: Date

    @Relationship(deleteRule: .cascade)
    var categories: [Category] = []

    init(title: String, scheduleStart: Date, dueDate: Date,
         categories: [Category] = []) {
        self.title = title
        self.scheduleStart = scheduleStart
        self.dueDate = dueDate
        self.categories = categories
    }
    
    var progress: Double {
        let tasks = categories.flatMap { $0.tasks }
        
        guard !tasks.isEmpty else { return 0 }
        let doneCount = tasks.filter { $0.isDone }.count
        return Double(doneCount) / Double(tasks.count)
    }

    var status: String {
        let today = Date()
        let allTasks = categories.flatMap { $0.tasks }
        let hasCompletedTask = allTasks.contains { $0.isDone }
        let allTasksDone = !allTasks.isEmpty && allTasks.allSatisfy { $0.isDone }
        let isPastDue = today > dueDate
        let isWithinRange = today >= scheduleStart && today <= dueDate

        if allTasksDone || isPastDue {
            return "완료"
        } else if isWithinRange || hasCompletedTask {
            return "진행중"
        } else {
            return "대기"
        }
    }

    var due: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: dueDate) + " 마감"
    }
}
