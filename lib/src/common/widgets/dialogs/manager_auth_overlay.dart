import 'package:flutter/material.dart';
import 'package:hotswing/src/services/manager_auth_service.dart';

enum _AuthMode {
  verifyManager,
  verifyActivationForInit,
  verifyActivationForReset,
  setNewManagerPassword,
}

/// 특정 화면(예: 선수 관리)에 진입하기 위한 관리자 인증 오버레이 다이얼로그 (공통 위젯)
class ManagerAuthOverlay extends StatefulWidget {
  const ManagerAuthOverlay({super.key});

  @override
  State<ManagerAuthOverlay> createState() => _ManagerAuthOverlayState();
}

class _ManagerAuthOverlayState extends State<ManagerAuthOverlay> {
  final ManagerAuthService _authService = ManagerAuthService();
  final TextEditingController _passwordController = TextEditingController();

  _AuthMode _currentMode = _AuthMode.verifyManager;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    final hasPassword = await _authService.hasManagerPassword();
    setState(() {
      _currentMode = hasPassword
          ? _AuthMode.verifyManager
          : _AuthMode.verifyActivationForInit;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_passwordController.text.isEmpty) return;

    setState(() {
      _errorMessage = null;
    });

    final password = _passwordController.text;

    switch (_currentMode) {
      case _AuthMode.verifyManager:
        final isValid = await _authService.verifyManagerPassword(password);
        if (isValid) {
          if (mounted) Navigator.of(context).pop(true);
        } else {
          setState(() {
            _errorMessage = '비밀번호가 일치하지 않습니다.';
            _passwordController.clear();
          });
        }
        break;

      case _AuthMode.verifyActivationForInit:
      case _AuthMode.verifyActivationForReset:
        final isValid = _authService.verifyActivationPassword(password);
        if (isValid) {
          setState(() {
            _currentMode = _AuthMode.setNewManagerPassword;
            _passwordController.clear();
          });
        } else {
          setState(() {
            _errorMessage = '활성화 비밀번호가 일치하지 않습니다.';
            _passwordController.clear();
          });
        }
        break;

      case _AuthMode.setNewManagerPassword:
        if (password.length < 4) {
          setState(() {
            _errorMessage = '비밀번호는 4자리 이상이어야 합니다.';
          });
          return;
        }
        await _authService.setManagerPassword(password);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('관리자 비밀번호가 설정되었습니다.')));
          Navigator.of(context).pop(true); // 새 비밀번호 설정 완료 시 인증 통과로 처리
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    String title;
    String subtitle;
    String hintText;

    switch (_currentMode) {
      case _AuthMode.verifyManager:
        title = '관리자 인증';
        subtitle = '해당 기능에 접근하려면 관리자 비밀번호를 입력하세요.';
        hintText = '관리자 비밀번호 입력';
        break;
      case _AuthMode.verifyActivationForInit:
        title = '관리자 비밀번호 초기 설정';
        subtitle = '초기 설정을 위해 앱 활성화 비밀번호를 입력하세요.';
        hintText = '활성화 비밀번호 입력';
        break;
      case _AuthMode.verifyActivationForReset:
        title = '관리자 비밀번호 재설정';
        subtitle = '재설정을 위해 앱 활성화 비밀번호를 입력하세요.';
        hintText = '활성화 비밀번호 입력';
        break;
      case _AuthMode.setNewManagerPassword:
        title = '새 관리자 비밀번호 설정';
        subtitle = '사용할 관리자 비밀번호를 입력하세요.';
        hintText = '새 관리자 비밀번호 (4자리 이상)';
        break;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // X (닫기) 버튼
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(false),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),

            Icon(
              Icons.admin_panel_settings,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _passwordController,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                labelText: '비밀번호',
                hintText: hintText,
                errorText: _errorMessage,
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _handleSubmit(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // 비밀번호 재설정 버튼 (인증 모드일 때만 표시)
            if (_currentMode == _AuthMode.verifyManager) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentMode = _AuthMode.verifyActivationForReset;
                    _passwordController.clear();
                    _errorMessage = null;
                  });
                },
                child: const Text(
                  '비밀번호를 잊으셨나요? (재설정)',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],

            // 마스터 비밀번호 확인 중이거나 새 비밀번호 설정 중일 때 '우회 진입' 옵션 제공
            if (_currentMode != _AuthMode.verifyManager) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  if (_currentMode == _AuthMode.setNewManagerPassword) {
                    // 이미 마스터 비밀번호 검증이 완료된 상태
                    Navigator.of(context).pop(true);
                  } else {
                    // 현재 마스터 비밀번호 입력창인 경우, 여기서 바로 검증 후 진입 시도
                    final password = _passwordController.text;
                    if (password.isEmpty) {
                      setState(() => _errorMessage = '활성화 비밀번호를 입력하세요.');
                      return;
                    }
                    if (_authService.verifyActivationPassword(password)) {
                      Navigator.of(context).pop(true);
                    } else {
                      setState(() => _errorMessage = '활성화 비밀번호가 일치하지 않습니다.');
                    }
                  }
                },
                child: Text(
                  _currentMode == _AuthMode.setNewManagerPassword
                      ? '비밀번호 변경 없이 진입하기'
                      : '마스터 비밀번호로 즉시 진입',
                  style: const TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
