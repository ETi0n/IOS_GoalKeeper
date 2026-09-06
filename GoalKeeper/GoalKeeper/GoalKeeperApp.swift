import SwiftUI
import SwiftData

@main
struct GoalKeeperStudyApp: App {
    let notificationManager = NotificationManager()
    @State private var undoManager = UndoManager()

    var body: some Scene {
        WindowGroup {
            IntroView()
                .environment(undoManager) // IntroView() 내부에 등록
                .overlay(alignment: .bottom) { // View 위에 떠 있도록
                    if let message = undoManager.message {
                        SnackbarView(message: message) {
                            undoManager.undo()
                        }
                    }
                }
                .onAppear {
                    notificationManager.requestPermission()
                    notificationManager.scheduleDailyReminder(hour: 22, minute: 00) // 오후 10시
                }
        }
        .modelContainer(for: Goal.self)
    }
}
