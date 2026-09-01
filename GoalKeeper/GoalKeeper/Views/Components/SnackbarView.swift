import SwiftUI

struct SnackbarView: View {
    let message: String
    let onUndo: () -> Void
    
    var body: some View {
        HStack {
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white)
            
            Spacer()
            
            Button("실행 취소", action: onUndo)
                .font(.subheadline).fontWeight(.medium)
                .foregroundStyle(Color.gkGreen)
        }
        .padding(.horizontal, Metrics.Spacing.lg).padding(.vertical, Metrics.Spacing.md)
        .background(Color.gkInk)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.control))
        .padding(.horizontal, Metrics.Spacing.xxl).padding(.bottom, Metrics.Spacing.lg)
    }
}

#Preview {
    SnackbarView(message: "이 항목을 삭제하시겠습니까?", onUndo: {})
}
