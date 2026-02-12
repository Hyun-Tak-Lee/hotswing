import 'package:flutter/material.dart';
import 'package:hotswing/src/services/activation_service.dart';

/// 활성화 화면
///
/// 사용자가 마스터 비밀번호를 입력하여 앱을 활성화하는 화면
class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final ActivationService _activationService = ActivationService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleActivation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final password = _passwordController.text;
    final success = await _activationService.activateWithPassword(password);

    if (!mounted) return;

    if (success) {
      // 활성화 성공 - 앱 재시작 필요
      // 간단한 방법: 사용자에게 앱 재시작 요청
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('활성화 완료'),
          content: const Text('앱이 성공적으로 활성화되었습니다.\n앱을 재시작해주세요.'),
          actions: [
            TextButton(
              onPressed: () {
                // 앱 종료 (사용자가 수동으로 재시작)
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      // 활성화 실패
      setState(() {
        _isLoading = false;
        _errorMessage = '비밀번호가 올바르지 않습니다.';
        _passwordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 로고 또는 타이틀
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                const Text(
                  '앱 활성화',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  '활성화 비밀번호를 입력하세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 48),

                // 비밀번호 입력 필드
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    hintText: '활성화 비밀번호 입력',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.vpn_key),
                    errorText: _errorMessage,
                  ),
                  onSubmitted: (_) => _handleActivation(),
                ),
                const SizedBox(height: 24),

                // 활성화 버튼
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleActivation,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '활성화',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
