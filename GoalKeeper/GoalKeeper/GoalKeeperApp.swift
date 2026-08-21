import SwiftUI
import SwiftData

@main
struct GoalKeeperApp: App {

    var body: some Scene {
        WindowGroup {
            IntroView()
        }
        .modelContainer(for: Goal.self) // 저장소 연결 (관계로 엮인 나머지도 자동 포함)
    }
}
