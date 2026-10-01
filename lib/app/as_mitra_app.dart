import 'package:flutter/material.dart';

import '../ui/prototype_screen.dart';

class AsMitraApp extends StatelessWidget {
  const AsMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'As Mitra Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: const PrototypeScreen(),
    );
  }
}
