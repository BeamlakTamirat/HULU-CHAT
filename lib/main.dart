//// filepath: /c:/flutter/chat_app/lib/main.dart
library;

import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/register_page.dart';
import 'package:chat_app/pages/splash_screen.dart';
import 'package:chat_app/services/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only if it hasn't been initialized yet
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  // Configure Firebase Storage for better error handling
  FirebaseStorage.instance.setMaxUploadRetryTime(const Duration(seconds: 15));
  FirebaseStorage.instance
      .setMaxOperationRetryTime(const Duration(seconds: 10));

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the theme from our provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Flutter-Chat-App',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.getTheme(), // Use our theme provider
      home: const SplashScreen(),
      routes: {
        '/login': (context) => LoginPage(
              onTap: () => Navigator.pushReplacementNamed(context, '/register'),
            ),
        '/register': (context) => RegisterPage(
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
        '/home': (context) => const HomePage(),
      },
      // Use a builder to add any global configurations or wrappers
      builder: (context, child) {
        return MediaQuery(
          // Set default text scaling to prevent UI issues
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}
