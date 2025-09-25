//
// RegisterPage: User sign up page for PatchUp app.
// Handles registration form, validation, API call, and navigation.
//

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../components/appbar.dart' show UserSession;
import '../components/bottonnav.dart';
import '../localization/app_localizations.dart';
import '../main.dart';
import 'login.dart';
import 'terms_conditions.dart';

// Register page widget
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

// State for registration logic and UI
class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _acceptedTerms = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final RegExp nameRegExp = RegExp(r"^[a-zA-Z][a-zA-Z\s'-]{1,99}$");
  final RegExp emailRegExp = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );
  final RegExp passwordRegExp = RegExp(
    r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$",
  );
  final List<String> commonPasswords = [
    "password",
    "123456",
    "12345678",
    "qwerty",
    "abc123",
    "111111",
    "123456789",
    "12345",
    "123123",
    "admin",
  ];

  // Handles registration logic and API call
  Future<void> _register() async {
    final appLoc = AppLocalizations.of(context);
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (name.isEmpty || !nameRegExp.hasMatch(name)) {
      _showError(
        "Please enter a valid name (letters, spaces, hyphens, apostrophes, 2-100 chars).",
      );
      return;
    }
    if (email.isEmpty || !emailRegExp.hasMatch(email)) {
      _showError("Please enter a valid email address.");
      return;
    }
    if (password.isEmpty ||
        password.length < 8 ||
        !passwordRegExp.hasMatch(password)) {
      _showError(
        "Password must be at least 8 characters and include uppercase, lowercase, number, and special character.",
      );
      return;
    }
    if (commonPasswords.contains(password.toLowerCase())) {
      _showError("Password is too common. Please choose a stronger password.");
      return;
    }
    if (!_acceptedTerms) {
      _showError("You must accept the Terms and Conditions to register.");
      return;
    }

    final url = 'http://192.168.8.187/patchup_app/lib/api/register.php';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "Name": name,
        "Email": email,
        "PasswordHash": password,
      }),
    );
    final result = jsonDecode(response.body);
    if (result["success"]) {
      UserSession.email = email;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', UserSession.email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appLoc.translate("Registration successful! Welcome!"),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          backgroundColor: const Color(0xFF27AE60),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          duration: const Duration(seconds: 3),
          elevation: 0,
        ),
      );
      await Future.delayed(const Duration(seconds: 3));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavigationExample()),
      );
    } else {
      _showError(result["message"] ?? "Unknown error");
    }
  }

  // Shows error dialog for registration errors
  void _showError(String message) {
    final appLoc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 24,
            shadowColor: Colors.black.withOpacity(0.2),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appLoc.translate("Registration Failed"),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: const Color(0xFF04274B),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF04274B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  appLoc.translate("OK"),
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: const Color(0xFF04274B),
          selectionColor: const Color(0xFF04274B).withOpacity(0.3),
          selectionHandleColor: const Color(0xFF04274B),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF04274B),
        appBar: AppBar(
          backgroundColor: const Color(0xFF04274B),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: Container(
            margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                );
              },
            ),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo/Logo 2.webp',
                        width: 180,
                        height: 135,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Registration form card
                  Center(
                    child: Card(
                      elevation: 18,
                      shadowColor: Colors.black.withOpacity(0.18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.97),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 32,
                            horizontal: 28,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Title and subtitle
                                Text(
                                  appLoc.translate('Create Account'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF04274B),
                                    letterSpacing: -1.2,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  appLoc.translate('Sign up to get started'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFB1B5C3),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                // Name field
                                Text(
                                  appLoc.translate('Name'),
                                  style: const TextStyle(
                                    color: Color(0xFF8F9BB3),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Focus(
                                  child: Builder(
                                    builder: (context) {
                                      final hasFocus =
                                          Focus.of(context).hasFocus;
                                      return TextFormField(
                                        controller: _nameController,
                                        cursorColor: const Color(0xFF04274B),
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                vertical: 10,
                                                horizontal: 16,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide(
                                              color:
                                                  hasFocus
                                                      ? const Color(0xFF04274B)
                                                      : const Color(0xFFE4E9F2),
                                              width: hasFocus ? 2 : 1,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE4E9F2),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF04274B),
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFFF7F9FC),
                                        ),
                                        style: const TextStyle(fontSize: 16),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 18),
                                // Email field
                                Text(
                                  appLoc.translate('Email Login'),
                                  style: const TextStyle(
                                    color: Color(0xFF8F9BB3),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Focus(
                                  child: Builder(
                                    builder: (context) {
                                      final hasFocus =
                                          Focus.of(context).hasFocus;
                                      return TextFormField(
                                        controller: _emailController,
                                        cursorColor: const Color(0xFF04274B),
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                vertical: 10,
                                                horizontal: 16,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide(
                                              color:
                                                  hasFocus
                                                      ? const Color(0xFF04274B)
                                                      : const Color(0xFFE4E9F2),
                                              width: hasFocus ? 2 : 1,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE4E9F2),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF04274B),
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFFF7F9FC),
                                        ),
                                        style: const TextStyle(fontSize: 16),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 18),
                                // Password field
                                Text(
                                  appLoc.translate('Password'),
                                  style: const TextStyle(
                                    color: Color(0xFF8F9BB3),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Focus(
                                  child: Builder(
                                    builder: (context) {
                                      final hasFocus =
                                          Focus.of(context).hasFocus;
                                      return TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        cursorColor: const Color(0xFF04274B),
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                vertical: 10,
                                                horizontal: 16,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: BorderSide(
                                              color:
                                                  hasFocus
                                                      ? const Color(0xFF04274B)
                                                      : const Color(0xFFE4E9F2),
                                              width: hasFocus ? 2 : 1,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE4E9F2),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF04274B),
                                              width: 2,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFFF7F9FC),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: const Color(0xFF8F9BB3),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              });
                                            },
                                          ),
                                        ),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          letterSpacing: 2,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Terms and conditions checkbox
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Checkbox(
                                      value: _acceptedTerms,
                                      onChanged: (value) {
                                        setState(() {
                                          _acceptedTerms = value ?? false;
                                        });
                                      },
                                      activeColor: const Color(0xFF04274B),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const TermsConditionsPage(),
                                            ),
                                          );
                                        },
                                        child: RichText(
                                          text: TextSpan(
                                            text:
                                                appLoc.translate(
                                                  'I agree to the',
                                                ) +
                                                ' ',
                                            style: const TextStyle(
                                              color: Color(0xFF04274B),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: appLoc.translate(
                                                  'Terms and Conditions',
                                                ),
                                                style: const TextStyle(
                                                  color: Color(0xFF04274B),
                                                  decoration:
                                                      TextDecoration.underline,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Sign up button
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed:
                                        _acceptedTerms ? _register : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF04274B),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                    ),
                                    child: Text(
                                      appLoc.translate('Sign Up'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Login link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          appLoc.translate('Already have an account?'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            appLoc.translate('Log In'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
