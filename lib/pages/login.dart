// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:form_validator/form_validator.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:absence_watch/common/theme.dart';
import 'package:absence_watch/models/profile.dart';
import 'package:absence_watch/pages/home.dart';
import 'package:absence_watch/pages/signup.dart';
import 'package:absence_watch/widgets/social_sign_in.dart';

class LoginPage extends StatefulWidget {
  final Widget redirectPage;
  const LoginPage({super.key, this.redirectPage = const HomePage()});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          // Add Form widget
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              const SizedBox(height: 80.0),
              const Center(
                child: Text(
                  'Welcome Back',
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
                validator: ValidationBuilder().required().email().build(),
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Your Password',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: ValidationBuilder().required().build(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: const Text('Forgot password?'),
                    onPressed: () {
                      // TODO: Handle forgot password
                    },
                  ),
                ],
              ),
              Center(
                child: FilledButton(
                  style: primaryButtonStyle,
                  child: const Text('Login'),
                  onPressed: () async {
                    if (!(_formKey.currentState!.validate())) {
                      return;
                    }

                    // Retrieve email and password - Adapt for your input types
                    final String email = _emailController.text.trim();
                    final String password = _passwordController.text.trim();

                    try {
                      final UserCredential userCredential = await FirebaseAuth
                          .instance
                          .signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      // Successful sign-in
                      if (!context.mounted) return;

                      Provider.of<Profile>(context, listen: false)
                          .fetchAndUpdateProfile(userCredential.user!.uid);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => widget.redirectPage),
                      );
                    } on FirebaseAuthException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(e.message ?? 'Login failed'),
                      ));
                    } on Exception {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('An unknown error occurred')));
                    }
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Row(children: <Widget>[
                  Expanded(child: Divider()),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text("Or Login with")),
                  Expanded(child: Divider()),
                ]),
              ),
              SocialSignInButtonBar(redirectPage: widget.redirectPage),
              const SizedBox(height: 20.0),
              Center(
                child: TextButton(
                  child: const Text('Don\'t have an account? Sign up.'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
