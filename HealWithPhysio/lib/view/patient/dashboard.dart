import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heal_with_physio/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class DashboardScreen extends StatefulWidget {
  final Map userData;
  const DashboardScreen({super.key, required this.userData});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> physiotherapists = [];
  bool isLoading = false;
  String? selectedGender;
  String? selectedLocation;
  String? selectedSpeciality;
  double? minRating;
  int? minExperience;
  String? selectedCity;

  @override
  void initState() {
    super.initState();
    fetchPhysiotherapists();
  }

  Future<void> fetchPhysiotherapists() async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse("http://${MyApp.ip}/capstone/physiotherapiest_filter.php");

    try {
      final response = await http.get(url).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == "success") {
          setState(() {
            physiotherapists = data["data"];
            isLoading = false;
          });
        } else {
          _showSnackBar(context, data["message"] ?? "Unknown error", Colors.red);
          setState(() {
            isLoading = false;
          });
        }
      } else {
        _showSnackBar(context, "Server error: ${response.statusCode}", Colors.red);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar(context, "Network error occurred: $e", Colors.red);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchFilteredPhysiotherapists() async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse("http://${MyApp.ip}/capstone/physiotherapiest_filter.php");
    Map<String, String> queryParams = {};
    if (selectedGender != null) queryParams['gender'] = selectedGender!;
    if (selectedLocation != null) queryParams['location'] = selectedLocation!;
    if (selectedSpeciality != null) queryParams['speciality'] = selectedSpeciality!;
    if (minRating != null) queryParams['min_rating'] = minRating.toString();
    if (minExperience != null) queryParams['min_experience'] = minExperience.toString();
    if (selectedCity != null) queryParams['city'] = selectedCity!;
    
    url = url.replace(queryParameters: queryParams);

    try {
      final response = await http.get(url).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == "success") {
          setState(() {
            physiotherapists = data["data"];
            isLoading = false;
          });
        } else {
          _showSnackBar(context, data["message"] ?? "Unknown error", Colors.red);
          setState(() {
            isLoading = false;
          });
        }
      } else {
        _showSnackBar(context, "Server error: ${response.statusCode}", Colors.red);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar(context, "Network error occurred: $e", Colors.red);
      setState(() {
        isLoading = false;
      });
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

  void _showDeleteConfirmationDialog(
    BuildContext context, String username, String password) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Delete Account"),
        content: Text("Are you sure you want to delete your account?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await deleteAccount(context, username, password);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

Future<void> deleteAccount(
    BuildContext context, String username, String password) async {
  var url = Uri.parse("http://${MyApp.ip}/capstone/patient_delete.php");

  try {
    final response = await http.post(url, body: {
      "username": username,
      "password": password,
    });

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        if (data["status"] == "success") {
          _showSnackBar(context, "Account deleted successfully", Colors.green);

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          Navigator.pushNamed(context, '/');
        } else {
          _showSnackBar(context, data["message"], Colors.red);
        }
      } catch (e) {
        _showSnackBar(context, "Invalid response format", Colors.red);
      }
    } else {
      _showSnackBar(
          context, "Server error: ${response.statusCode}", Colors.red);
    }
  } catch (e) {
    _showSnackBar(context, "Network error occurred", Colors.red);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HealWithPhysio', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo[900]),
              child: SizedBox(
                height: 100,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 95,
                            height: 100,
                            child: Image.asset('assets/images/logo.png'),
                          ),
                          Text(
                            '${widget.userData['username'] ?? 'HealWithPhysio'}',
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.indigo[900]),
              title: Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.account_circle, color: Colors.indigo[900]),
              title: Text('Manage Profile'),
              onTap: () => Navigator.pushNamed(context, '/patient/manageProfile'),
            ),
            ListTile(
              leading: Icon(Icons.history, color: Colors.indigo[900]),
              title: Text('View Appointments'),
              onTap: () => Navigator.pushNamed(context, '/patient/pastAppointment'),
            ),
            ListTile(
              leading: Icon(Icons.info, color: Colors.indigo[900]),
              title: Text('About Us'),
              onTap: () => Navigator.pushNamed(context, '/patient/aboutUs'),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.indigo[900]),
              title: Text('Log Out'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('islogin', false);
                await prefs.remove('username');
                await prefs.remove('password');
                Navigator.pushReplacementNamed(context, '/patient/logout_success');
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.indigo[900]),
              title: Text('Delete Account'),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? username = prefs.getString('username');
                String? password = prefs.getString('password');

                if (password != null) {
                  _showDeleteConfirmationDialog(context, username!, password);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: No user logged in",
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to HealWithPhysio ${widget.userData['username'] ?? ''}',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Personalized Physiotherapy – Anytime, Anywhere!',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 20.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for doctors or specialities',
                    prefixIcon: Icon(Icons.search, color: Colors.indigo[900]),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.filter_list, color: Colors.indigo[900]),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                          ),
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (BuildContext context, StateSetter setModalState) {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: IconButton(
                                            icon: Icon(Icons.close, color: Colors.indigo[900]),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                        ),
                                        Text(
                                          'Filter Options',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo[900],
                                          ),
                                        ),
                                        SizedBox(height: 16.0),
                                        ListTile(
                                          leading: Icon(Icons.person, color: Colors.indigo[900]),
                                          title: Text('Gender'),
                                          trailing: SizedBox(
                                            width: 145,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: selectedGender,
                                                isExpanded: true,
                                                dropdownColor: Colors.indigo[100],
                                                items: ['Male', 'Female'].map((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value, style: TextStyle(fontSize: 16)),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setModalState(() {
                                                    selectedGender = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.medical_services, color: Colors.indigo[900]),
                                          title: Text('Speciality'),
                                          trailing: SizedBox(
                                            width: 145,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: selectedSpeciality,
                                                isExpanded: true,
                                                dropdownColor: Colors.indigo[100],
                                                items: ['Orthopedic', 'Neurology', 'Pediatric', 'Sports', 'Musculoskeletal']
                                                    .map((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value, style: TextStyle(fontSize: 16)),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setModalState(() {
                                                    selectedSpeciality = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.star_rate_rounded, color: Colors.indigo[900]),
                                          title: Text('Minimum Rating'),
                                          trailing: SizedBox(
                                            width: 145,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<double>(
                                                value: minRating,
                                                isExpanded: true,
                                                dropdownColor: Colors.indigo[100],
                                                items: [1.0, 2.0, 3.0, 4.0, 5.0].map((double value) {
                                                  return DropdownMenuItem<double>(
                                                    value: value,
                                                    child: Text(value.toString(), style: TextStyle(fontSize: 16)),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setModalState(() {
                                                    minRating = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.history, color: Colors.indigo[900]),
                                          title: Text('Minimum Experience'),
                                          trailing: SizedBox(
                                            width: 145,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<int>(
                                                value: minExperience,
                                                isExpanded: true,
                                                dropdownColor: Colors.indigo[100],
                                                items: [1, 3, 5, 10].map((int value) {
                                                  return DropdownMenuItem<int>(
                                                    value: value,
                                                    child: Text('$value years', style: TextStyle(fontSize: 16)),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setModalState(() {
                                                    minExperience = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.location_city, color: Colors.indigo[900]),
                                          title: Text('City'),
                                          trailing: SizedBox(
                                            width: 145,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: selectedCity,
                                                isExpanded: true,
                                                dropdownColor: Colors.indigo[100],
                                                items: ['Ahmedabad', 'Surat', 'Vadodara', 'Gandhinagar', 'Rajkot'].map((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value, style: TextStyle(fontSize: 16)),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setModalState(() {
                                                    selectedCity = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    fetchFilteredPhysiotherapists();
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Apply Filters'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.indigo[900],
                                                  foregroundColor: Colors.white,
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  setModalState(() {
                                                    selectedGender = null;
                                                    selectedSpeciality = null;
                                                    minRating = null;
                                                    minExperience = null;
                                                    selectedCity = null;
                                                  });
                                                  setState(() {
                                                    fetchPhysiotherapists();
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Clear Filters', style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              SizedBox(
                height: 200.0,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4.0,
                            spreadRadius: 1.0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: PageView(
                          children: [
                            Image.asset('assets/images/slider1.jpg', fit: BoxFit.cover),
                            Image.asset('assets/images/slider2.jpeg', fit: BoxFit.cover),
                            Image.asset('assets/images/slider.jpeg', fit: BoxFit.cover),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Our Best Physiotherapists',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
              SizedBox(height: 20.0),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : physiotherapists.isEmpty
                      ? Center(child: Text('No physiotherapists found'))
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: physiotherapists.length,
                          itemBuilder: (context, index) {
                            final physio = physiotherapists[index];
                            String imageUrl = physio['photo'] != null && physio['photo'].isNotEmpty
                                ? "http://${MyApp.ip}/capstone/${physio['photo']}"
                                : 'assets/images/d1.jpg';

                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/patient/doctorDetail',
                                  arguments: {
                                    'name': (physio['name'] ?? 'Unknown').toString(),
                                    'specialization': (physio['specialization'] ?? 'Not specified').toString(),
                                    'image': imageUrl,
                                    'email': (physio['email'] ?? 'Not available').toString(),
                                    'gender': (physio['gender'] ?? 'Not specified').toString(),
                                    'qualification': (physio['qualification'] ?? 'Not specified').toString(),
                                    'experience': (physio['experience'] ?? '0').toString(),
                                    'contactNo': (physio['contact_no'] ?? 'Not available').toString(),
                                    'clinicAddress': (physio['appartment'] ?? 'Not available').toString(),
                                    'clinicStartTime': (physio['clinic_start_time'] ?? 'N/A').toString(),
                                    'clinicEndTime': (physio['clinic_end_time'] ?? 'N/A').toString(),
                                    'appartment': (physio['appartment'] ?? 'Not available').toString(),
                                    'landmark': (physio['landmark'] ?? 'Not available').toString(),
                                    'area': (physio['area'] ?? 'Not available').toString(),
                                    'city': (physio['city'] ?? 'Not available').toString(),
                                    'pincode': (physio['pincode'] ?? 'Not available').toString(),
                                    'average_rating': (physio['average_rating'] ?? '3.0').toString(),
                                  },
                                );
                              },
                              child: DoctorProfile(
                                name: physio['name'] ?? 'Unknown',
                                specialization: physio['specialization'] ?? 'Not specified',
                                image: imageUrl,
                                rating: double.tryParse(physio['average_rating']?.toString() ?? '3.0') ?? 0.0,
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

class DoctorProfile extends StatelessWidget {
  final String name;
  final String specialization;
  final String image;
  final double rating;

  const DoctorProfile({
    super.key,
    required this.name,
    required this.specialization,
    required this.image,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: Container(
                height: 80.0,
                width: 80.0,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: image.contains('http')
                    ? FadeInImage(
                        placeholder: AssetImage('assets/images/d1.jpg'),
                        image: NetworkImage(image),
                        height: 80.0,
                        width: 80.0,
                        fit: BoxFit.cover,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/images/d1.jpg', height: 80.0, width: 80.0, fit: BoxFit.cover);
                        },
                        fadeInDuration: Duration(milliseconds: 300),
                      )
                    : Image.asset('assets/images/d1.jpg', height: 80.0, width: 80.0, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.indigo[900]),
            ),
            SizedBox(height: 5.0),
            Text(
              specialization,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.0, color: Colors.indigo[600]),
            ),
            SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.orange, size: 16.0),
                SizedBox(width: 4.0),
                Text(rating.toStringAsFixed(1), style: TextStyle(fontSize: 14.0, color: Colors.indigo[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}