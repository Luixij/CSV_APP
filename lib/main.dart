import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/open_csv_screen.dart';
import 'screens/create_csv_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 🔥 Oculta el banner DEBUG
      title: 'CSV Manager',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/open_csv': (context) => OpenCSVScreen(filePath: ModalRoute.of(context)!.settings.arguments as String),
        '/create_csv': (context) => const CreateCSVScreen(),
      },
    );
  }
}
