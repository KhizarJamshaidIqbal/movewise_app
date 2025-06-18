// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/registration_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MoveWiseApp());
}

class MoveWiseApp extends StatelessWidget {
  const MoveWiseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MOVEWISE',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const RegistrationScreen(),
        '/dashboard': (context) => const DashboardScreen(userName: 'User'),
        '/settings': (context) => const SettingsScreen(userName: 'User'),
        '/profile': (context) => const ProfileScreen(userName: 'User'),
      },
      // Check authentication state before deciding which screen to show
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in, fetch user data and show dashboard
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(snapshot.data!.uid)
                    .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              String userName = 'User';
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                Map<String, dynamic> userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                userName = userData['name'] ?? 'User';
              }

              return DashboardScreen(userName: userName);
            },
          );
        }

        // If no user is logged in, show login screen
        return const LoginScreen();
      },
    );
  }
}
