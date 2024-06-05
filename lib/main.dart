import 'package:absence_watch/pages/trips.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'models/profile.dart';
import 'pages/home.dart';
import 'package:provider/provider.dart';

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
