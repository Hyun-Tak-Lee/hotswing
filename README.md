# HotSwing

배드민턴 모임 정모 시 실력·성별 등으로 게임을 자동 매칭하고, 플레이 기록을 관리하는 Flutter 앱입니다.

---

## 환경 설정

프로젝트 루트에 `.env` 파일을 생성하고 아래 내용을 추가하세요.

```env
MASTER_PASSWORD=''
SECRET_KEY=''
```

---

## Release 배포

### 서명 설정 (Keystore)

Android 릴리즈 빌드를 위해 `android/key.properties` 파일을 생성하고 서명 정보를 입력합니다. (`key.properties`와 키 파일은 gitignore 대상입니다.)

```properties
storePassword=<저장소 비밀번호>
keyPassword=<키 비밀번호>
keyAlias=<키 별칭>
storeFile=<키 파일 경로>
```

- `storeFile`은 절대 경로 또는 프로젝트 기준 상대 경로를 지원합니다. (경로 구분자는 `/` 권장)
- Play Store 업로드 키 관련 설명은 [docs/playstore_signing.md](docs/playstore_signing.md)를 참고하세요.

### APK 빌드

```bash
flutter build apk --release
```

산출물: `build/app/outputs/flutter-apk/app-release.apk`

### App Bundle 빌드 (Play Store)

```bash
flutter build appbundle --release
```

산출물: `build/app/outputs/bundle/release/app-release.aab`

---

## Realm migration

```bash
dart run build_runner clean
```

---

## 성능 프로파일링

실제 기기에서 성능 및 CPU/메모리 사용량을 측정할 때 사용합니다.

```bash
flutter run --profile
```

실행 후 출력되는 Flutter DevTools URL을 브라우저에서 열거나, 아래 명령어로 별도 실행할 수 있습니다.

```bash
dart devtools
```
