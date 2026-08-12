import 'package:flutter/material.dart';
import 'screens/root_screen.dart';

void main() {
  runApp(const IncidentsWearableApp());
}

class IncidentsWearableApp extends StatelessWidget {
  const IncidentsWearableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: false).copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const RootScreen(),
    );
  }
}
