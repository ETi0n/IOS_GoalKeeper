import SwiftUI

enum Metrics {
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
    }
    
    enum Radius {
        static let chip: CGFloat = 6      // 작은 배지
        static let control: CGFloat = 8   // 버튼, 입력창
        static let card: CGFloat = 10     // 행(row) 카드
        static let panel: CGFloat = 14    // 큰 카드
    }
    
    enum Stroke {
        static let hairline: CGFloat = 0.5     // 카드/행 테두리 (제일 많이 씀)
        static let outline: CGFloat = 1        // 상태 배지 같은 pill 테두리
        static let dashed: CGFloat = 1.5       // "+ 추가" 점선 버튼
    }
    
    enum Layout {
        static let categoryColumnWidth: CGFloat = 280
        static let taskListMinWidth: CGFloat = 500
        
        static var milestoneDetailMinWidth: CGFloat {
            categoryColumnWidth + taskListMinWidth
        }
    }
}
