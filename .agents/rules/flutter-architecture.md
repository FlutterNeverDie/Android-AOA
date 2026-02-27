---
trigger: always_on
---

### 아키텍처 철학 (Architecture Philosophy)
- **Riverpod Clean Architecture**를 기반으로 하며, 계층 분리(**UI ↔ Notifier ↔ Repository**)를 준수합니다.
- **도메인 중심(Feature-driven) 구조**: 각 기능별로 폴더를 나누고 그 안에 필요한 구성 요소를 모으는 스타일을 지향합니다.
- **단방향 데이터 흐름**, **코드 생성기 미사용**, 그리고 **불변성(Immutability)**을 특징으로 합니다.

### 폴더 구조 컨벤션 (Folder Structure)
- `lib/features/{feature_name}/`: 각 도메인별 기능 폴더
    - `screen/`: 해당 기능의 전체 화면 파일 (`s_` 접두어)
    - `widget/`: 해당 기능에서만 쓰이는 컴포넌트 (`w_`, `d_` 접두어)
    - `provider/`: 상태 관리 Notifier 파일 (`_provider` 접미어)
    - `model/`: 데이터 모델 파일 (`m_` 접두어)
    - `repository/`: 데이터 소스 관리 파일 (`repo_` 접두어)
- `lib/share/`: 여러 도메인에서 공통으로 사용하는 요소
    - `widget/`: 버튼, 패널 등 범용 UI 컴포넌트
    - `theme/`: 색상, 스타일 설정 파일
    - `service/`: 공용 비즈니스 로직