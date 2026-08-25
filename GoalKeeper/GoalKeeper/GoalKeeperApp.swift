import SwiftUI
import SwiftData

@main
struct GoalKeeperStudyApp: App {
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
        }
        .modelContainer(for: Goal.self)
    }
}
