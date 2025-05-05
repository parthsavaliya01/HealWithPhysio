import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heal_with_physio/main.dart';
import 'package:heal_with_physio/view/patient/dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController unameController = TextEditingController(text: "keshwi");  // aa banne kadhi nakhva nu jo by default na joi ae to

  final TextEditingController passwordController = TextEditingController(text: "Keshwi@123");

Future<void> login(BuildContext context) async {
  var url = Uri.parse("http://${MyApp.ip}/capstone/patient_login.php");

  // Validate input fields
  if (unameController.text.isEmpty || passwordController.text.isEmpty) {
    _showSnackBar(context, "Both fields are required", Colors.red);
    return;
  }

  try {
    // Make API request
    var response = await http.post(url, body: {
      "username": unameController.text,
      "password": passwordController.text,
    });

    var data = jsonDecode(response.body);

    // Check API response
    if (data['status'] == 'success') {
      _showSnackBar(context, "Login Successfully", Colors.green);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', unameController.text);
      await prefs.setString('password', passwordController.text); 

      // Navigate to Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(userData: data['data']),
        ),
      );
    } else {
      _showSnackBar(context, "Invalid Username or Password", Colors.red);
    }
  } catch (e) {
    _showSnackBar(context, "Network error, please try again", Colors.red);
  }
}

// Reusable Snackbar Function
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

  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.indigo[900],size: 30,),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
      backgroundColor: Colors.lightBlue[50], // Light blue background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // App heading
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
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Add an image above the Login heading
                        Image.asset(
                          'assets/images/logo.png', // Path to the logo image
                          height: 150,
                          width: 150,
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          'Login for Patient',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[900],
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextField(
                          controller: unameController,
                          // keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        TextField(
                          controller: passwordController,
                          obscureText: _isObscured, // Toggle password visibility
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _isObscured = !_isObscured; // Toggle visibility
                                });
                              },
                            ),
                          ),
                        ),


                        SizedBox(height: 8.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, '/patient/forgotPassword');
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.indigo[700]),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              login(context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              backgroundColor: Colors.indigo[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: Text(
                              'Login',
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
                            Navigator.pushNamed(context, '/patient/signup');
                          },
                          child: Text(
                            "Don't have an account? Sign Up",
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
    );
  }
}
