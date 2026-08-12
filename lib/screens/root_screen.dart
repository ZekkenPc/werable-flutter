import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'setup_pin_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';

enum _Screen { loading, setup, login, home }

// Equivalente al router() de wearable.js: decide que pantalla mostrar
// según si hay PIN configurado y si hay sesión válida.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  _Screen _screen = _Screen.loading;

  @override
  void initState() {
    super.initState();
    _resolveScreen();
  }

  Future<void> _resolveScreen() async {
    final configured = await AuthService.instance.isPinConfigured();
    if (!configured) {
      setState(() => _screen = _Screen.setup);
      return;
    }
    if (!AuthService.instance.isAuthenticated()) {
      setState(() => _screen = _Screen.login);
      return;
    }
    setState(() => _screen = _Screen.home);
  }

  void _goHome() => setState(() => _screen = _Screen.home);
  void _goLogin() => setState(() => _screen = _Screen.login);

  @override
  Widget build(BuildContext context) {
    switch (_screen) {
      case _Screen.setup:
        return SetupPinScreen(onDone: _goLogin);
      case _Screen.login:
        return LoginScreen(onSuccess: _goHome);
      case _Screen.home:
        return HomeScreen(onLogout: _goLogin);
      case _Screen.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}
