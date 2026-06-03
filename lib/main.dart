import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AlgoMealApp());
}

class AlgoMealApp extends StatelessWidget {
  const AlgoMealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AlgoMeal',
      home: const LoginScreen(),
    );
  }
}