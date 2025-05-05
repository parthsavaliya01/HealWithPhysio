

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heal_with_physio/main.dart';
import 'package:http/http.dart' as http;
import 'package:heal_with_physio/view/physiotherapist/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreenPhysio extends StatefulWidget {
  const LoginScreenPhysio({super.key});

  @override
  State<LoginScreenPhysio> createState() => _LoginScreenPhysioState();
}

class _LoginScreenPhysioState extends State<LoginScreenPhysio> {
  final TextEditingController unameController = TextEditingController(text: "payal");

  final TextEditingController passwordController = TextEditingController(text: "Payal@123");

  Future<void> login(BuildContext context) async {
  var url = Uri.parse("http://${MyApp.ip}/capstone/physiotherapiest_login.php");

  // Check if email or password is empty
  if (unameController.text.isEmpty || passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Both fields are Required", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    return;
  }

  // Make API request
  var response = await http.post(url, body: {
    "username": unameController.text,
    "password": passwordController.text,
  });

  var data = json.decode(response.body);

  // Check API response
  if (data['status'] == 'success') {
    // Store username & password in SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', unameController.text);
    await prefs.setString('password', passwordController.text);

    print("Saved Username: ${prefs.getString('username')}");
    print("Saved Password: ${prefs.getString('password')}");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("LogIn Successfully", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Navigate to the Dashboard page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DashboardScreenPhysio(userData: data)),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Invalid Username and Password", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
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
      backgroundColor: Colors.lightBlue[50],
      body: Center(
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
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // App Logo
                        Image.asset(
                          'assets/images/logo.png',
                          height: 150,
                          width: 150,
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          'Login for Physiotherapist',
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
                            prefixIcon: Icon(Icons.email),
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
                              Navigator.pushNamed(context, '/physio/forgotPassword');
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
                            onPressed: () => login(context),
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
                            Navigator.pushNamed(context, '/physio/signup');
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
