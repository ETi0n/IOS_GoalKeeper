# GoalKeeper

[![App Store](https://img.shields.io/badge/App_Store-Download-black?logo=apple)](https://apps.apple.com/kr/app/goalkeeper/id6809496466?l=en-GB)
![Swift](https://img.shields.io/badge/Swift-5.0-orange?logo=swift)
![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2017%2B-blue)
![SwiftData](https://img.shields.io/badge/SwiftData-CloudKit-green)

목표를 마일스톤과 할 일로 쪼개서, 세운 목표가 실제 실행으로 이어지게 돕는 iOS / iPadOS 앱

<br/>
<br/>
<br/>

## 🤷 왜 만들었나

목표를 세워도 실행으로 이어지지 않는 이유는 대부분 "목표가 너무 크고 막연해서"라고 생각했습니다. GoalKeeper는 큰 목표를 마일스톤 → 카테고리 → 할 일 단위까지 쪼개서, 오늘 뭘 해야 할지가 항상 명확하게 보이도록 만든 개인 목표 관리 앱입니다.

<br/>
<br/>

## 📷 서비스 사진
### | iPad
> 메인 서비스 기기로, 넓은 화면으로 마일스톤과 카테고리/할 일 목록을 한 눈에 확인해 관리할 수 있습니다.
<table>
  <tr>
    <td><img width="2752" height="2064" alt="GoalKeeper-iPad-00-Cover" src="https://github.com/user-attachments/assets/dbcf4069-c67d-4f63-a25b-ba0711caa4ef" /></td>
    <td><img width="2752" height="2064" alt="GoalKeeper-iPad-01-Home" src="https://github.com/user-attachments/assets/140b5831-c957-43d0-856a-99ff8ee0c684" /></td>
    <td><img width="2752" height="2064" alt="GoalKeeper-iPad-02-Milestone" src="https://github.com/user-attachments/assets/ded5714e-f8ae-411f-9279-07fb9c786413" /></td>
    <td><img width="2752" height="2064" alt="GoalKeeper-iPad-03-Archive" src="https://github.com/user-attachments/assets/043c4c1c-3e8b-4a22-930d-3419f59eedd6" /></td>
  </tr>
  <tr>
    <td></td>
    <td>목표 화면</td>
    <td>마일스톤 & 카테고리 & 할 일 화면</td>
    <td>보관함 화면</td>
  </tr>
</table>


### | iPhone
> 휴대성을 위해 간단한 확인/체크를 위해 만들어졌으나, 아이패드와 동일한 기능을 제공합니다.
<table>
  <tr>
    <td><img width="1284" height="2778" alt="GoalKeeper-iPhone-00-Cover" src="https://github.com/user-attachments/assets/67190a78-5184-4651-a738-fb59541fbf4d" /></td>
    <td><img width="1284" height="2778" alt="GoalKeeper-iPhone-01-Home" src="https://github.com/user-attachments/assets/3b2b5893-0a2f-451d-855d-ed972300f0ce" /></td>
    <td><img width="1284" height="2778" alt="GoalKeeper-iPhone-02-GoalDetail" src="https://github.com/user-attachments/assets/af9956b9-68a1-4464-9fb3-8fdb05ac69cc" /></td>
    <td><img width="1284" height="2778" alt="GoalKeeper-iPhone-03-Milestone" src="https://github.com/user-attachments/assets/65c15a6a-767c-41fc-a998-59b95f0821c5" /></td>
    <td><img width="1284" height="2778" alt="GoalKeeper-iPhone-04-Archive" src="https://github.com/user-attachments/assets/e7a996f0-0f3d-42ec-8ea2-0a7a7529bd62" /></td>
  </tr>
  <tr>
    <td></td>
    <td>목표 화면</td>
    <td>마일스톤 화면</td>
    <td>카테고리 & 할 일 화면</td>
    <td>보관함 화면</td>
  </tr>
</table>

<br/>
<br/>



## 🧾 핵심 기능

### (1) 목표를 실행 단위까지 쪼개기
`목표 → 마일스톤 → 카테고리 → 할 일`의 4단계 계층 구조. 목표 하나가 여러 마일스톤으로, 마일스톤은 카테고리별 할 일 목록으로 나뉩니다.

### (2) 우선순위와 완료 기준
- **MoSCoW 우선순위** — 모든 할 일에 Must/Should/Could/Won't 부여, Won't은 별도 백로그로 분리
- **완료 조건 체크리스트** — "할 일을 다 체크해도 진짜 완료는 아닐 수 있다"는 문제를 위해, 마일스톤마다 완료 기준을 할 일과 별개로 직접 정의
- **마일스톤 상태 자동 판정** — 대기/진행중/완료/지연을 수동 변경 없이 날짜와 완료 여부로 자동 계산

### (3) 여러 목표를 한눈에
- **오늘의 MUST 패널** — 여러 목표에 흩어진 Must 할 일을 홈 화면 하나에 모음
- **대표 목표 지정** — 지금 가장 중요한 목표 하나를 강조 표시
- **간트 차트** — 마일스톤 일정을 막대그래프로 시각화

### (4) 기록은 남기고 실수는 되돌리고
- **보관함 + 한 줄 후기** — 완료/기간 만료된 목표를 삭제 대신 보관, 후기와 함께 다시 꺼내볼 수 있음
- **Undo 스낵바** — 삭제 후 몇 초 내 되돌리기

### (5) 실사용을 위한 디테일
- iCloud 동기화 (SwiftData + CloudKit)
- 로컬 알림 (매일 리마인더, 마일스톤 D-1 마감 알림, 탭하면 해당 화면으로 이동)
- 아이폰/아이패드 반응형 레이아웃
- VoiceOver 접근성 라벨
- 다크모드 대응

<br/>
<br/>

## 💡 기술적으로 고민한 지점

**CloudKit 동기화를 위한 SwiftData 모델링**
- CloudKit과 함께 쓰려면 관계(Relationship)가 옵셔널 to-many여야 하고 inverse 관계가 명시돼야 합니다. `Goal → Milestone → Category → TaskItem` 4단 계층 전체에 이 제약을 맞추면서, 계산 프로퍼티(progress, dDay 등)로 저장 프로퍼티를 최소화해 동기화 충돌 가능성을 줄였습니다.

**스키마 마이그레이션 우선 계획**
- `SchemaV1` 기준선을 만들어, 이후 모델 변경 시 마이그레이션 경로를 확보. 배포 후 스키마를 바꿔야 할 상황에 대비했습니다.

**"완료"의 정의를 분리**
- 할 일 체크리스트의 완료와 마일스톤의 완료를 같은 것으로 두지 않고, 완료 조건(Criterion)이라는 별도 개념을 도입. 우선순위(MoSCoW)도 문자열 태그로 시작했다가 enum으로 리팩토링해 상태 관리를 명확히 함.

<br/>

## 🍎 앱 출시 과정에서 겪은 것

- **개인정보 처리방침 / 데이터 수집 신고** — CloudKit에 저장되는 사용자 콘텐츠를 "신원과 연결되지 않은 데이터"로 정확히 분류해 신고
- **프랑스 암호화 신고 요건** — HTTPS/CloudKit만 쓰는 앱도 프랑스향 배포 시 별도 암호화 문서 제출이 필요해, 개인 프로젝트 규모에 맞춰 프랑스를 배포 국가에서 제외하는 쪽으로 결정
- **리뷰 이력이 적은 계정에 대한 추가 정보 요청** — 실기기 화면 녹화, 앱 목적/대상, 외부 서비스 목록 등을 제출해 재심사 통과

<br/>
<br/>

## 🛠️ 기술 스택

- SwiftUI
- SwiftData + CloudKit
- UserNotifications (로컬 알림)
- iOS / iPadOS 17.0+

<br/>

## 📂 프로젝트 구조

```
GoalKeeper/
├─ Models/            # Goal, Milestone, Category, TaskItem, Criterion
├─ Views/
│  ├─ Intro/          # 목표 목록, 오늘의 MUST 패널
│  ├─ GoalDetail/      # 목표 상세, 마일스톤 카드, 간트 차트
│  ├─ MilestoneDetail/ # 카테고리·할 일 관리, 완료 조건
│  └─ Archive/         # 보관함
├─ DesignSystem/       # 색상·간격 토큰
└─ Shared/             # 알림, Undo 등 공용 로직
```

<br/>
<br/>

## 👉 다운로드
[App Store에서 보기](https://apps.apple.com/kr/app/goalkeeper/id6809496466?l=en-GB)
