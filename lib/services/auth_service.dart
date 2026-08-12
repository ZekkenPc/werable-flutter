import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mismo diseño de seguridad que la versión web (Prácticas 11/12):
// - PIN nunca en texto plano: se guarda SHA-256(salt + pin).
// - Bloqueo temporal tras 5 intentos fallidos.
// - Sesión en memoria (no persiste al reiniciar la app) que expira
//   sola a los 5 minutos de inactividad.

class VerifyResult {
  final bool ok;
  final String? reason; // WRONG_PIN | LOCKED | LOCKED_NOW | NOT_CONFIGURED
  final int? attemptsLeft;
  final int? secondsLeft;

  VerifyResult({required this.ok, this.reason, this.attemptsLeft, this.secondsLeft});
}

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  static const _saltKey = 'wearable_pin_salt';
  static const _hashKey = 'wearable_pin_hash';
  static const int maxAttempts = 5;
  static const int lockoutSeconds = 30;
  static const int sessionTimeoutSeconds = 5 * 60;

  int _failedAttempts = 0;
  DateTime? _lockedUntil;
  DateTime? _authenticatedAt;

  Future<bool> isPinConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_hashKey);
  }

  String _hash(String pin, String saltHex) {
    final saltBytes = List<int>.generate(
      saltHex.length ~/ 2,
      (i) => int.parse(saltHex.substring(i * 2, i * 2 + 2), radix: 16),
    );
    final pinBytes = utf8.encode(pin);
    final digest = sha256.convert([...saltBytes, ...pinBytes]);
    return digest.toString();
  }

  String _randomSaltHex() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<void> setupPin(String pin) async {
    if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) {
      throw Exception('El PIN debe tener 4 a 6 dígitos');
    }
    final prefs = await SharedPreferences.getInstance();
    final salt = _randomSaltHex();
    final hash = _hash(pin, salt);
    await prefs.setString(_saltKey, salt);
    await prefs.setString(_hashKey, hash);
  }

  Future<VerifyResult> verifyPin(String pin) async {
    final now = DateTime.now();
    if (_lockedUntil != null && now.isBefore(_lockedUntil!)) {
      return VerifyResult(
        ok: false,
        reason: 'LOCKED',
        secondsLeft: _lockedUntil!.difference(now).inSeconds,
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final salt = prefs.getString(_saltKey);
    final storedHash = prefs.getString(_hashKey);
    if (salt == null || storedHash == null) {
      return VerifyResult(ok: false, reason: 'NOT_CONFIGURED');
    }

    final attemptHash = _hash(pin, salt);
    if (attemptHash == storedHash) {
      _failedAttempts = 0;
      _authenticatedAt = DateTime.now();
      return VerifyResult(ok: true);
    }

    _failedAttempts++;
    if (_failedAttempts >= maxAttempts) {
      _lockedUntil = DateTime.now().add(const Duration(seconds: lockoutSeconds));
      _failedAttempts = 0;
      return VerifyResult(ok: false, reason: 'LOCKED_NOW', secondsLeft: lockoutSeconds);
    }

    return VerifyResult(
      ok: false,
      reason: 'WRONG_PIN',
      attemptsLeft: maxAttempts - _failedAttempts,
    );
  }

  bool isAuthenticated() {
    if (_authenticatedAt == null) return false;
    final expired =
        DateTime.now().difference(_authenticatedAt!).inSeconds > sessionTimeoutSeconds;
    if (expired) {
      logout();
      return false;
    }
    return true;
  }

  void touchSession() {
    if (isAuthenticated()) {
      _authenticatedAt = DateTime.now();
    }
  }

  void logout() {
    _authenticatedAt = null;
  }

  // Util para reiniciar la demo
  Future<void> resetPinConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saltKey);
    await prefs.remove(_hashKey);
    logout();
  }
}
