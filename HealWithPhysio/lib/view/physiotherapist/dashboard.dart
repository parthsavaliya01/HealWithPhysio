import 'package:flutter/material.dart';
import 'package:heal_with_physio/main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreenPhysio extends StatefulWidget {
  final Map userData;
  const DashboardScreenPhysio({super.key, required this.userData});

  @override
  _DashboardScreenPhysioState createState() => _DashboardScreenPhysioState();
}

class _DashboardScreenPhysioState extends State<DashboardScreenPhysio>
    with RouteAware, WidgetsBindingObserver {
  String physioName = 'Physiotherapist'; // Default name until fetched
  bool isLoading = true;
  int allCount = 0;
  int pendingCount = 0;
  int confirmedCount = 0;
  int rejectedCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add lifecycle observer
    fetchPhysioName().then((_) {
      fetchAppointmentCounts(); // Fetch counts after physioName is set
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      MyApp.routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Called when this screen is revisited (e.g., after popping another screen)
    fetchPhysioName().then((_) {
      fetchAppointmentCounts(); // Refresh counts
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh counts when the app resumes
      fetchPhysioName().then((_) {
        fetchAppointmentCounts();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove lifecycle observer
    MyApp.routeObserver.unsubscribe(this); // Unsubscribe from route observer
    super.dispose();
  }

  Future<void> fetchPhysioName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';
      if (username.isEmpty) {
        _showSnackBar(context, 'Username not found in preferences', Colors.red);
        return;
      }

      final response = await http.post(
        Uri.parse('http://${MyApp.ip}/capstone/get_physio_name.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['name'] != null) {
          setState(() {
            physioName = data['name'];
          });
        } else {
          _showSnackBar(context, data['message'] ?? 'Failed to fetch name', Colors.red);
        }
      } else {
        _showSnackBar(context, 'Failed to fetch physiotherapist name', Colors.red);
      }
    } catch (e) {
      _showSnackBar(context, 'Error fetching name: $e', Colors.red);
    }
  }

  Future<void> fetchAppointmentCounts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://${MyApp.ip}/capstone/get_appointment_counts.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'physio_name': physioName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            allCount = data['counts']['all'] ?? 0;
            pendingCount = data['counts']['pending'] ?? 0;
            confirmedCount = data['counts']['confirmed'] ?? 0;
            rejectedCount = data['counts']['rejected'] ?? 0;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          _showSnackBar(context, data['message'], Colors.red);
        }
      } else {
        setState(() {
          isLoading = false;
        });
        _showSnackBar(context, 'Failed to fetch appointment counts', Colors.red);
      }
    } catch (e) {
      _showSnackBar(context, 'Error: $e', Colors.red);
      setState(() {
        isLoading = false;
      });
    }
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
                Navigator.pop(context); // Close dialog
                await deleteAccount(context, username, password);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteAccount(BuildContext context, String username, String password) async {
    var url = Uri.parse("http://${MyApp.ip}/capstone/physiotherapiest_delete.php");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "username": username,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print("📦 Decoded JSON: $data");

          if (data["status"] == "success") {
            _showSnackBar(context, "Account deleted successfully", Colors.green);

            // Clear stored user data
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.clear();

            // Navigate to login screen
            Navigator.pushNamed(context, '/'); //role page redirect karav vu hoi to khali / lakhva nu
          } else {
            _showSnackBar(context, data["message"], Colors.red);
          }
        } catch (e) {
          print("⚠️ JSON Decode Error: ${e.toString()}");
          _showSnackBar(context, "Invalid response format", Colors.red);
        }
      } else {
        _showSnackBar(context, "Server error: ${response.statusCode}", Colors.red);
      }
    } catch (e) {
      _showSnackBar(context, "Network error occurred", Colors.red);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HealWithPhysio',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo[900],
        iconTheme: IconThemeData(color: Colors.white), // Ensures back button is white
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo[900],
              ),
              child: SizedBox(
                height: 100,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 110,
                            height: 100,
                            child: Image.asset('assets/images/logo.png'),
                          ),
                          Text(
                            '${widget.userData['username']}',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                            ),
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
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle, color: Colors.indigo[900]),
              title: Text('Manage Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/physio/manageProfile');
              },
            ),
            ListTile(
              leading: Icon(Icons.star_rate, color: Colors.indigo[900]),
              title: Text('View Rating & Feedback'),
              onTap: () {
                Navigator.pushNamed(context, '/physio/view_rating_feedback');
              },
            ),
            ListTile(
              leading: Icon(Icons.info, color: Colors.indigo[900]),
              title: Text('About Us'),
              onTap: () {
                Navigator.pushNamed(context, '/physio/aboutUs');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.indigo[900]),
              title: Text('Log Out'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('islogin', false);
                await prefs.remove('username');
                await prefs.remove('password');
                Navigator.pushReplacementNamed(context, '/physio/logout_success');
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.indigo[900]),
              title: Text('Delete Account'),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? username = prefs.getString('username');
                String? password = prefs.getString('password');

                // print("In if else: Username: $username, Password: $password");
                _showDeleteConfirmationDialog(context, username!, password!);
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
                'Welcome to HealWithPhysio, ${widget.userData['username']}',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Smart Scheduling for Smarter Physiotherapy!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20.0),
              // Image slider
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

              SizedBox(height: 30.0),
              // Appointments Section
              Center(
                child: Text(
                  "Manage All your Appointments",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo[900]),
                ),
              ),
              SizedBox(height: 30),
              // Row of appointment status cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _buildStatusCard(
                      title: "All",
                      count: allCount.toString(),
                      color: Colors.blue,
                      icon: Icons.list_alt,
                      onTap: () {
                        Navigator.pushNamed(context, '/physio/allAppointments');
                      },
                    ),
                  ),
                  SizedBox(width: 20,),
                  Expanded(
                    child: _buildStatusCard(
                      title: "Pending",
                      count: pendingCount.toString(),
                      color: Colors.orange,
                      icon: Icons.pending_actions,
                      onTap: () {
                        Navigator.pushNamed(context, '/physio/pendingAppointments');
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _buildStatusCard(
                      title: "Confirmed",
                      count: confirmedCount.toString(),
                      color: Colors.green,
                      icon: Icons.check_circle,
                      onTap: () {
                        Navigator.pushNamed(context, '/physio/confirmedAppointments');
                      },
                    ),
                  ),
                  SizedBox(width: 20,),
                  Expanded(
                    child: _buildStatusCard(
                      title: "Rejected",
                      count: rejectedCount.toString(),
                      color: Colors.red,
                      icon: Icons.cancel,
                      onTap: () {
                        Navigator.pushNamed(context, '/physio/rejectedAppointments');
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for appointment status cards
  Widget _buildStatusCard({
    required String title,
    required String count,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 150, // Adjust width for responsiveness
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 10),
            Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            SizedBox(height: 5),
            Text(title, style: TextStyle(fontSize: 16, color: Colors.black87)),
            SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
}