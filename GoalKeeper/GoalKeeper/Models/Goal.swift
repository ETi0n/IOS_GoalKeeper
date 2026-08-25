import SwiftUI
import SwiftData

@Model
class Goal {
    var title: String
    var scheduleStart: Date
    var dueDate: Date
    var archivedDate: Date?
    var isPrimary: Bool // 대표 목표 여부
    var isArchived: Bool
    
    @Relationship(deleteRule: .cascade)
    var milestones: [Milestone] = []
    
    init(title: String, scheduleStart: Date, dueDate: Date, archivedDate: Date? = nil,
         isPrimary: Bool = false, isArchived: Bool = false, milestones: [Milestone] = []) {
        self.title = title
        self.scheduleStart = scheduleStart
        self.dueDate = dueDate
        self.archivedDate = archivedDate
        self.isPrimary = isPrimary
        self.isArchived = isArchived
        self.milestones = milestones
    }
    
    var progress: Double {
        let categories = milestones.flatMap { $0.categories }
        let tasks = categories.flatMap { $0.tasks }
        
        guard !tasks.isEmpty else { return 0 }
        let doneCount = tasks.filter { $0.isDone }.count
        return Double(doneCount) / Double(tasks.count)
    }
    
    var dDay: String {
        let today = Calendar.current.startOfDay(for: Date())
        let due = Calendar.current.startOfDay(for: dueDate)
        let days = Calendar.current.dateComponents([.day], from: today, to: due).day ?? 0
        if days == 0 { return "D-Day" }
        return days > 0 ? "D-\(days)" : "D+\(-days)"
    }
    
    var archivedLabel: String {
        guard let archivedDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: archivedDate)
    }
    
    var period: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return "\(formatter.string(from: scheduleStart)) – \(formatter.string(from: dueDate))"
    }
    
    var nextMilestone: String {
        milestones.sorted { $0.dueDate < $1.dueDate }
            .first { $0.status != "완료" }?.title ?? "모두 완료"
    }
}

private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
    DateComponents(calendar: .current, year: year, month: month, day: day).date!
}

extension Goal {
    static var samples: [Goal] {
        [
            Goal(title: "SwiftUI 앱 베타 출시",
                 scheduleStart: date(2026,7,10), dueDate: date(2026,11,7), isPrimary: true,
                 milestones: [
                    Milestone(title: "화면 설계 확정",
                              scheduleStart: date(2026,7,10), dueDate: date(2026,8,9),
                              categories: [
                                 Category(name: "와이어프레임", tasks: [
                                    TaskItem(title: "홈 화면 와이어프레임", tag: .must, isDone: true)
                                 ])
                              ]),
                    Milestone(title: "베타 테스트 준비",
                              scheduleStart: date(2026,8,9), dueDate: date(2026,9,8),
                              categories: [
                                 Category(name: "테스터 모집", tasks: [
                                    TaskItem(title: "지인 5명에게 참여 요청", tag: .must, isDone: true),
                                    TaskItem(title: "커뮤니티 모집 글 작성", tag: .must, isDone: false),
                                    TaskItem(title: "TestFlight 초대 링크 정리", tag: .should, isDone: false),
                                    TaskItem(title: "참여 안내 메일 문구", tag: .could, isDone: false)
                                 ]),
                                 Category(name: "피드백 수집", tasks: [
                                    TaskItem(title: "피드백 설문 문항 만들기", tag: .must, isDone: false)
                                 ]),
                                 Category(name: "버그 수정", tasks: [
                                    TaskItem(title: "목록 스크롤 끊김 수정", tag: .must, isDone: false)
                                 ])
                              ]),
                    Milestone(title: "앱스토어 심사 제출",
                              scheduleStart: date(2026,9,8), dueDate: date(2026,11,7),
                              categories: [
                                 Category(name: "스토어 자료", tasks: [
                                    TaskItem(title: "스크린샷 6장 준비", tag: .must, isDone: false)
                                 ])
                              ])
                 ]),

            Goal(title: "정보처리기사 필기 합격",
                 scheduleStart: date(2026,6,30), dueDate: date(2026,9,22), isPrimary: false,
                 milestones: [
                    Milestone(title: "1~2과목 완독",
                              scheduleStart: date(2026,6,30), dueDate: date(2026,7,28),
                              categories: [
                                 Category(name: "요약 노트", tasks: [
                                    TaskItem(title: "1과목 요약 정리", tag: .must, isDone: true)
                                 ])
                              ]),
                    Milestone(title: "3~5과목 완독",
                              scheduleStart: date(2026,7,28), dueDate: date(2026,8,25),
                              categories: [
                                 Category(name: "기출 풀이", tasks: [
                                    TaskItem(title: "기출 2회분 타이머 풀이", tag: .must, isDone: false),
                                    TaskItem(title: "오답 노트 20문항 정리", tag: .should, isDone: false)
                                 ])
                              ])
                 ]),

            Goal(title: "10km 42분 안에 뛰기",
                 scheduleStart: date(2026,7,12), dueDate: date(2026,12,9), isPrimary: false,
                 milestones: [
                    Milestone(title: "주 3회 습관 만들기",
                              scheduleStart: date(2026,7,12), dueDate: date(2026,8,26),
                              categories: [
                                 Category(name: "주간 러닝", tasks: [
                                    TaskItem(title: "주 3회 5km", tag: .must, isDone: false)
                                 ])
                              ])
                 ]),

            // == 보관된 목표 샘플 ==
            Goal(title: "블로그 리뉴얼",
                 scheduleStart: date(2026,4,1), dueDate: date(2026,6,20), archivedDate: date(2026,6,2), isPrimary: false,
                 isArchived: true,
                 milestones: [
                    Milestone(title: "디자인 시스템 정리",
                              scheduleStart: date(2026,4,1), dueDate: date(2026,4,30),
                              categories: [
                                 Category(name: "컬러·타이포", tasks: [
                                    TaskItem(title: "컬러 팔레트 정리", tag: .must, isDone: true)
                                 ])
                              ]),
                    Milestone(title: "글 10편 발행",
                              scheduleStart: date(2026,4,30), dueDate: date(2026,6,10),
                              categories: [
                                 Category(name: "발행", tasks: [
                                    TaskItem(title: "10편 발행 완료", tag: .must, isDone: true)
                                 ])
                              ]),
                    Milestone(title: "배포 및 마무리",
                              scheduleStart: date(2026,6,10), dueDate: date(2026,6,20),
                              categories: [
                                 Category(name: "배포", tasks: [
                                    TaskItem(title: "도메인 연결", tag: .must, isDone: true)
                                 ])
                              ])
                 ]),

            Goal(title: "독서 12권 읽기",
                 scheduleStart: date(2026,1,1), dueDate: date(2026,2,28), archivedDate: date(2026,3,2), isPrimary: false,
                 isArchived: true,
                 milestones: [
                    Milestone(title: "상반기 6권",
                              scheduleStart: date(2026,1,1), dueDate: date(2026,1,31),
                              categories: [
                                 Category(name: "독서 기록", tasks: [
                                    TaskItem(title: "6권 완독", tag: .must, isDone: true)
                                 ])
                              ]),
                    Milestone(title: "하반기 6권",
                              scheduleStart: date(2026,1,31), dueDate: date(2026,2,28),
                              categories: [
                                 Category(name: "독서 기록", tasks: [
                                    TaskItem(title: "6권 완독", tag: .must, isDone: true)
                                 ])
                              ])
                 ])
        ]
    }
}
