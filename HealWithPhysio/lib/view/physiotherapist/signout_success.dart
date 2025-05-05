import 'package:flutter/material.dart';

class SignoutPagePhysio extends StatelessWidget {
  const SignoutPagePhysio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.lightBlue[50],
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
                          Text("Account deleted successfully",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.indigo[900]
                            ),),
                          SizedBox(height: 30,),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigate to the Dashboard
                                Navigator.pushNamed(context, '/physio/signup');
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                backgroundColor: Colors.indigo[900], // Indigo color background
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: Text(
                                'Back To SignUp',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white, // White text color
                                ),
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
      ),
    );
  }
}


