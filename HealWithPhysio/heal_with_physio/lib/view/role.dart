import 'package:flutter/material.dart';
class RolePage extends StatefulWidget {
  const RolePage({super.key});

  @override
  _RolePageState createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  String role = ''; // Default empty role selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50], // Light blue background

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/logo.png', // Make sure the logo is in the assets folder
                      height: 150,
                      width: 150,
                    ),
                    SizedBox(height: 20.0),
                    // Heading
                    Text(
                      'HealWithPhysio',
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[900],
                      ),
                    ),
                    SizedBox(height: 40.0),
                    // Role selection
                    Text(
                      'Select your Role:',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.indigo[900],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    // Radio Buttons for Role Selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio<String>(
                          value: 'Patient',
                          groupValue: role,
                          onChanged: (String? value) {
                            setState(() {
                              role = value!;
                            });
                          },
                        ),
                        Text(
                          'Patient',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.indigo[900],
                          ),
                        ),
                        Radio<String>(
                          value: 'Physiotherapist',
                          groupValue: role,
                          onChanged: (String? value) {
                            setState(() {
                              role = value!;
                            });
                          },
                        ),
                        Text(
                          'Physiotherapist',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.indigo[900],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Check role selection and navigate to Login Screen
                          if (role.isNotEmpty) {
                            if(role=="Patient"){
                              Navigator.pushNamed(context, '/patient/login');
                            }
                            else{
                              Navigator.pushNamed(context, '/physio/login');
                            }
                          } else {
                            // If no role is selected, show an alert
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please select a role!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: Colors.indigo[900], // Indigo color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
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
    );
  }
}
