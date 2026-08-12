import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';
import '../models/incident.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const HomeScreen({super.key, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Incident? _activeIncident;
  late final String _pairingPin; // PIN de vinculación con Smart TV (distinto del PIN de login)

  @override
  void initState() {
    super.initState();
    _pairingPin = _generatePairingPin();
    SocketService.instance.onIncidentCreated = _handleCreated;
    SocketService.instance.onIncidentUpdated = _handleUpdated;
    SocketService.instance.connect();
  }

  @override
  void dispose() {
    SocketService.instance.onIncidentCreated = null;
    SocketService.instance.onIncidentUpdated = null;
    super.dispose();
  }

  String _generatePairingPin() {
    final rand = Random();
    return (100000 + rand.nextInt(900000)).toString();
  }

  void _handleCreated(Incident incident) {
    if (incident.priority == 'CRITICAL' && mounted) {
      setState(() => _activeIncident = incident);
      _vibrate();
    }
  }

  void _handleUpdated(Incident incident) {
    if (_activeIncident != null && _activeIncident!.id == incident.id && mounted) {
      setState(() => _activeIncident = null);
    }
  }

  Future<void> _vibrate() async {
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (hasVibrator) {
      // Patrón equivalente a navigator.vibrate([200, 100, 200]) en la web
      Vibration.vibrate(pattern: [0, 200, 100, 200]);
    }
  }

  void _accept() {
    final incident = _activeIncident;
    if (incident == null) return;
    SocketService.instance.claimIncident(incident.id, (_) {
      if (mounted) setState(() => _activeIncident = null);
    });
  }

  void _reject() {
    final incident = _activeIncident;
    if (incident == null) return;
    SocketService.instance.rejectIncident(incident.id);
    setState(() => _activeIncident = null);
  }

  void _logout() {
    AuthService.instance.logout();
    SocketService.instance.disconnect();
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    AuthService.instance.touchSession();

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _pairingPin,
                      style: const TextStyle(
                        fontSize: 20,
                        letterSpacing: 4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_activeIncident != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[700],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _activeIncident!.priority,
                        style: const TextStyle(fontSize: 9, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _activeIncident!.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                          onPressed: _accept,
                          child: const Text('Aceptar', style: TextStyle(fontSize: 11)),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
                          onPressed: _reject,
                          child: const Text('Rechazar', style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ] else
                    const Text(
                      'Sin incidencias críticas',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: TextButton(
              onPressed: _logout,
              child: const Text('Salir', style: TextStyle(fontSize: 9)),
            ),
          ),
        ],
      ),
    );
  }
}
