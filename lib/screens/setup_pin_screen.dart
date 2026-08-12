import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/numeric_keypad.dart';

class SetupPinScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SetupPinScreen({super.key, required this.onDone});

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  String _pin = '';
  String? _error;

  Future<void> _save() async {
    try {
      await AuthService.instance.setupPin(_pin);
      widget.onDone();
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _pin = '';
      });
    }
  }

  void _onChanged(String value) {
    setState(() {
      _pin = value;
      _error = null;
    });
    if (value.length == 6) {
      _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Configura tu PIN',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              NumericKeypad(value: _pin, onChanged: _onChanged),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_pin.length >= 4)
                TextButton(
                  onPressed: _save,
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
