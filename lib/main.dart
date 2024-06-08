// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:absence_watch/firebase_options.dart';
import 'package:absence_watch/models/profile.dart';
import 'package:absence_watch/pages/home.dart';
import 'package:absence_watch/pages/login.dart';
import 'package:absence_watch/pages/trips.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Use Firestore emulator
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);

  // Use Firebase Auth emulator
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  runApp(ChangeNotifierProvider(
      create: (context) => Profile(), child: const AbsenceWatchApp()));
}

class AbsenceWatchApp extends StatelessWidget {
  const AbsenceWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AbsenceWatch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(redirectPage: HomePage()),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/trips': (context) => TripsPage(),
      },
    );
  }
}
