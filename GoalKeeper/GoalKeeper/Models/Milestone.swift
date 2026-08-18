import SwiftUI
import SwiftData

@Model
class Milestone {
    var title: String
    var progress: Double
    var scheduleStart: Date
    var dueDate: Date

    @Relationship(deleteRule: .cascade)
    var categories: [Category] = []

    init(title: String, progress: Double, scheduleStart: Date, dueDate: Date,
         categories: [Category] = []) {
        self.title = title
        self.progress = progress
        self.scheduleStart = scheduleStart
        self.dueDate = dueDate
        self.categories = categories
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
