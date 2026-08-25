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
                .foregroundStyle(Color.gkGreen.opacity(0.9))
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(Color.gkInk)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 24).padding(.bottom, 16)
    }
}

#Preview {
    SnackbarView(message: "이 항목을 삭제하시겠습니까?", onUndo: {})
}
