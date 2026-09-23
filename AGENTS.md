## Code Style

- Constant Constructor: 불변 인스턴스와 UI 노드에는 항상 `const` 적용 (`prefer_const_constructors`).
- Widget Decomposition: `_build...()` 같은 내부 helper 함수로 UI를 쪼개지 말고, 1클래스 1위젯 원칙에 따라 별도 `StatelessWidget`/`StatefulWidget` 클래스로 분리하여 독립된 rebuild 범위 및 `const` 캐싱 보장.
- List Rendering: 정적 목록을 제외한 모든 가변/대량 데이터 UI는 `ListView(children: ...)` 대신 반드시 `ListView.builder` 사용 (on-demand rendering).
- Resource Cleanup: `Controller`, `Timer`, `StreamSubscription` 등 모든 런타임 리소스는 State 생명주기의 `dispose()`에서 명시적 해제.
- Context Safety: `await` 등 비동기 작업 완료 후 `BuildContext` 참조 시 반드시 `mounted` 상태 검증 선행 (`use_build_context_synchronously`).
