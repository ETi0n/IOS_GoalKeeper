import SwiftUI

extension Color {
    static let gkGreen   = Color(red: 0.17, green: 0.48, blue: 0.29)
    static let gkGreenBG = Color(red: 0.92, green: 0.96, blue: 0.93)
    static let gkGreenBorder = Color.gkGreen.opacity(0.6)
    static let gkSurface = Color(red: 0.96, green: 0.96, blue: 0.95)
    static let gkInk     = Color(red: 0.10, green: 0.10, blue: 0.10)
    static let gkGray    = Color(red: 0.56, green: 0.56, blue: 0.53)
    static let gkRed     = Color(red: 0.77, green: 0.24, blue: 0.18)
    static let gkRedBG   = Color(red: 0.97, green: 0.90, blue: 0.87)

    static let gkCard        = Color.white               // 카드 배경
    static let gkHairline    = Color.black.opacity(0.1)  // 카드 테두리
    static let gkFaintFill   = Color.black.opacity(0.05) // dDay 배지 등 은은한 배경
    static let gkMutedIcon   = Color.gray.opacity(0.4)   // 비활성 아이콘(연필, 휴지통, 별 등)
}
