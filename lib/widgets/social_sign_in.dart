// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:absence_watch/models/profile.dart';
import 'package:absence_watch/pages/home.dart';

Future<void> _signInWithGoogle(
    BuildContext context, Widget redirectPage) async {
  try {
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        Profile profile = Profile(
          userId: userCredential.user!.uid,
          firstName: userCredential.user!.displayName ?? "",
          lastName: "",
          email: userCredential.user!.email ?? "",
          profileImageUrl: userCredential.user!.photoURL,
        );
        await profile.toFirestore();
      }

      final profile = Provider.of<Profile>(context, listen: false);
      await profile.fetchAndUpdateProfile(userCredential.user!.uid);

      if (context.mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => redirectPage));
      }
    }
  } catch (e) {
    debugPrint('Error signing in with Google: $e');
    // Handle errors (e.g., show a SnackBar or dialog to the user)
  }
}

class SocialSignInButtonBar extends StatelessWidget {
  final Widget redirectPage;
  const SocialSignInButtonBar(
      {super.key, this.redirectPage = const HomePage()});

  @override
  Widget build(BuildContext context) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: IconButton(
            iconSize: 24.0,
            icon: Image.asset(
              'assets/icons/google.png',
            ),
            onPressed: () async {
              try {
                await _signInWithGoogle(context, redirectPage);
              } catch (e) {
                debugPrint('Error signing in with Google: $e');
                // Handle potential errors
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: IconButton(
            iconSize: 24.0,
            icon: Image.asset(
              'assets/icons/apple.png',
            ),
            onPressed: () {
              // TODO: Handle login
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: IconButton(
            iconSize: 24.0,
            icon: Image.asset(
              'assets/icons/facebook.png',
            ),
            onPressed: () {
              // TODO: Handle login
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: IconButton(
            iconSize: 24.0,
            icon: Image.asset(
              'assets/icons/linkedin.png',
            ),
            onPressed: () {
              // TODO: Handle login
            },
          ),
        ),
      ],
    );
  }
}
