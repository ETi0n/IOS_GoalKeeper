import Foundation

struct TaskItem: Identifiable {
    let id = UUID()
    let title: String
    let tag: String
    let isDone: Bool
}
