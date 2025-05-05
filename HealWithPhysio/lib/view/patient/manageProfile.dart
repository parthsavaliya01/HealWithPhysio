import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:heal_with_physio/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ManageProfile extends StatefulWidget {
  // No parameters needed anymore
  const ManageProfile({super.key});

  @override
  _ManageProfileState createState() => _ManageProfileState();
}

class _ManageProfileState extends State<ManageProfile> {
  String? selectedCity; // Variable for dropdown city selection

  // List of cities for dropdown
  final List<String> cities = [
    'Ahmedabad',
    'Surat',
    'Vadodara',
    'Gandhinagar',
    'Rajkot'
  ];
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  TextEditingController unameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String? gender;
  TextEditingController apartmentController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  // final TextEditingController passwordController = TextEditingController();
  // final TextEditingController npasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

Future<void> fetchProfileData() async {
  final prefs = await SharedPreferences.getInstance();
  final String? username = prefs.getString('username');
  final String? password = prefs.getString('password');

  if (username == null || password == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please login first')),
    );
    Navigator.pushNamed(context, '/patient/login');
    return;
  }

  try {
    final uri = Uri.parse('http://${MyApp.ip}/capstone/get_patient.php');
    // print('Request URL: $uri');
    // print('Request Body: ${json.encode({'username': username, 'password': password})}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    ).timeout(Duration(seconds: 15));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final data = responseData['data'];
      setState(() {
        unameController.text = data['username'] ?? '';
        nameController.text = data['name'] ?? '';       
        contactController.text = (data['contact_no'] ?? '').toString();
        emailController.text = data['email'] ?? '';
        gender = data['gender'] ?? '';
        apartmentController.text = data['appartment'] ?? '';
        landmarkController.text = data['landmark'] ?? '';
        areaController.text = data['area'] ?? '';
        cityController.text = data['city'] ?? '';
        selectedCity = data['city'] != null && cities.contains(data['city']) ? data['city'] : null; // Set initial dropdown value
        pincodeController.text = (data['pincode'] ?? '').toString();
      });
    } else if (response.statusCode == 401) {
      _showSnackBar(context, 'Invalid credentials, please login again', Colors.red);
      
      Navigator.pushNamed(context, '/patient/login');
    } else {
      _showSnackBar(context, 'Failed: ${response.statusCode} - ${response.body}', Colors.red);
      
    }
  } catch (e) {
    _showSnackBar(context, 'Error: $e', Colors.red);
  }
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

Future<void> updateProfile() async {
  if (_formKey.currentState!.validate()) {
    final prefs = await SharedPreferences.getInstance();
    final String? username = prefs.getString('username');

    try {
      final uri = Uri.parse('http://${MyApp.ip}/capstone/patient_update.php');
      final requestBody = json.encode({
        'username': unameController.text,
        'name': nameController.text,
        'contact_no': contactController.text,
        'email': emailController.text,
        'gender': gender ?? '',
        'appartment': apartmentController.text,
        'landmark': landmarkController.text,
        'area': areaController.text,
        'city': selectedCity ?? '', // Use selectedCity instead of cityController.text
        'pincode': pincodeController.text,
      });
      // print('Update URL: $uri');
      // print('Request Body: $requestBody');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      ).timeout(Duration(seconds: 15));

      final responseData = json.decode(response.body);
      _showSnackBar(context, responseData['message'], Colors.green);
      
   
      if (response.statusCode == 200) {
        await fetchProfileData(); // Refresh UI
      } else if (response.statusCode == 401) {
        Navigator.pushNamed(context, '/patient/login');
      } else {
        _showSnackBar(context, 'Update failed with status: ${response.statusCode}', Colors.red);
      }
    } catch (e) {
      // print('Error: $e');
      // print('Stack trace: $stackTrace');
      _showSnackBar(context, 'Error updating profile: $e', Colors.red);
      
    }
  }
}

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(  // Added Form widget
          key: _formKey,  // Assigned form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Your Profile',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
              
              SizedBox(height: 20.0),
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
              SizedBox(height: 20.0),
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
              SizedBox(height: 20.0),
              Text(
                'Gender',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.indigo[900],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Male'),
                      value: 'Male',
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('Female'),
                      value: 'Female',
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
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
              SizedBox(height: 20.0),
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
              SizedBox(height: 20.0),
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
              SizedBox(height: 20.0),
              // TextFormField(
              //   controller: cityController,
              //   decoration: InputDecoration(
              //     labelText: 'City',
              //     prefixIcon: Icon(Icons.location_city),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12.0),
              //     ),
              //   ),
              //   validator: (value) =>
              //   value!.isEmpty ? "Please enter City" : null,
              // ),
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
              SizedBox(height: 20.0),
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
              Center(
                child: ElevatedButton(
                  onPressed: updateProfile, // Call updateProfile
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Update Profile',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    unameController.dispose();
    nameController.dispose();
    contactController.dispose();
    emailController.dispose();
    // passwordController.dispose();
    // npasswordController.dispose();
    apartmentController.dispose();
    landmarkController.dispose();
    areaController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    super.dispose();
  }
}