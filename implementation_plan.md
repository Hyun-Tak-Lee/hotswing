# 앱 네이티브 강점 활용 잔여 개선 구현 계획

최신 커밋 및 [`AGENTS.md`](file:///c:/Users/12gus/projects/hotswing/AGENTS.md) 코드 스타일 지침을 준수하여 외부 패키지 추가 없이 **Flutter 기본 SDK(`services.dart`, `MethodChannel`)와 Android/iOS OS Native SDK**만으로 잔여 항목을 구현합니다.

> [!NOTE]
> **구현 완료되어 제외된 항목**
> - 1·2페이지(개인전/교류전) 전용 전체 화면 모드 (`CourtFullscreenControlBar`, `MainWrapper` 연동)
> - 코트별 실시간 경과 타이머 (`CourtFinishTimerButton` 연동)

## User Review Required

> [!IMPORTANT]
> **외부 패키지 무의존 (Native SDK 직접 연동)**
> 화면 상시 켜짐(Wakelock)과 생체 인증(Biometrics) 모두 외부 패키지 추가 없이 단일 `MethodChannel('com.matching61.hotswing/device')`을 통해 Android(`MainActivity.kt`) 및 iOS(`AppDelegate.swift`) 기본 SDK로 구현합니다.

---

## Proposed Changes

### 1. OS Native 브릿지 (`MethodChannel`) 구현 (화면 상시 켜짐 & 생체 인증)

#### [NEW] [native_device_service.dart](file:///c:/Users/12gus/projects/hotswing/lib/src/services/system/native_device_service.dart)
- `MethodChannel('com.matching61.hotswing/device')` 정의
- `setKeepScreenOn({required bool enable})`: OS 화면 상시 켜짐 제어
- `authenticateBiometric({required String reason})`: OS 생체/기기 인증 호출 (`Future<bool>`)

#### [MODIFY] [MainActivity.kt](file:///c:/Users/12gus/projects/hotswing/android/app/src/main/kotlin/com/matching61/hotswing/MainActivity.kt)
- `configureFlutterEngine`에서 `MethodChannel` 핸들러 등록:
  - `setKeepScreenOn`: `window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)` / `clearFlags`
  - `authenticateBiometric`: Android 기본 SDK `android.hardware.biometrics.BiometricPrompt` (API 28+) 연동

#### [MODIFY] [AndroidManifest.xml](file:///c:/Users/12gus/projects/hotswing/android/app/src/main/AndroidManifest.xml)
- `<uses-permission android:name="android.permission.USE_BIOMETRIC"/>` 권한 추가

#### [MODIFY] [AppDelegate.swift](file:///c:/Users/12gus/projects/hotswing/ios/Runner/AppDelegate.swift)
- `FlutterMethodChannel` 핸들러 등록:
  - `setKeepScreenOn`: `UIApplication.shared.isIdleTimerDisabled = enable`
  - `authenticateBiometric`: iOS 기본 SDK `LocalAuthentication` (`LAContext().evaluatePolicy`) 연동

#### [MODIFY] [Info.plist](file:///c:/Users/12gus/projects/hotswing/ios/Runner/Info.plist)
- `NSFaceIDUsageDescription` 권한 설명 추가

---

### 2. `OptionsProvider` 기반 화면 상시 켜짐 (Wakelock)

#### [MODIFY] [option.dart](file:///c:/Users/12gus/projects/hotswing/lib/src/models/options/option.dart) & [option.realm.dart](file:///c:/Users/12gus/projects/hotswing/lib/src/models/options/option.realm.dart)
- `_Options` 모델에 `late bool keepScreenOn;` 필드 추가

#### [MODIFY] [realm.dart](file:///c:/Users/12gus/projects/hotswing/lib/src/repository/realms/realm.dart) & [options.dart](file:///c:/Users/12gus/projects/hotswing/lib/src/repository/realms/options.dart)
- `schemaVersion`을 현재 `7`에서 `8`로 증가시키고, 마이그레이션(`oldSchemaVersion < 8`) 및 초기 생성 시 `keepScreenOn = true` 기본값 설정

#### [MODIFY] [options_provider.dart](file:///c:/Users/12gus/projects/hotswing/lib/src/providers/options_provider.dart)
- `bool get keepScreenOn => _options.keepScreenOn;`
- `_loadOptions()` 및 `setKeepScreenOn(bool newValue)`에서 `NativeDeviceService.instance.setKeepScreenOn(enable: ...)` 호출

#### [MODIFY] [settings_screen.dart](file:///c:/Users/12gus/projects/hotswing/lib/src/screens/settings/settings_screen.dart)
- '테마 설정' 섹션 카드 내부에 **'화면 항상 켜기'** `Switch.adaptive` 설정 행 추가

---

### 3. 관리자 생체 인증 연동 & 주요 조작 햅틱 피드백

#### [MODIFY] [manager_auth_overlay.dart](file:///c:/Users/12gus/projects/hotswing/lib/src/common/widgets/dialogs/manager_auth_overlay.dart)
- `_checkInitialState()`에서 `hasPassword == true`(`_AuthMode.verifyManager`)일 때 `NativeDeviceService.instance.authenticateBiometric(reason: '관리자 인증을 진행해주세요')`를 호출하여 성공 시 즉시 `Navigator.of(context).pop(true)` 반환
- 취소/미지원 시 기존 비밀번호 입력 UI를 그대로 유지하며, 입력창 우측(`suffixIcon`)에 지문 재시도 아이콘 버튼 제공

#### [MODIFY] [draggable_player_item.dart](file:///c:/Users/12gus/projects/hotswing/lib/src/common/widgets/draggable/draggable_player_item.dart) & [player_drop_zone.dart](file:///c:/Users/12gus/projects/hotswing/lib/src/common/widgets/draggable/player_drop_zone.dart)
- `LongPressDraggable.onDragStarted`: `HapticFeedback.mediumImpact()` 추가
- `DragTarget.onAcceptWithDetails`: `HapticFeedback.lightImpact()` 추가

---

## Verification Plan

- 사용자 지침에 따라 별도 지시가 있기 전까지 테스트 및 검증 명령을 임의 실행하지 않으며, 계획 승인 및 구현 완료 후 요청 시 검증을 수행합니다.
