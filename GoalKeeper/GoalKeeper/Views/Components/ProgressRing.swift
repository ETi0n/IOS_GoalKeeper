import SwiftUI

struct ProgressRing: View {
    let value: Double
    var size: CGFloat = 26
    var lineWidth: CGFloat = 3
    var tint: Color = .gkGreenBorder
    var showsLabel: Bool = true
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gkHairline, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: min(max(value, 0), 1)) // 기본적으로 3시 방향부터 시계방향으로 그려짐
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(Angle(degrees: -90)) // -90도 돌려, 12시부터 그리기 시작
            
            if showsLabel {
                Text("\(Int(value * 100))")
                    .font(.system(size: size * 0.32, weight: .light))
                    .foregroundStyle(Color.gkInk)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 16) {
        ProgressRing(value: 0)
        ProgressRing(value: 0.4)
        ProgressRing(value: 1, tint: .gkGray)
    }
    .padding()
}
