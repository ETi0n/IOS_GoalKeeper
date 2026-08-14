import Foundation

struct Category: Identifiable {
    let id = UUID()
    var name: String
    var tasks: [TaskItem] = []
}
