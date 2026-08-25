import SwiftUI
import SwiftData

            // @Observable: 시스템이 미리 준비한 것 대신, 직접 만든 클래스를 SwiftUI가 지켜보게 만드는 매크로
@Observable // 클래스 안의 프로퍼티가 변경되면 그걸 읽고 있는 뷰가 자동으로 다시 그려짐 (예전 @Published보다 간단)
class UndoManager {
    private(set) var message: String?
    private var pendingIDs: Set<PersistentIdentifier> = [] // PersistentIdentifier = PID = 영구식별자
                                                            // id 포함여부(.contains)로만 사용되기 때문에 배열보다 Set이 더 빠름
    private var task: Task<Void, Never>? // Never: 비반환 함수, 인스턴스 생성 불가
    
    // 보류 여부
    func isPending(_ id: PersistentIdentifier) -> Bool {
        pendingIDs.contains(id)
    }
    
    // 삭제 진행
    func scheduleDelete(id: PersistentIdentifier, message: String, action: @escaping () -> Void) {
        pendingIDs.insert(id) // 즉시 화면에서 숨김
        self.message = message // 스낵바 표시
        
        task = Task {
            try? await Task.sleep(for: .seconds(4)) // 삭제 전까지 보류 시간
            if !Task.isCancelled {                  // 그 사이 취소가 안됐다면 삭제 진행
                action()
                pendingIDs.remove(id)
                self.message = nil
            }
        }
    }
    
    // 실행 취소(되돌리기)
    func undo() {
        task?.cancel()
        pendingIDs.removeAll()
        message = nil
    }
}
