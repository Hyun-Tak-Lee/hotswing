## Code Style

- Widget Decomposition: `_build...()` 같은 내부 helper 함수로 UI를 쪼개지 말고, 1클래스 1위젯 원칙에 따라 별도 `StatelessWidget`/`StatefulWidget` 클래스로 분리하여 독립된 rebuild 범위 및 `const` 캐싱 보장.
- List Rendering: 정적 목록을 제외한 모든 가변/대량 데이터 UI는 `ListView(children: ...)` 대신 반드시 `ListView.builder` 사용 (on-demand rendering).
- Resource Cleanup: `Controller`, `Timer`, `StreamSubscription` 등 모든 런타임 리소스는 State 생명주기의 `dispose()`에서 명시적 해제.
- Provider Access: UI 렌더링 구독 시 `context.watch<T>()`, 이벤트 핸들러 및 콜백 내 메서드 호출 시에는 반드시 `context.read<T>()` 사용 (`Provider.of` 지양).
- Helper Placement: private helper 메서드나 함수(`_...`)는 클래스 또는 파일의 최하단에 배치하여 public 인터페이스 및 핵심 로직의 가독성을 최우선 확보.
- Constants Grouping: 글로벌 상수나 `k` 접두사 대신 `abstract final class` 네임스페이스로 그룹화하여 정의 (`CourtConstants.capacity`).
- Function Parameters: 3개 이상의 인자를 받는 함수/메서드는 단순 positional 인자 나열이나 불필요한 별도 Parameter Object(Data Class) 생성 대신 Dart 내장 `Named Parameters`(`{required ...}`) 우선 적용.
