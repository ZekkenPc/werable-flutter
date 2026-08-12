import 'package:flutter/material.dart';

// Teclado numérico dibujado en pantalla, para no depender del teclado del
// sistema (que en Wear OS suele no aparecer o ser incómodo de usar).
// Círculos grandes y pegados entre sí para que sea fácil tocarlos con el dedo.

class NumericKeypad extends StatelessWidget {
  final String value;
  final int maxLength;
  final ValueChanged<String> onChanged;
  final double keySize;

  const NumericKeypad({
    super.key,
    required this.value,
    required this.onChanged,
    this.maxLength = 6,
    this.keySize = 30,
  });

  void _addDigit(String digit) {
    if (value.length < maxLength) {
      onChanged(value + digit);
    }
  }

  void _backspace() {
    if (value.isNotEmpty) {
      onChanged(value.substring(0, value.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxLength, (i) {
            final filled = i < value.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? Colors.white : Colors.grey[700],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        _buildRow(['1', '2', '3']),
        _buildRow(['4', '5', '6']),
        _buildRow(['7', '8', '9']),
        _buildBottomRow(),
      ],
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits.map((d) => _key(d, () => _addDigit(d))).toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: keySize + 4),
        _key('0', () => _addDigit('0')),
        _iconKey(Icons.backspace_outlined, _backspace),
      ],
    );
  }

  Widget _key(String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.all(2.0),
      width: keySize,
      height: keySize,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          backgroundColor: Colors.grey[850],
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            fontSize: keySize * 0.38,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _iconKey(IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.all(2.0),
      width: keySize,
      height: keySize,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          backgroundColor: Colors.grey[850],
        ),
        onPressed: onTap,
        child: Icon(icon, size: keySize * 0.32),
      ),
    );
  }
}
