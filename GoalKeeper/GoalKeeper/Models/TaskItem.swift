import SwiftUI
import SwiftData

@Model
class TaskItem {
    var title: String
    var tag: Moscow
    var isDone: Bool
    var doneDate: Date?
    
    init(title: String, tag: Moscow, isDone: Bool, doneDate: Date? = nil) {
        self.title = title
        self.tag = tag
        self.isDone = isDone
        self.doneDate = doneDate
    }
}

// String raw value
// VaseIterable: .allCases로 전체 한 번에 순회 가능
// Indetifiable: ForEach 사용 가능
// Codable: SwiftData에서 enum 저장시 필요
enum Moscow: String, CaseIterable, Identifiable, Codable {
    case must = "Must"
    case should = "Should"
    case could = "Could"
    case wont = "Won't"
    
    var id: String { rawValue }
}
