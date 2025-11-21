import 'package:flutter/material.dart';
import 'package:atlasvault/theme.dart';
import 'package:atlasvault/screens/home_page.dart';

void main() {
  runApp(const AtlasVaultApp());
}

class AtlasVaultApp extends StatelessWidget {
  const AtlasVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AtlasVault - Asset Management',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
