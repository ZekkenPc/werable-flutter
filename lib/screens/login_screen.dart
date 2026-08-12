import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/numeric_keypad.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  const LoginScreen({super.key, required this.onSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _pin = '';
  String? _error;
  bool _submitting = false;

  Future<void> _submit() async {
    if (_pin.isEmpty || _submitting) return;
    setState(() => _submitting = true);

    final result = await AuthService.instance.verifyPin(_pin);

    if (result.ok) {
      widget.onSuccess();
      return;
    }

    setState(() {
      _submitting = false;
      _pin = '';
      if (result.reason == 'WRONG_PIN') {
        _error = 'PIN incorrecto. Intentos: ${result.attemptsLeft}';
      } else if (result.reason == 'LOCKED' || result.reason == 'LOCKED_NOW') {
        _error = 'Bloqueado. Espera ${result.secondsLeft}s';
      } else {
        _error = 'PIN no configurado';
      }
    });
  }

  void _onChanged(String value) {
    setState(() {
      _pin = value;
      _error = null;
    });
    if (value.length == 6) {
      _submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ingresa tu PIN',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                NumericKeypad(value: _pin, onChanged: _onChanged, keySize: 40),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (_pin.length >= 4 && _pin.length < 6)
                  SizedBox(
                    height: 28,
                    child: TextButton(
                      onPressed: _submit,
                      child: const Text(
                        'Entrar',
                        style: TextStyle(fontSize: 10),
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
