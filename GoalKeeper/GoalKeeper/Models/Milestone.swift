import SwiftUI
import SwiftData

@Model
class Milestone {
    var title: String = ""
    var scheduleStart: Date = Date()
    var dueDate: Date = Date()
    var notificationID: String = UUID().uuidString
    var goal: Goal?

    @Relationship(deleteRule: .cascade)
    var categories: [Category]? = []

    @Relationship(deleteRule: .cascade)
    var criteria: [Criterion]? = []

    init(title: String, scheduleStart: Date, dueDate: Date,
         categories: [Category] = [], criteria: [Criterion] = []) {
        self.title = title
        self.scheduleStart = scheduleStart
        self.dueDate = dueDate
        self.categories = categories
        self.criteria = criteria
    }

    // 완료 조건이 하나라도 있고, 전부 충족됐는지
    var criteriaMet: Bool {
        !(criteria ?? []).isEmpty && (criteria ?? []).allSatisfy { $0.isMet }
    }

    var progress: Double {
        let tasks = (categories ?? []).flatMap { $0.tasks ?? [] }
        guard !tasks.isEmpty else { return 0 }
        let doneCount = tasks.filter { $0.isDone }.count
        return Double(doneCount) / Double(tasks.count)
    }

    var status: String {
        let isPastDue = Date() > dueDate

        // 완료 조건이 하나라도 있으면, 대기/진행중/완료/지연 전부
        // 할 일과 무관하게 완료 조건만으로 판단하되, 기한이 지났는데 못 채웠으면 지연
        if !(criteria ?? []).isEmpty {
            if criteriaMet {
                return "완료"
            } else if isPastDue {
                return "지연"
            } else if (criteria ?? []).contains(where: { $0.isMet }) {
                return "진행중"
            } else {
                return "대기"
            }
        }

        // 완료 조건이 없으면 기존처럼 할 일/기한 기준으로 판단
        let allTasks = (categories ?? []).flatMap { $0.tasks ?? [] }
        let hasCompletedTask = allTasks.contains { $0.isDone }
        let allTasksDone = !allTasks.isEmpty && allTasks.allSatisfy { $0.isDone }
        let isWithinRange = Date() >= scheduleStart && Date() <= dueDate

        if allTasksDone {
            return "완료"
        } else if isPastDue {
            return "지연"
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
    
    var orderedCategories: [Category] {
        (categories ?? []).sorted { $0.createdAt < $1.createdAt }
    }

    var orderedCriteria: [Criterion] {
        (criteria ?? []).sorted { $0.createdAt < $1.createdAt }
    }
}
