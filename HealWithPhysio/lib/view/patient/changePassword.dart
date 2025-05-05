import 'package:flutter/material.dart';
import 'package:heal_with_physio/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, required String email});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _isObscured = true;
  bool c_isObscured = true;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>(); // Added Form key for validation

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<String?> _getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) { // Check form validation
      String newPassword = newPasswordController.text.trim();
      String confirmPassword = confirmPasswordController.text.trim();
      String? email = await _getEmail();

      if (newPassword.isEmpty || confirmPassword.isEmpty) {
        _showSnackBar(context, 'Both Password fields are required', Colors.red);
        return;
      }

      if (newPassword != confirmPassword) {
        _showSnackBar(context, 'Both Password are not equal', Colors.red);
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('http://${MyApp.ip}/capstone/patient_changepassword.php'), // Replace with your API URL
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': email,
            'new_password': newPassword,
          }),
        );

        final result = json.decode(response.body);

        if (response.statusCode == 200 && result['status'] == 'success') {
          _showSnackBar(context, 'Password Updated successfully', Colors.green);
          // Clear SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('user_email');
          // Navigate to login
          Navigator.pushReplacementNamed(context, '/patient/login');
        } else {
          _showSnackBar(context, result['message'] ?? 'Failed to Update password', Colors.red);
        }
      } catch (e) {
        _showSnackBar(context, 'Error: $e', Colors.red);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "HealWithPhysio",
                      style: TextStyle(
                        fontSize: 36.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[900],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Card(
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form( // Added Form widget
                          key: _formKey, // Assigned form key
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                height: 150,
                                width: 150,
                              ),
                              SizedBox(height: 20.0),
                              Text(
                                'Change Password',
                                style: TextStyle(
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[900],
                                ),
                              ),
                              SizedBox(height: 20.0),
                              TextFormField(
                                controller: newPasswordController,
                                obscureText: _isObscured,
                                decoration: InputDecoration(
                                  labelText: 'New Password',
                                  helperText: "Must be 8+ characters, 1 uppercase, 1 number, 1 special char",
                                  prefixIcon: Icon(Icons.lock),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        _isObscured = !_isObscured; // Toggle password visibility
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter a password";
                                  }
                                  if (value.length < 8) {
                                    return "Password must be at least 8 characters long";
                                  }
                                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                    return "Must contain at least one uppercase letter";
                                  }
                                  if (!RegExp(r'[a-z]').hasMatch(value)) {
                                    return "Must contain at least one lowercase letter";
                                  }
                                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                                    return "Must contain at least one number";
                                  }
                                  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                                    return "Must contain at least one special character";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 8.0),
                              TextFormField(
                                controller: confirmPasswordController,
                                obscureText: c_isObscured, // Fixed to use c_isObscured
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  helperText: "Must be 8+ characters, 1 uppercase, 1 number, 1 special char",
                                  prefixIcon: Icon(Icons.lock),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(c_isObscured ? Icons.visibility : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        c_isObscured = !c_isObscured; // Toggle confirm password visibility
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter a password";
                                  }
                                  if (value != newPasswordController.text) {
                                    return "Passwords do not match";
                                  }
                                  if (value.length < 8) {
                                    return "Password must be at least 8 characters long";
                                  }
                                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                    return "Must contain at least one uppercase letter";
                                  }
                                  if (!RegExp(r'[a-z]').hasMatch(value)) {
                                    return "Must contain at least one lowercase letter";
                                  }
                                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                                    return "Must contain at least one number";
                                  }
                                  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                                    return "Must contain at least one special character";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20.0),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _updatePassword,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    backgroundColor: Colors.indigo[900],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  child: Text(
                                    'Change Password',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.0),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/patient/login');
                                },
                                child: Text(
                                  "Back to LogIn",
                                  style: TextStyle(
                                    color: Colors.indigo[900],
                                    fontSize: 16.0,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}