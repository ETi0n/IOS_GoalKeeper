import SwiftUI
import SwiftData
import UserNotifications

@main
struct GoalKeeperStudyApp: App {
    @State private var undoManager = UndoManager()
    
    let container: ModelContainer = {
        let configuration = ModelConfiguration(cloudKitDatabase: .automatic)
        return try! ModelContainer(for: Goal.self, configurations: configuration) // 실패시 그냥 크러시 내라..
    }()

    init() {
        // 앱이 알림 탭 이벤트를 받을 수 있도록, 화면이 뜨기 전(가능한 한 이른 시점)에 델리게이트 등록
        UNUserNotificationCenter.current().delegate = NotificationManager.shared
    }

    var body: some Scene {
        WindowGroup {
            IntroView()
                .environment(undoManager) // IntroView() 내부에 등록
                .environment(NotificationManager.shared)
                .preferredColorScheme(.light)
                .overlay(alignment: .bottom) { // View 위에 떠 있도록
                    if let message = undoManager.message {
                        SnackbarView(message: message) {
                            undoManager.undo()
                        }
                    }
                }
                .onAppear {
                    NotificationManager.shared.requestPermission()
                    NotificationManager.shared.scheduleDailyReminder(hour: 9, minute: 0)
                }
        }
        .modelContainer(container)
    }
}
