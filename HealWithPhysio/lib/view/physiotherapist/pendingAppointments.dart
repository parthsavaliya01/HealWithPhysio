import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:heal_with_physio/main.dart';
import 'package:heal_with_physio/view/physiotherapist/reject_reason.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingAppointmentsScreenPhysio extends StatefulWidget {
  const PendingAppointmentsScreenPhysio({super.key});

  @override
  _PendingAppointmentsScreenPhysioState createState() => _PendingAppointmentsScreenPhysioState();
}

class _PendingAppointmentsScreenPhysioState extends State<PendingAppointmentsScreenPhysio> {
  List<Map<String, dynamic>> pendingAppointments = [];
  bool isLoading = true;
  String physioName = 'Physiotherapist'; // Default name until fetched

  @override
  void initState() {
    super.initState();
    fetchPhysioName().then((_) {
      fetchPendingAppointments(); // Fetch appointments after physioName is set
    });
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

  Future<void> fetchPendingAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://${MyApp.ip}/capstone/get_pending_appointments.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'physio_name': physioName,
          'status': null, // Filter for pending appointments (NULL status)
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            pendingAppointments = List<Map<String, dynamic>>.from(data['appointments']).map((appt) {
              String status = appt['status']?.toString().trim() ?? 'Pending';
              appt['status'] = status == '' || appt['status'] == null ? 'Pending' : status;
              return appt;
            }).toList();
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
        _showSnackBar(context, 'Failed to fetch pending appointments', Colors.red);
      }
    } catch (e) {
      _showSnackBar(context, 'Error: $e', Colors.red);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> acceptAppointment(int appointmentId) async {
    try {
      final response = await http.post(
        Uri.parse('http://${MyApp.ip}/capstone/accept_appointment.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'appointment_id': appointmentId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _showSnackBar(context, data['message'], Colors.green);
       
        if (data['status'] == 'success') {
          fetchPendingAppointments(); // Refresh the list
        }
      } else {
        _showSnackBar(context, 'Failed to accept appointment', Colors.red);
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

  @override
  Widget build(BuildContext context) {
    final filteredAppointments = pendingAppointments
        .where((appointment) => appointment["status"] == "Pending")
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pending Appointments",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredAppointments.isEmpty
              ? Center(
                  child: Text(
                    "No pending appointments available.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: filteredAppointments.length,
                  itemBuilder: (context, index) {
                    var appointment = filteredAppointments[index];

                    return Card(
                      elevation: 5,
                      margin: EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                appointment["patient_name"]!,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "📅 ${appointment["appointment_date"]}",
                                      style: TextStyle(fontSize: 14, color: Colors.black),
                                    ),
                                    Text(
                                      "⏰ ${appointment["selected_slot"]}",
                                      style: TextStyle(fontSize: 14, color: Colors.black),
                                    ),
                                    Text(
                                      "🏡 ${appointment["consulting_type"]}",
                                      style: TextStyle(fontSize: 14, color: Colors.black),
                                    ),
                                    Text(
                                      "🚨 Emergency: ${appointment["is_emergency"] ? 'Yes' : 'No'}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: appointment["is_emergency"] ? Colors.red : Colors.black,
                                      ),
                                    ),
                                    Text(
                                      "📍 ${appointment["address"]}",
                                      style: const TextStyle(fontSize: 14, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  appointment["status"]!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ),
                            ),

                            // Confirm & Reject Buttons
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    acceptAppointment(appointment["id"]);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green, // Accept button color
                                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 6,
                                    shadowColor: Colors.greenAccent,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white), // Accept icon
                                      SizedBox(width: 10),
                                      Text(
                                        "Accept",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RejectReasonScreen(appointmentId: appointment["id"]),
                                      ),
                                    ).then((result) {
                                      if (result == true) {
                                        fetchPendingAppointments(); // Refresh after rejection
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red, // Reject button color
                                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 6,
                                    shadowColor: Colors.redAccent,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.cancel, color: Colors.white), // Reject icon
                                      SizedBox(width: 10),
                                      Text(
                                        "Reject",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}