import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heal_with_physio/main.dart';
import 'package:heal_with_physio/view/patient/login.dart';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedGender;

  final TextEditingController unameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController cityController = TextEditingController(); // Still declared but not used in UI
  final TextEditingController pincodeController = TextEditingController();

  String? selectedCity; // Variable for dropdown city selection

  // List of cities for dropdown
  final List<String> cities = [
    'Ahmedabad',
    'Surat',
    'Vadodara',
    'Gandhinagar',
    'Rajkot'
  ];

  // API URL - Change this to your server URL
  final String apiUrl = "http://${MyApp.ip}/capstone/patient_signup.php";

  // Function to handle signup
  Future<void> registerPatient() async {
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": unameController.text,
        "name": nameController.text,
        "password": passwordController.text,
        "contact_no": contactController.text,
        "email": emailController.text,
        "gender": selectedGender ?? "Male",
        "appartment": apartmentController.text,
        "landmark": landmarkController.text,
        "area": areaController.text,
        "city": selectedCity ?? "", // Use selectedCity instead of cityController.text
        "pincode": pincodeController.text,
      }),
    );

    print("Raw Response: ${response.body}"); // Debugging

    try {
      var responseData = jsonDecode(response.body);
      print("Decoded Response: $responseData"); // Debugging

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Signup Successful!",
              style: TextStyle(color: Colors.white), // Foreground (text) color
            ),
            backgroundColor: Colors.green, // Background color
            behavior: SnackBarBehavior.floating, // Makes it float above UI
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${responseData['error']}")),
        );
      }
    } catch (e) {
      print("JSON Parsing Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server Error!")),
      );
    }
  }

  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: Text(
          "Patient Signup",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo[900],
        iconTheme:
        IconThemeData(color: Colors.white), // Also sets back button color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Sign Up for Patient',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: unameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? "Please enter username" : null,
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                        helperText: ("e.g., Firstname Lastname Surname"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? "Please enter Full Name" : null,
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: passwordController,
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        helperText:
                        "Must be 8+ characters, 1 uppercase, 1 number, 1 special char",
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscured
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isObscured =
                              !_isObscured; // Toggle password visibility
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
                        if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                            .hasMatch(value)) {
                          return "Must contain at least one special character";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: contactController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Contact Number',
                        prefixIcon: Icon(Icons.phone),
                        helperText: ("Enter valid contact number"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter contact number";
                        } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                          return "Enter a valid 10-digit number";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        helperText:
                        'Enter a valid email (e.g., example@gmail.com)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter email";
                        }
                        // Regular expression for validating an email
                        String pattern =
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                        RegExp regex = RegExp(pattern);
                        if (!regex.hasMatch(value)) {
                          return "Enter a valid email (e.g., example@gmail.com)";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Gender',
                      style: TextStyle(fontSize: 16.0, color: Colors.indigo[900]),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Male'),
                            value: 'Male',
                            groupValue: selectedGender,
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text('Female'),
                            value: 'Female',
                            groupValue: selectedGender,
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      "Enter Your Home Address",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 11),
                    TextFormField(
                      controller: apartmentController,
                      decoration: InputDecoration(
                        labelText: 'Appartment',
                        prefixIcon: Icon(Icons.apartment),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? "Please enter Apartment" : null,
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: landmarkController,
                      decoration: InputDecoration(
                        labelText: 'Landmark',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? "Please enter Landmark" : null,
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: areaController,
                      decoration: InputDecoration(
                        labelText: 'Area',
                        prefixIcon: Icon(Icons.map),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? "Please enter Area" : null,
                    ),
                    SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      value: selectedCity,
                      decoration: InputDecoration(
                        labelText: 'City',
                        prefixIcon: Icon(Icons.location_city),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      items: cities.map((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCity = newValue;
                        });
                      },
                      validator: (value) =>
                      value == null ? "Please select a city" : null,
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: pincodeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Pincode',
                        helperText: "Enter a valid 6-digit Pincode",
                        prefixIcon: Icon(Icons.pin),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter Pincode";
                        }
                        if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                          return "Pincode must be exactly 6 digits";
                        }
                        return null; // Validation passed
                      },
                    ),
                    SizedBox(height: 20.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // If all fields pass validation, call API
                            registerPatient();
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
                          'Sign Up',
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/patient/login');
                      },
                      child: Center(
                        child: Text(
                          "Already have an account? Login",
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: 16.0,
                            decoration: TextDecoration.underline,
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