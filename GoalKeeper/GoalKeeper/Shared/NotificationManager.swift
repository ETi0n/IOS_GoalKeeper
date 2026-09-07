import SwiftUI
import UserNotifications

@Observable
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    // 알림을 탭해서 열어야 할 마일스톤의 notificationID. 화면(IntroView)이 이 값을 지켜보다가 바뀌면 이동시킴
    var pendingMilestoneNotificationID: String?

    // MARK: 델리게이트 - 알림에 무슨 일이 생기면 여기로 알려달라고 등록
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound]) // 앱이 포그라운드여도 배너를 띄워줌
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        if identifier.hasPrefix("milestone-") {
            pendingMilestoneNotificationID = String(identifier.dropFirst("milestone-".count))
        }
        completionHandler()
    }

    // MARK: 권한 요청 - 앱이 처음 실행되었을 때 한 번 요청
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
            if let error {
                print("알림 권한 요청 실패", error)
            }
        }
    }
    
    // MARK: 매일 정해진 시각에 반복 알림 등록
    func scheduleDailyReminder(hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "GoalKeeper"
        content.body = "오늘도 목표를 위한 한 걸음, 나아가셨나요?"
        content.sound = .default
        
        var dateComponents = DateComponents() // year,month,day를 비울 시 시각마다(즉 매일) 알림
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger) // 고유 이름 적용
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("알림 등록 실패:", error)
            }
        }
    }
    
    // MARK: 마일스톤 마감 전날 리마인드
    func scheduleMilestoneReminder(id: String, title: String, dueDate: Date) {
        guard let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: dueDate) else { return } // 특정 날짜에서 덧셈/뺄셈 (D-1 계산)
        guard reminderDate > Date() else { return } // 이미 지난 시간
        
        let content = UNMutableNotificationContent()
        content.title = "내일 마감이예요"
        content.body = "\(title) 마감이 하루 남았어요"
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate) // 날짜를 컴포넌트화
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "milestone-\(id)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: 마일스톤 알림 취소
    func cancelMilestoneReminder(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["milestone-\(id)"]) // "아직 울리지 않은" 알림 중 취소
    }
}
