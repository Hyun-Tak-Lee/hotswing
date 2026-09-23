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

### Keystore

key 파일을 아래 경로에 저장하세요.

```
C:\Users\12gus\hotswing_key\hotswing.keystore
```

### APK 빌드

```bash
flutter build apk --release
```

산출물:

```
/build/app/outputs/flutter-apk/app-release.apk
```

### App Bundle 빌드 (Play Store)

```bash
flutter build appbundle --release
```

산출물:

```
/build/app/outputs/bundle/release/app-release.aab
```

---

## Realm migration

```bash
dart run build_runner clean
```

---

## 성능 프로파일링 (CPU / 메모리 모니터링)

실제 기기에서 성능 및 CPU/메모리 사용량을 측정할 때 사용합니다.

```bash
flutter run --profile
```

- 실행 후 터미널에 출력되는 **Flutter DevTools** URL을 브라우저에서 열어 CPU Profiler 및 Performance/Memory 탭에서 실시간 리소스 사용량을 모니터링할 수 있습니다.
- DevTools 바로 실행:
  ```bash
  dart devtools
  ```

---

## 구글 플레이스토어 앱 등록 키

구글 플레이스토어에 앱을 배포하려면 디지털 서명이 필요합니다. Play 앱 서명(Play App Signing)을 사용할 때 주로 다루는 키는 아래 두 가지입니다.

### 1. 업로드 키 (Upload Key)

| 항목      | 내용                                                                                   |
| --------- | -------------------------------------------------------------------------------------- |
| 보유 주체 | 앱 개발자                                                                              |
| 기술 형식 | Java Keystore (`.jks` 또는 `.keystore`), 로컬 저장 (RSA 2048비트 이상)                 |
| 용도      | `.aab`를 Play Console에 업로드하기 전 서명. Google이 업로드 주체를 인증하는 데 사용    |
| 관리·보안 | 개발자가 안전하게 보관. 분실·유출 시 Google 고객센터를 통해 새 업로드 키로 재설정 가능 |

### 2. 앱 서명 키 (App Signing Key)

| 항목      | 내용                                                                                                        |
| --------- | ----------------------------------------------------------------------------------------------------------- |
| 보유 주체 | Google Play (Play 앱 서명 사용 시)                                                                          |
| 기술 형식 | 공개 인증서 (`.der` / `.pem`)와 연결, Google KMS로 보호 (RSA 4096비트)                                      |
| 용도      | 사용자 기기에 설치되는 최종 APK에 서명                                                                      |
| 관리·보안 | 과거에는 개발자가 직접 관리(분실 시 업데이트 불가). 현재는 Play 앱 서명 등록 시 Google이 안전하게 보관·관리 |

### 요약

개발자는 **업로드 키**로 앱 번들에 서명한 뒤 콘솔에 업로드하면 됩니다. 이후 사용자 기기에 배포될 앱의 생성·서명은 **앱 서명 키**를 통해 Google Play가 처리합니다.
