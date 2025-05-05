import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:heal_with_physio/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RejectedAppointmentsScreenPhysio extends StatefulWidget {
  const RejectedAppointmentsScreenPhysio({super.key});

  @override
  _RejectedAppointmentsScreenPhysioState createState() => _RejectedAppointmentsScreenPhysioState();
}

class _RejectedAppointmentsScreenPhysioState extends State<RejectedAppointmentsScreenPhysio> {
  List<Map<String, dynamic>> rejectedAppointments = [];
  bool isLoading = true;
  String physioName = 'Physiotherapist'; // Default name until fetched

  @override
  void initState() {
    super.initState();
    fetchPhysioName().then((_) {
      fetchRejectedAppointments(); // Fetch appointments after physioName is set
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

  Future<void> fetchRejectedAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://${MyApp.ip}/capstone/get_rejected_appointments.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'physio_name': physioName,
          'status': 'Rejected', // Filter for rejected appointments
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            rejectedAppointments = List<Map<String, dynamic>>.from(data['appointments']);
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
        _showSnackBar(context, 'Failed to fetch rejected appointments', Colors.red);
      }
    } catch (e) {
      _showSnackBar(context, 'Error: $e', Colors.red);
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

  @override
  Widget build(BuildContext context) {
    // Filter for rejected appointments
    final filteredAppointments = rejectedAppointments
        .where((appointment) => appointment["status"] == "Rejected")
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Rejected Appointments",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredAppointments.isEmpty
              ? Center(
                  child: Text(
                    "No rejected appointments available.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: filteredAppointments.length,
                  itemBuilder: (context, index) {
                    var appointment = filteredAppointments[index];

                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                appointment["patient_name"]!,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
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
                                      "🏥 ${appointment["consulting_type"]}",
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
                                      style: TextStyle(fontSize: 14, color: Colors.black),
                                    ),
                                    Text(
                                      "❌ Reason: ${appointment["rejection_reason"] ?? 'Not specified'}",
                                      style: TextStyle(fontSize: 14, color: Colors.red.shade700),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  appointment["status"]!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                              ),
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