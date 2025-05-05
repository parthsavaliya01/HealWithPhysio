import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

class ForgotPasswordScreenPhysio extends StatefulWidget {
  const ForgotPasswordScreenPhysio({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreenPhysio> {
  final TextEditingController emailController = TextEditingController();
  final List<TextEditingController> otpControllers =
      List.generate(4, (index) => TextEditingController());

  bool otpSent = false;
  String? emailError;
  String? otpError;
  String generatedOtp = '';
  bool isLoading = false;

  // Save email to SharedPreferences
  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('physio_email', email); // Using a different key than patient
  }

  // Generate random 4-digit OTP
  String _generateOtp() {
    final random = Random();
    return List.generate(4, (_) => random.nextInt(10)).join();
  }

  // Send OTP via EmailJS
  Future<void> _sendOtp(String email) async {
    setState(() {
      isLoading = true;
    });

    generatedOtp = _generateOtp();

    const serviceId = 'service_by91gas';
    const templateId = 'template_eruqeuw';
    const userId = 'EUTzH9-D2thpNSplQ';

    final requestBody = json.encode({
      'service_id': serviceId,
      'template_id': templateId,
      'user_id': userId,
      'template_params': {
        'email': email,
        'to': email,
        'otp': generatedOtp,
        'from_name': 'HealWithPhysio',
      },
    });

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      setState(() {
        otpSent = true;
        otpError = null;
      });
      await _saveEmail(email); // Save email when OTP is sent successfully
      _showSnackBar(context, 'OTP sent to $email', Colors.green);
    } else {
      setState(() {
        emailError = 'Failed to send OTP: ${response.body}';
      });
      _showSnackBar(context, "Failed to send OTP..!", Colors.red);
    }

    setState(() {
      isLoading = false;
    });
  }

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

  // Verify OTP
  bool _verifyOtp() {
    String enteredOtp = otpControllers.map((controller) => controller.text).join();
    return enteredOtp == generatedOtp;
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              height: 150,
                              width: 150,
                            ),
                            SizedBox(height: 20.0),
                            Text(
                              'Reset Password',
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo[900],
                              ),
                            ),
                            SizedBox(height: 20.0),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                                helperText: 'Enter a valid email (e.g., example@gmail.com)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter email";
                                }
                                String pattern =
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                                RegExp regex = RegExp(pattern);
                                if (!regex.hasMatch(value)) {
                                  return "Enter a valid email (e.g., example@gmail.com)";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 30.0),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        String email = emailController.text.trim();
                                        if (!EmailValidator.validate(email)) {
                                          setState(() {
                                            emailError = 'Please enter a valid email address';
                                          });
                                        } else {
                                          setState(() {
                                            emailError = null;
                                          });
                                          _sendOtp(email);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  backgroundColor: Colors.indigo[900],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                child: Text(
                                  otpSent ? 'Resend OTP' : 'Get OTP',
                                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                                ),
                              ),
                            ),
                            if (otpSent) ...[
                              SizedBox(height: 20.0),
                              Text(
                                'Enter 4-digit OTP',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              if (otpError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    otpError!,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(4, (index) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    child: TextField(
                                      controller: otpControllers[index],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      maxLength: 1,
                                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                      decoration: InputDecoration(
                                        counterText: '',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      onChanged: (value) {
                                        if (value.isNotEmpty && index < 3) {
                                          FocusScope.of(context).nextFocus();
                                        }
                                      },
                                    ),
                                  );
                                }),
                              ),
                              SizedBox(height: 20.0),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () async {
                                          if (_verifyOtp()) {
                                            // Clear OTP fields
                                            for (var controller in otpControllers) {
                                              controller.clear();
                                            }
                                            // Navigate to ChangePassword page
                                            Navigator.pushReplacementNamed(
                                              context,
                                              '/physio/changePassword',
                                            );
                                          } else {
                                            setState(() {
                                              otpError = 'Invalid OTP';
                                            });
                                            _showSnackBar(
                                              context,
                                              'Invalid OTP entered',
                                              Colors.red,
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(height: 16.0),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/physio/login');
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
    emailController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}