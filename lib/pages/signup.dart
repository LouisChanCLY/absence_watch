// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:form_validator/form_validator.dart';
import 'package:provider/provider.dart';

// Project imports:
import '../models/profile.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  SignupPageState createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          // Add Form widget
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              // Logo image
              // Image.asset('assets/images/your_logo.png'),
              const SizedBox(height: 20.0),
              // Full name text field
              TextFormField(
                controller: _firstNameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  hintText: 'John',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
                validator: ValidationBuilder().minLength(1).build(),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: _lastNameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  hintText: 'Doe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
                validator: ValidationBuilder().minLength(1).build(),
              ),
              const SizedBox(height: 10.0),
              // Email address text field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'example@example.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
                validator: ValidationBuilder().email().maxLength(50).build(),
              ),
              const SizedBox(height: 10.0),
              // Phone number text field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'UK Phone Number',
                  hintText: '07123456789',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
                validator: ValidationBuilder()
                    .phone()
                    .minLength(10)
                    .maxLength(11)
                    .regExp(RegExp(r"^(?:0?)([1-9])\d{9}$"),
                        "Invalid UK phone number.")
                    .build(),
              ),
              const SizedBox(height: 10.0),
              // Password text field
              TextFormField(
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
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
                validator: ValidationBuilder()
                    .required()
                    .minLength(
                        8, "Password needs to be at least 8 characters long.")
                    .build(),
              ),
              const SizedBox(height: 10.0),
              // Confirm password text field
              TextFormField(
                obscureText: _obscureConfirmPassword,
                keyboardType: TextInputType.visiblePassword,
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  // Required check
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  // Password match check
                  if (value != _passwordController.text) {
                    return 'Passwords don\'t match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              // Terms & Conditions text
              FormField<bool>(
                initialValue: _agreedToTerms,
                builder: (fieldState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CheckboxListTile(
                        value: _agreedToTerms,
                        title: const Text(
                            'By signing up, you agree to our Terms & Conditions.'),
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value!;
                            fieldState.didChange(value);
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      if (fieldState.hasError)
                        Text(
                          fieldState.errorText ?? 'You must agree to the terms',
                          style: const TextStyle(color: Colors.red),
                        ),
                    ],
                  );
                },
                validator: (value) {
                  if (value == null || value == false) {
                    return 'You must agree to the Terms & Conditions';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              // Sign up button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      // Retrieve user input. Adapt for your specific form fields.
                      final String email = _emailController.text.trim();
                      final String password = _passwordController.text.trim();

                      // Attempt to create the user
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      String uid = userCredential.user!.uid;
                      String firstName = _firstNameController.text.trim();

                      final Profile newProfile = Profile(
                        userId: uid,
                        firstName: firstName,
                        lastName: _lastNameController.text.trim(),
                        email: email,
                        phone: _phoneController.text.trim(),
                      );

                      await newProfile.toFirestore();

                      if (!context.mounted) return;

                      Provider.of<Profile>(context, listen: false)
                          .fetchAndUpdateProfile(userCredential.user!.uid);

                      // TODO: Send welcome email
                      // User creation successful - Handle success
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Welcome $firstName')),
                      );
                      Navigator.pushReplacementNamed(context, '/home');
                    } on FirebaseAuthException catch (e) {
                      // Handle Firebase Authentication errors

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(e.message ??
                              'Unknown signup error. Please try again.'),
                        ));
                      }
                    } catch (e) {
                      // Handle other potential errors
                      debugPrint(e as String?);
                    }
                  }
                }, // Add your sign up logic here
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 10.0),
              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
