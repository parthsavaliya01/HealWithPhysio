import 'package:flutter/foundation.dart' show kIsWeb; // Add this for platform detection
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heal_with_physio/main.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailValidationExample extends StatefulWidget {
  const EmailValidationExample({super.key});

  @override
  _SignupScreenPhysioState createState() => _SignupScreenPhysioState();
}

class SignupScreenPhysio extends StatefulWidget {
  const SignupScreenPhysio({super.key});

  @override
  _SignupScreenPhysioState createState() => _SignupScreenPhysioState();
}

class _SignupScreenPhysioState extends State<SignupScreenPhysio> {
  final TextEditingController unameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController clinicStartTimeController = TextEditingController();
  final TextEditingController clinicEndTimeController = TextEditingController();
  // final TextEditingController homeStartTimeController = TextEditingController();
  // final TextEditingController homeEndTimeController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();

  String gender = 'Male'; // Default gender selection
  File? profilePhoto; // Used for mobile
  File? qualificationPhoto; // Used for mobile
  XFile? profileXFile; // Used for web
  XFile? qualificationXFile; // Used for web
  Uint8List? profileBytes; // Web image bytes
  Uint8List? qualificationBytes; // Web image bytes

  TimeOfDay? clinicStartTime;
  TimeOfDay? clinicEndTime;
  // TimeOfDay? homeStartTime;
  // TimeOfDay? homeEndTime;

  final ImagePicker _picker = ImagePicker();
  bool _isObscured = true;
  bool _isLoading = false;

  // Add Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Dropdown values
  String? selectedCity;
  String? selectedSpecialization;

  // Dropdown options
  final List<String> cityOptions = ['Ahmedabad', 'Surat', 'Vadodara', 'Gandhinagar', 'Rajkot'];
  final List<String> specializationOptions = ['Orthopedic', 'Neurology', 'Pediatric', 'Sports', 'Musculoskeletal'];

