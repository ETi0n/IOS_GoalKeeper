# ✅ GoalKeeper

> 목표를 마일스톤과 할 일로 쪼개서 끝까지 완주하도록 돕는 iOS / iPadOS 목표 관리 앱입니다.

`목표(Goal) → 마일스톤(Milestone) → 카테고리(Category) → 할 일(Task)`의 4단계 계층으로 목표를 관리합니다. 목표만 세우고 실행은 흐지부지되는 문제를 막기 위해, 큰 목표를 실제로 오늘 할 수 있는 단위까지 쪼개는 데 초점을 맞췄습니다.

<br/>

## 1. 이미지
### 📍 iPhone
<table>
  <tr>
    <td><img width="1284" height="2778" alt="GoalKeeper-iPhone-00-Cover" src="https://github.com/user-attachments/assets/67190a78-5184-4651-a738-fb59541fbf4d" /></td>
    <td><img width="1284" height="2778" alt="GoalKeeper-iPhone-04-Archive" src="https://github.com/user-attachments/assets/e7a996f0-0f3d-42ec-8ea2-0a7a7529bd62" /></td>
    <td><img width="1284" height="2778" alt="GoalKeeper-iPhone-03-Milestone" src="https://github.com/user-attachments/assets/65c15a6a-767c-41fc-a998-59b95f0821c5" /></td>
    <td><img width="1284" height="2778" alt="GoalKeeper-iPhone-02-GoalDetail" src="https://github.com/user-attachments/assets/af9956b9-68a1-4464-9fb3-8fdb05ac69cc" /></td>
    <td><img width="1284" height="2778" alt="GoalKeeper-iPhone-01-Home" src="https://github.com/user-attachments/assets/3b2b5893-0a2f-451d-855d-ed972300f0ce" /></td>
    </tr>
</table>

<br/>

### 📍 iPad ⭐️
<table>
  <tr>
    <td><img width="2752" height="2064" alt="GoalKeeper-iPad-00-Cover" src="https://github.com/user-attachments/assets/dbcf4069-c67d-4f63-a25b-ba0711caa4ef" /></td>
    <td><img width="2752" height="2064" alt="GoalKeeper-iPad-01-Home" src="https://github.com/user-attachments/assets/140b5831-c957-43d0-856a-99ff8ee0c684" /></td>
    <td><img width="2752" height="2064" alt="GoalKeeper-iPad-02-Milestone" src="https://github.com/user-attachments/assets/ded5714e-f8ae-411f-9279-07fb9c786413" /></td>
    <td><img width="2752" height="2064" alt="GoalKeeper-iPad-03-Archive" src="https://github.com/user-attachments/assets/043c4c1c-3e8b-4a22-930d-3419f59eedd6" /></td>
    </tr>
</table>

<br/>
<br/>

## 2. 주요 기능

- **오늘의 MUST** — 여러 목표에 흩어진 Must 할 일을 한 화면에 모아서 보여줍니다.
- **MoSCoW 우선순위** — 모든 할 일에 Must / Should / Could / Won't 우선순위를 부여합니다.
- **완료 조건 체크리스트** — 마일스톤마다 "진짜 끝"의 기준을 할 일과 별개로 직접 정의합니다.
- **마일스톤 상태 자동 판정** — 대기 / 진행중 / 완료 / 지연 상태를 자동으로 계산합니다.
- **간트 차트** — 마일스톤 일정을 막대그래프로 시각화합니다.
- **대표 목표 지정** — 여러 목표 중 지금 가장 중요한 하나를 강조 표시합니다.
- **목표 보관함 · 한 줄 후기** — 끝난 목표를 지우지 않고 후기와 함께 보관하고, 다시 꺼낼 수 있습니다.
- **실행 취소(Undo)** — 삭제 후 몇 초간 스낵바로 되살릴 수 있습니다.
- **iCloud 동기화** — SwiftData + CloudKit으로 기기 간 목표 데이터를 자동 동기화합니다.
- **로컬 알림** — 매일 리마인더와 마일스톤 마감 D-1 알림을 예약하고, 탭하면 해당 화면으로 이동합니다.
- **반응형 레이아웃** — 아이폰과 아이패드에서 화면 구성이 다르게 최적화되어 있습니다.
- **접근성** — 아이콘 전용 버튼에 VoiceOver용 설명을 제공합니다.

<br/>
<br/>

## 3. 기술 스택

- SwiftUI
- SwiftData + CloudKit
- UserNotifications (로컬 알림)
- iOS / iPadOS 17.0+

<br/>
<br/>

## 4. 프로젝트 구조

```
GoalKeeper/
├─ Models/            # Goal, Milestone, Category, TaskItem, Criterion 등 SwiftData 모델
├─ Views/
│  ├─ Intro/           # 목표 목록, 오늘의 MUST 패널
│  ├─ GoalDetail/      # 목표 상세, 마일스톤 카드, 간트 차트
│  ├─ MilestoneDetail/ # 카테고리·할 일 관리, 완료 조건
│  └─ Archive/         # 보관함
├─ DesignSystem/       # 색상·간격 등 디자인 토큰
└─ Shared/             # 알림, Undo 등 공용 로직
```

<br/>
<br/>

## 5. 요구 사항

- Xcode 26 이상
- iOS / iPadOS 17.0 이상
