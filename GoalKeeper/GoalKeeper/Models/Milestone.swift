import Foundation

struct Milestone: Identifiable {
    let id = UUID()
    var title: String
    var status: String
    var progress: Double
    var due: String
    var categories: [Category] = []
}