  Future<void> _selectTime(BuildContext context, {required String timeType}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child ?? Container(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        switch (timeType) {
          case 'clinicStart':
            clinicStartTime = picked;
            break;
          case 'clinicEnd':
            clinicEndTime = picked;
            break;
        }
      });
    }
  }

  Future<void> _pickProfilePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (kIsWeb) {
          profileXFile = image;
          image.readAsBytes().then((bytes) {
            setState(() {
              profileBytes = bytes;
            });
          });
        } else {
          profilePhoto = File(image.path);
        }
      });
    }
  }

  Future<void> _pickQualificationPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (kIsWeb) {
          qualificationXFile = image;
          image.readAsBytes().then((bytes) {
            setState(() {
              qualificationBytes = bytes;
            });
          });
        } else {
          qualificationPhoto = File(image.path);
        }
      });
    }
  }

  Future<void> _submitSignupData() async {
    // Check if form is valid before proceeding
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String apiUrl = 'http://${MyApp.ip}/capstone/physiotherapist_signup.php';

    if (clinicStartTime == null || clinicEndTime == null) {
      _showSnackBar(context, 'Timing Details are Required', Colors.red);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Validate that end times are after start times
    final clinicStartMinutes = clinicStartTime!.hour * 60 + clinicStartTime!.minute;
    final clinicEndMinutes = clinicEndTime!.hour * 60 + clinicEndTime!.minute;
    // final homeStartMinutes = homeStartTime!.hour * 60 + homeStartTime!.minute;
    // final homeEndMinutes = homeEndTime!.hour * 60 + homeEndTime!.minute;

    if (clinicEndMinutes <= clinicStartMinutes) {
      _showSnackBar(context, 'Clinic End time must be after Start Time', Colors.red);
      setState(() {
        _isLoading = false;
      });
      return;
    }
    // if (homeEndMinutes <= homeStartMinutes) {
    //   _showSnackBar(context, 'Home visit End time must be after Start time', Colors.red);
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   return;
    // }

    // Additional validation for photos
    if ((!kIsWeb && profilePhoto == null) || (kIsWeb && profileXFile == null)) {
      _showSnackBar(context, 'Profile Photo is Required', Colors.red);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if ((!kIsWeb && qualificationPhoto == null) || (kIsWeb && qualificationXFile == null)) {
      _showSnackBar(context, 'Qualification Photo is Required', Colors.red);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.fields['name'] = nameController.text;
      request.fields['username'] = unameController.text;
      request.fields['password'] = passwordController.text;
      request.fields['contact_no'] = contactController.text;
      request.fields['email'] = emailController.text;
      request.fields['gender'] = gender;
      request.fields['appartment'] = apartmentController.text;
      request.fields['landmark'] = landmarkController.text;
      request.fields['area'] = areaController.text;
      request.fields['city'] = selectedCity ?? ''; // Use selectedCity
      request.fields['pincode'] = pincodeController.text;
      request.fields['clinic_start_time'] = _formatTime(clinicStartTime);
      request.fields['clinic_end_time'] = _formatTime(clinicEndTime);
      // request.fields['home_visit_start_time'] = _formatTime(homeStartTime);
      // request.fields['home_visit_end_time'] = _formatTime(homeEndTime);
      request.fields['qualification'] = qualificationController.text;
      request.fields['specialization'] = selectedSpecialization ?? ''; // Use selectedSpecialization
      request.fields['experience'] = experienceController.text;

      if (kIsWeb) {
        if (profileXFile != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'photo',
            await profileXFile!.readAsBytes(),
            filename: profileXFile!.name,
          ));
        }
        if (qualificationXFile != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'qualification_photo',
            await qualificationXFile!.readAsBytes(),
            filename: qualificationXFile!.name,
          ));
        }
      } else {
        if (profilePhoto != null) {
          request.files.add(await http.MultipartFile.fromPath('photo', profilePhoto!.path));
        }
        if (qualificationPhoto != null) {
          request.files.add(await http.MultipartFile.fromPath('qualification_photo', qualificationPhoto!.path));
        }
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      dynamic jsonResponse;
      try {
        jsonResponse = jsonDecode(responseData);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar(context, 'Server returned invalid JSON: $responseData', Colors.red);
        return;
      }

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        if (jsonResponse['message'] != null) {
          _showSnackBar(context, 'Signup successful!', Colors.green);
          Navigator.pushNamed(context, '/physio/login');
        } else if (jsonResponse['error'] != null) {
          _showSnackBar(context, 'Error: ${jsonResponse['error']}', Colors.red);
        } else {
          _showSnackBar(context, 'Unexpected response format', Colors.red);
        }
      } else {
        _showSnackBar(context, 'Server error: ${response.statusCode} - $responseData', Colors.red);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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

  String _formatTime(TimeOfDay? time) {
    if (time == null) return ''; // Handle null case
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute'; // Returns time in "HH:MM" format
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
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
              child: Form( // Added Form widget
                key: _formKey,
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 60.0), // Space for the back button
                        Center(
                          child: Text(
                            'Sign Up for Physiotherapist',
                            style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo[900],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Text("Profile Photo", style: TextStyle(fontSize: 15)),
                        GestureDetector(
                          onTap: _pickProfilePhoto,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: kIsWeb
                                ? (profileBytes != null ? MemoryImage(profileBytes!) : null)
                                : (profilePhoto != null ? FileImage(profilePhoto!) : null),
                            child: (kIsWeb ? profileBytes : profilePhoto) == null
                                ? Icon(Icons.add_a_photo, size: 40, color: Colors.indigo[900])
                                : null,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: unameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a username';
                            }
                            return null;
                          },
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
                        SizedBox(height: 16.0),
                        Text(
                          "Enter Your Clinic Address",
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 11),
                        TextFormField(
                          controller: apartmentController,
                          decoration: InputDecoration(
                            labelText: 'Appartment',
                            prefixIcon: Icon(Icons.apartment),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an Apartment';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: landmarkController,
                          decoration: InputDecoration(
                            labelText: 'Landmark',
                            prefixIcon: Icon(Icons.location_on),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a Landmark';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: areaController,
                          decoration: InputDecoration(
                            labelText: 'Area',
                            prefixIcon: Icon(Icons.map),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an Area';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'City',
                            prefixIcon: Icon(Icons.location_city),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          value: selectedCity,
                          items: cityOptions.map((String city) {
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
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a city';
                            }
                            return null;
                          },
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
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        // Clinic Timings
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Timings", style: TextStyle(fontSize: 15)),
                            SizedBox(height: 16.0),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectTime(context, timeType: 'clinicStart'),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Start Time',
                                        prefixIcon: Icon(Icons.access_time),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                      ),
                                      child: Text(
                                        clinicStartTime?.format(context) ?? 'Select Start Time',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectTime(context, timeType: 'clinicEnd'),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'End Time',
                                        prefixIcon: Icon(Icons.access_time),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                      ),
                                      child: Text(
                                        clinicEndTime?.format(context) ?? 'Select End Time',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                       
                        SizedBox(height: 16.0),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Specialization',
                            prefixIcon: Icon(Icons.star),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          value: selectedSpecialization,
                          items: specializationOptions.map((String specialization) {
                            return DropdownMenuItem<String>(
                              value: specialization,
                              child: Text(specialization),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedSpecialization = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a Specialization';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: qualificationController,
                          decoration: InputDecoration(
                            labelText: 'Qualification',
                            prefixIcon: Icon(Icons.school),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a Qualification';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        Text("Qualification Photo", style: TextStyle(fontSize: 15)),
                        GestureDetector(
                          onTap: _pickQualificationPhoto,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: kIsWeb
                                ? (qualificationBytes != null ? MemoryImage(qualificationBytes!) : null)
                                : (qualificationPhoto != null ? FileImage(qualificationPhoto!) : null),
                            child: (kIsWeb ? qualificationBytes : qualificationPhoto) == null
                                ? Icon(Icons.add_a_photo, size: 40, color: Colors.indigo[900])
                                : null,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: experienceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Experience',
                            helperText: "Enter Experience (in years)",
                            prefixIcon: Icon(Icons.access_time),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter Experience";
                            }
                            if (!RegExp(r'^\d{1,2}$').hasMatch(value)) { // Changed to allow 1-2 digits
                              return "Experience must be a number (1-99 years)";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitSignupData,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              backgroundColor: Colors.indigo[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                              'Sign Up',
                              style: TextStyle(fontSize: 18.0, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/physio/login');
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
                    Positioned(
                      top: 1.0, // Adjust this to move it higher
                      left: 5.0, // Adjust this to move it left
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.indigo[900], size: 30),
                        onPressed: () {
                          Navigator.pop(context);
                        },
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