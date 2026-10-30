# HotSwing

배드민턴 모임 정모 시 실력·성별 등으로 게임을 자동 매칭하고, 플레이 기록을 관리하는 Flutter 앱입니다.

---

## 환경 설정

프로젝트 루트에 `.env` 파일을 생성하고 마스터(활성화) 비밀번호의 **salt와 해시**를 추가하세요.
`.env`는 APK에 포함되어 누구나 열어볼 수 있으므로 비밀번호 원문은 절대 넣지 않습니다.

```env
MASTER_PASSWORD_SALT=<16진수 salt>
MASTER_PASSWORD_HASH=<16진수 해시>
```

### 해시 생성 방법

아래 명령으로 두 값을 생성한 뒤, 출력된 두 줄을 그대로 `.env`에 붙여넣고 빌드합니다.

```bash
dart run tool/hash_password.dart "<마스터 비밀번호>"
```

출력 예시:

```env
MASTER_PASSWORD_SALT=3f9a0c...
MASTER_PASSWORD_HASH=8b21e7...
```

- 알고리즘: **PBKDF2-HMAC-SHA256**, 반복 300,000회, 출력 32바이트(16진수 64자)
  - 반복 횟수는 `CryptoUtils.pbkdf2Iterations`와 반드시 일치해야 합니다. 변경 시 해시를 다시 생성하세요.
- salt: 16바이트 난수(16진수 32자). 해시 계산 시 16진수를 바이트로 디코딩하여 사용
- 비밀번호: 앞뒤 공백을 제거(trim)한 뒤 UTF-8로 인코딩
- 실행할 때마다 salt가 새로 생성되므로 결과값이 매번 다르며, 어느 쌍을 사용해도 동일하게 동작합니다.
- 해시를 거꾸로 추측하기 어렵도록 **12자 이상**의 비밀번호를 권장합니다.
- 프로젝트 루트에서 실행하며, `flutter pub get`이 한 번이라도 실행된 상태여야 합니다. (`dart`는 Flutter SDK에 포함되어 있어 별도 설치나 가상 환경이 필요 없습니다.)

> 마스터 비밀번호(또는 salt/해시)를 변경하면 기존 기기는 다음 실행 시 재활성화가 필요합니다. 선수·세션 데이터는 유지됩니다.

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
