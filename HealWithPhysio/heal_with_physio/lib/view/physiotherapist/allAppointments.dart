import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:heal_with_physio/view/physiotherapist/reject_reason.dart';
import 'package:heal_with_physio/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllAppointmentsScreenPhysio extends StatefulWidget {
  const AllAppointmentsScreenPhysio({super.key});

  @override
  _AllAppointmentsScreenPhysioState createState() => _AllAppointmentsScreenPhysioState();
}

class _AllAppointmentsScreenPhysioState extends State<AllAppointmentsScreenPhysio> {
  List<Map<String, dynamic>> allAppointments = [];
  bool isLoading = true;
  String physioName = 'Physiotherapist'; // Default name until fetched

  @override
  void initState() {
    super.initState();
    fetchPhysioName().then((_) {
      fetchAppointments(); // Fetch appointments after physioName is set
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

      // print('Physio Name Response status: ${response.statusCode}');
      // print('Physio Name Response body: ${response.body}');

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

  Future<void> fetchAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://${MyApp.ip}/capstone/get_appointments.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'physio_name': physioName}), // Send physioName to filter appointments
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            allAppointments = List<Map<String, dynamic>>.from(data['appointments']).map((appt) {
              String status = appt['status']?.toString().trim() ?? 'Pending';
              appt['status'] = status == '' ? 'Pending' : status;
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
        _showSnackBar(context, 'Failed to fetch appointments', Colors.red);
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
          fetchAppointments(); // Refresh the list
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "All Appointments",
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allAppointments.isEmpty
              ? const Center(
                  child: Text(
                    "No appointments available.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchAppointments,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: allAppointments.length,
                    itemBuilder: (context, index) {
                      var appointment = allAppointments[index];
                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.only(bottom: 14),
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
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("📅 ${appointment["appointment_date"]}",
                                          style: const TextStyle(fontSize: 14, color: Colors.black)),
                                      Text("⏰ ${appointment["selected_slot"]}",
                                          style: const TextStyle(fontSize: 14, color: Colors.black)),
                                      Text("${appointment["consulting_type"]}",
                                          style: const TextStyle(fontSize: 14, color: Colors.black)),
                                      Text(
                                        "📍 ${appointment["address"]}",
                                        style: const TextStyle(fontSize: 14, color: Colors.black),
                                      ),
                                      Text(
                                        "🚨 Emergency: ${appointment["is_emergency"] ? 'Yes' : 'No'}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: appointment["is_emergency"] ? Colors.red : Colors.black,
                                        ),
                                      ),
                                      if (appointment["status"] == "Rejected" &&
                                          appointment["rejection_reason"] != null)
                                        Text(
                                          "❌ Reason: ${appointment["rejection_reason"]}",
                                          style: const TextStyle(fontSize: 14, color: Colors.red),
                                        ),
                                    ],
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: appointment["status"] == "Pending"
                                        ? Colors.orange.shade100
                                        : appointment["status"] == "Accepted"
                                            ? Colors.green.shade100
                                            : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    appointment["status"]!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: appointment["status"] == "Pending"
                                          ? Colors.orange.shade900
                                          : appointment["status"] == "Accepted"
                                              ? Colors.green.shade900
                                              : Colors.red.shade900,
                                    ),
                                  ),
                                ),
                              ),
                              if (appointment["status"] == "Pending") ...[
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        acceptAppointment(appointment["id"]);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 6,
                                        shadowColor: Colors.greenAccent,
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.white),
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
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RejectReasonScreen(appointmentId: appointment["id"]),
                                          ),
                                        );
                                        if (result == true) {
                                          fetchAppointments(); // Refresh after rejection
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 6,
                                        shadowColor: Colors.redAccent,
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.cancel, color: Colors.white),
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
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}