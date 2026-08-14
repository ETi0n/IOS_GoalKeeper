import Foundation

struct Goal: Identifiable {
    let id = UUID()
    var title: String
    var progress: Double
    var dDay: String
    var period: String
    var nextMilestone: String
    var isPrimary: Bool // 대표 목표 여부
    var milestones: [Milestone] = []
}

extension Goal {
    static let samples: [Goal] = [

        Goal(title: "SwiftUI 앱 베타 출시", progress: 0.38, dDay: "D-87",
             period: "7월 10일 – 11월 7일", nextMilestone: "베타 테스트 준비", isPrimary: true,
             milestones: [
                Milestone(title: "화면 설계 확정", status: "완료", progress: 1.0, due: "8월 9일 마감",
                          categories: [
                             Category(name: "와이어프레임", tasks: [
                                TaskItem(title: "홈 화면 와이어프레임", tag: "Must", isDone: true)
                             ])
                          ]),
                Milestone(title: "베타 테스트 준비", status: "진행중", progress: 0.14, due: "9월 8일 마감",
                          categories: [
                             Category(name: "테스터 모집", tasks: [
                                TaskItem(title: "지인 5명에게 참여 요청",     tag: "Must",   isDone: true),
                                TaskItem(title: "커뮤니티 모집 글 작성",     tag: "Must",   isDone: false),
                                TaskItem(title: "TestFlight 초대 링크 정리", tag: "Should", isDone: false),
                                TaskItem(title: "참여 안내 메일 문구",        tag: "Could",  isDone: false)
                             ]),
                             Category(name: "피드백 수집", tasks: [
                                TaskItem(title: "피드백 설문 문항 만들기", tag: "Must",   isDone: false),
                                TaskItem(title: "응답 정리 시트 만들기",   tag: "Should", isDone: false)
                             ]),
                             Category(name: "버그 수정", tasks: [
                                TaskItem(title: "목록 스크롤 끊김 수정", tag: "Must", isDone: false)
                             ])
                          ]),
                Milestone(title: "앱스토어 심사 제출", status: "대기", progress: 0.0, due: "11월 7일 마감",
                          categories: [
                             Category(name: "스토어 자료", tasks: [
                                TaskItem(title: "스크린샷 6장 준비", tag: "Must", isDone: false)
                             ])
                          ])
             ]),

        Goal(title: "정보처리기사 필기 합격", progress: 0.50, dDay: "D-41",
             period: "6월 30일 – 9월 22일", nextMilestone: "3~5과목 완독", isPrimary: false,
             milestones: [
                Milestone(title: "1~2과목 완독", status: "완료", progress: 1.0, due: "7월 28일 마감",
                          categories: [
                             Category(name: "요약 노트", tasks: [
                                TaskItem(title: "1과목 요약 정리", tag: "Must", isDone: true)
                             ])
                          ]),
                Milestone(title: "3~5과목 완독", status: "진행중", progress: 0.0, due: "8월 25일 마감",
                          categories: [
                             Category(name: "기출 풀이", tasks: [
                                TaskItem(title: "기출 2회분 타이머 풀이", tag: "Must",   isDone: false),
                                TaskItem(title: "오답 노트 20문항 정리", tag: "Should", isDone: false)
                             ])
                          ])
             ]),

        Goal(title: "10km 42분 안에 뛰기", progress: 0.0, dDay: "D-119",
             period: "7월 12일 – 12월 9일", nextMilestone: "주 3회 습관 만들기", isPrimary: false,
             milestones: [
                Milestone(title: "주 3회 습관 만들기", status: "진행중", progress: 0.0, due: "8월 26일 마감",
                          categories: [
                             Category(name: "주간 러닝", tasks: [
                                TaskItem(title: "주 3회 5km", tag: "Must", isDone: false)
                             ])
                          ])
             ])
    ]
}
