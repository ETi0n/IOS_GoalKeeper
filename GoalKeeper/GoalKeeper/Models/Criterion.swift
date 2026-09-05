import SwiftUI
import SwiftData

@Model
class Criterion { // 조건
    var text: String
    var isMet: Bool // 충족 여부
    var createdAt: Date

    init(text: String, isMet: Bool = false, createdAt: Date = Date()) {
        self.text = text
        self.isMet = isMet
        self.createdAt = createdAt
    }
}
