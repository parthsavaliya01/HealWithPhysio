import 'dart:convert';
import 'dart:typed_data';
import 'package:heal_with_physio/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ManageProfileScreenPhysio extends StatefulWidget {
  const ManageProfileScreenPhysio({super.key});

  @override
  _ManageProfileScreenPhysioState createState() => _ManageProfileScreenPhysioState();
}

class _ManageProfileScreenPhysioState extends State<ManageProfileScreenPhysio> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController clinicStartTimeController = TextEditingController();
  final TextEditingController clinicEndTimeController = TextEditingController();
  // final TextEditingController homeStartTimeController = TextEditingController();
  // final TextEditingController homeEndTimeController = TextEditing Controller();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();

  String gender = 'Male';
  File? profilePhoto;
  File? qualificationPhoto;
  XFile? profileXFile;
  XFile? qualificationXFile;
  Uint8List? profileBytes;
  Uint8List? qualificationBytes;
  String? profilePhotoUrl;
  String? qualificationPhotoUrl;

  TimeOfDay? clinicStartTime;
  TimeOfDay? clinicEndTime;
  // TimeOfDay? homeStartTime;
  // TimeOfDay? homeEndTime;

  String? selectedCity;
  String? selectedSpecialization;

  // Dropdown options
  final List<String> cityOptions = ['Ahmedabad', 'Surat', 'Vadodara', 'Gandhinagar', 'Rajkot'];
  final List<String> specializationOptions = ['Orthopedic', 'Neurology', 'Pediatric', 'Sports', 'Musculoskeletal'];

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchDefaultData();
  }

  Future<void> _fetchDefaultData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? username = prefs.getString('username');
      final String? password = prefs.getString('password');

      if (username == null || password == null) {
        if (mounted) _showSnackBar(context, 'Please log in first', Colors.red);
        return;
      }

      final String apiUrl = 'http://${MyApp.ip}/capstone/physiotherapist_fetch.php';
      print('Fetching from: $apiUrl');
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'username': username,
          'password': password,
        },
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out');
      });

      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['message'] == 'Data fetched successfully') {
        final data = jsonResponse['data'];
        if (mounted) {
          setState(() {
            nameController.text = data['name'] ?? '';
            emailController.text = data['email'] ?? '';
            contactController.text = data['contact_no']?.toString() ?? '';
            apartmentController.text = data['appartment'] ?? '';
            pincodeController.text = data['pincode']?.toString() ?? '';
            specializationController.text = data['specialization'] ?? '';
            qualificationController.text = data['qualification'] ?? '';
            experienceController.text = data['experience']?.toString() ?? '';
            gender = data['gender'] ?? 'Male';
            landmarkController.text = data['landmark'] ?? '';
            areaController.text = data['area'] ?? '';
            cityController.text = data['city'] ?? '';
            // Set dropdown values
            selectedCity = cityOptions.contains(data['city']) ? data['city'] : null;
            selectedSpecialization = specializationOptions.contains(data['specialization']) ? data['specialization'] : null;

            if (data['clinic_start_time'] != null) {
              clinicStartTime = _parseTime(data['clinic_start_time']);
              clinicStartTimeController.text = clinicStartTime?.format(context) ?? '';
            }
            if (data['clinic_end_time'] != null) {
              clinicEndTime = _parseTime(data['clinic_end_time']);
              clinicEndTimeController.text = clinicEndTime?.format(context) ?? '';
            }
           

            if (data['photo']?.isNotEmpty ?? false) {
              profilePhotoUrl = 'http://${MyApp.ip}/capstone/${data['photo']}';
              print('Profile photo URL: $profilePhotoUrl');
              _fetchImageBytes(profilePhotoUrl!, 'profile');
            }

            if (data['qualification_photo']?.isNotEmpty ?? false) {
              qualificationPhotoUrl = 'http://${MyApp.ip}/capstone/${data['qualification_photo']}';
              print('Qualification photo URL: $qualificationPhotoUrl');
              _fetchImageBytes(qualificationPhotoUrl!, 'qualification');
            }
          });
        }
      } else {
        if (mounted) _showSnackBar(context, jsonResponse['error'] ?? 'Failed to fetch data', Colors.red);
      }
    } catch (e) {
      if (mounted) _showSnackBar(context, 'Error fetching data: $e', Colors.red);
      print('Fetch error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchImageBytes(String url, String type) async {
    if (!mounted) return;
    try {
      final response = await http.get(Uri.parse(url));
      // print('Image fetch status for $type: ${response.statusCode}');
      // print('Image fetch headers for $type: ${response.headers}');
      // print('Image fetch body length for $type: ${response.bodyBytes.length} bytes');
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        print('Content-Type for $type: $contentType');
        if (contentType?.startsWith('image/') ?? false) {
          if (mounted) {
            setState(() {
              if (type == 'profile') {
                profileBytes = response.bodyBytes;
              } else {
                qualificationBytes = response.bodyBytes;
              }
            });
          }
        } else {
          print('Invalid content type for $type. Body: ${response.body.substring(0, response.body.length < 100 ? response.body.length : 100)}');
        }
      } else {
        print('Failed to fetch image for $type. Response: ${response.body}');
      }
    } catch (e) {
      print('Error fetching image for $type: $e');
    }
  }

  Future<void> _submitUpdateData() async {
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? username = prefs.getString('username');
      final String? password = prefs.getString('password');

      if (username == null || password == null) {
        if (mounted) _showSnackBar(context, 'Please log in first', Colors.red);
        return;
      }

      final String apiUrl = 'http://${MyApp.ip}/capstone/physiotherapiest_update.php'; // Fixed typo
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.fields.addAll({
        'username': username,
        'password': password,
        'name': nameController.text,
        'email': emailController.text,
        'contact_no': contactController.text,
        'gender': gender,
        'appartment': apartmentController.text,
        'landmark': landmarkController.text,
        'area': areaController.text,
        'city': selectedCity ?? '', // Use selectedCity instead of cityController.text
        'pincode': pincodeController.text,
        'clinic_start_time': _formatTime(clinicStartTime),
        'clinic_end_time': _formatTime(clinicEndTime),
        // 'home_visit_start_time': _formatTime(homeStartTime),
        // 'home_visit_end_time': _formatTime(homeEndTime),
        'specialization': selectedSpecialization ?? '', // Use selectedSpecialization instead of specializationController.text
        'qualification': qualificationController.text,
        'experience': experienceController.text,
      });

      // Handle profile photo upload
      if (kIsWeb && profileXFile != null && profileBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'photo',
          profileBytes!,
          filename: profileXFile!.name, // Use original filename
        ));
      } else if (!kIsWeb && profilePhoto != null && profilePhoto!.existsSync()) {
        request.files.add(await http.MultipartFile.fromPath('photo', profilePhoto!.path));
      }

      // Handle qualification photo upload
      if (kIsWeb && qualificationXFile != null && qualificationBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'qualification_photo',
          qualificationBytes!,
          filename: qualificationXFile!.name, // Use original filename
        ));
      } else if (!kIsWeb && qualificationPhoto != null && qualificationPhoto!.existsSync()) {
        request.files.add(await http.MultipartFile.fromPath('qualification_photo', qualificationPhoto!.path));
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      print('Update response: $responseData');

      final jsonResponse = jsonDecode(responseData);
      if (response.statusCode == 200 && jsonResponse['message'] == 'Update successful') {
        if (mounted) {
          _showSnackBar(context, 'Update successful!', Colors.green);
          await _fetchDefaultData();
        }
      } else {
        if (mounted) _showSnackBar(context, jsonResponse['error'] ?? 'Update failed', Colors.red);
      }
    } catch (e) {
      if (mounted) _showSnackBar(context, 'Error updating data: $e', Colors.red);
      print('Update error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectTime(BuildContext context, {required String timeType}) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && mounted) {
      setState(() {
        switch (timeType) {
          case 'clinicStart':
            clinicStartTime = picked;
            clinicStartTimeController.text = picked.format(context);
            break;
          case 'clinicEnd':
            clinicEndTime = picked;
            clinicEndTimeController.text = picked.format(context);
            break;
          
        }
      });
    }
  }

  Future<void> _pickProfilePhoto() async {
    if (!mounted) return;
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() {
          if (kIsWeb) {
            profileXFile = image;
            image.readAsBytes().then((bytes) {
              if (mounted) {
                setState(() {
                  profileBytes = bytes;
                });
              }
            });
          } else {
            profilePhoto = File(image.path);
            profileBytes = null;
          }
          profilePhotoUrl = null;
        });
      }
    } catch (e) {
      if (mounted) _showSnackBar(context, 'Error picking profile photo: $e', Colors.red);
      print('Profile photo pick error: $e');
    }
  }

  Future<void> _pickQualificationPhoto() async {
    if (!mounted) return;
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() {
          if (kIsWeb) {
            qualificationXFile = image;
            image.readAsBytes().then((bytes) {
              if (mounted) {
                setState(() {
                  qualificationBytes = bytes;
                });
              }
            });
          } else {
            qualificationPhoto = File(image.path);
            qualificationBytes = null;
          }
          qualificationPhotoUrl = null;
        });
      }
    } catch (e) {
      if (mounted) _showSnackBar(context, 'Error picking qualification photo: $e', Colors.red);
      print('Qualification photo pick error: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  String _formatTime(TimeOfDay? time) => time == null ? '' : '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  TimeOfDay? _parseTime(String time) {
    try {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.lightBlue[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Update Your Profile',
                        style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.indigo[900]),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Text("Profile Photo", style: TextStyle(fontSize: 15)),
                    GestureDetector(
                      onTap: _pickProfilePhoto,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
                        child: ClipOval(
                          child: profileBytes != null
                              ? Image.memory(
                            profileBytes!,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            errorBuilder: (context, error, stackTrace) {
                              print('Memory image error for profile: $error');
                              return const Icon(Icons.image_not_supported, size: 40, color: Colors.grey);
                            },
                          )
                              : (profilePhotoUrl != null
                              ? CachedNetworkImage(
                            imageUrl: profilePhotoUrl!,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) {
                              print('CachedNetworkImage error for profile: $error');
                              return const Icon(Icons.image_not_supported, size: 40, color: Colors.grey);
                            },
                          )
                              : const Icon(Icons.add_a_photo, size: 40, color: Colors.indigo)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
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
                    const SizedBox(height: 16.0),
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
                    const SizedBox(height: 16.0),
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
                    const SizedBox(height: 16.0),
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
                    const SizedBox(height: 16.0),
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
                    const SizedBox(height: 16.0),
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
                    const SizedBox(height: 16.0),
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
                    const SizedBox(height: 16.0),
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
                    const SizedBox(height: 16.0),
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
                    const SizedBox(height: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Timings", style: TextStyle(fontSize: 15)),
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectTime(context, timeType: 'clinicStart'),
                                child: InputDecorator(
                                  decoration: InputDecoration(labelText: 'Start Time', prefixIcon: const Icon(Icons.access_time), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0))),
                                  child: Text(clinicStartTime?.format(context) ?? 'Select Start Time'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectTime(context, timeType: 'clinicEnd'),
                                child: InputDecorator(
                                  decoration: InputDecoration(labelText: 'End Time', prefixIcon: const Icon(Icons.access_time), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0))),
                                  child: Text(clinicEndTime?.format(context) ?? 'Select End Time'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    
                    const SizedBox(height: 16.0),
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
                    const SizedBox(height: 16.0),
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
                    const SizedBox(height: 16.0),
                    const Text("Qualification Photo", style: TextStyle(fontSize: 15)),
                    GestureDetector(
                      onTap: _pickQualificationPhoto,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
                        child: ClipOval(
                          child: qualificationBytes != null
                              ? Image.memory(
                            qualificationBytes!,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            errorBuilder: (context, error, stackTrace) {
                              print('Memory image error for qualification: $error');
                              return const Icon(Icons.image_not_supported, size: 40, color: Colors.grey);
                            },
                          )
                              : (qualificationPhotoUrl != null
                              ? CachedNetworkImage(
                            imageUrl: qualificationPhotoUrl!,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) {
                              print('CachedNetworkImage error for qualification: $error');
                              return const Icon(Icons.image_not_supported, size: 40, color: Colors.grey);
                            },
                          )
                              : const Icon(Icons.add_a_photo, size: 40, color: Colors.indigo)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
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
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitUpdateData,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: Colors.indigo[900],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Update Profile', style: TextStyle(fontSize: 18.0, color: Colors.white)),
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