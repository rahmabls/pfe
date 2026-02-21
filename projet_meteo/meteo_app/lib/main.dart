import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'forecast_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/forecast': (context) => const ForecastScreen(),
      },
    );
  }
}
