import 'package:chat_app/services/auth/login_or_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer; // Import developer for logging

import '../../pages/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Log the stream state
          developer.log(
              'Auth Stream Snapshot: connectionState=${snapshot.connectionState}, hasData=${snapshot.hasData}, hasError=${snapshot.hasError}, error=${snapshot.error}');

          // Handle connection states explicitly for debugging
          if (snapshot.connectionState == ConnectionState.waiting) {
            developer.log('Auth Stream: Waiting for connection...');
            // Optionally show a loading indicator while waiting
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            developer.log('Auth Stream Error: ${snapshot.error}');
            // Optionally show an error message
            return const Center(child: Text('Something went wrong!'));
          }

          // If we have data, user is logged in
          if (snapshot.hasData) {
            developer.log('Auth Stream: User is logged in.');
            return HomePage(); // Navigate to HomePage
          }
          // Otherwise, user is not logged in
          else {
            developer.log('Auth Stream: User is logged out.');
            return const LoginOrRegister(); // Navigate to Login/Register
          }
        },
      ),
    );
  }
}
