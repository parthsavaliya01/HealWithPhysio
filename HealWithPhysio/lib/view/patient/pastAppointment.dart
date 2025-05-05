import 'package:flutter/material.dart';
import 'package:heal_with_physio/view/patient/pastAppointmentDetail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heal_with_physio/main.dart'; // To access MyApp.ip

class PastAppointmentScreen extends StatefulWidget {
  PastAppointmentScreen({super.key});

  @override
  _PastAppointmentScreenState createState() => _PastAppointmentScreenState();
}

class _PastAppointmentScreenState extends State<PastAppointmentScreen> {
  List<Map<String, dynamic>> pastAppointments = []; // Changed to dynamic to handle JSON
  bool isLoading = true;
  String errorMessage = '';
  String patientName = ''; // Store patient name

  @override
  void initState() {
    super.initState();
    fetchPatientNameAndAppointments();
  }

  Future<void> fetchPatientNameAndAppointments() async {
    await fetchPatientName();
    if (patientName.isNotEmpty) {
      await fetchPastAppointments();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchPatientName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';

      if (username.isEmpty) {
        setState(() {
          errorMessage = 'Username not found in preferences';
          isLoading = false;
        });
        return;
      }

      final nameResponse = await http.post(
        Uri.parse('http://${MyApp.ip}/capstone/get_patient_name.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (nameResponse.statusCode != 200) {
        setState(() {
          errorMessage = 'Failed to fetch patient name: Server error ${nameResponse.statusCode}';
          isLoading = false;
        });
        return;
      }

      final nameData = jsonDecode(nameResponse.body);
      if (nameData['status'] != 'success') {
        setState() {
          errorMessage = nameData['message'] ?? 'Failed to fetch patient name';
          isLoading = false;
        }
        return;
      }

      setState(() {
        patientName = nameData['name'];
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching patient name: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchPastAppointments() async {
  try {
    if (patientName.isEmpty) {
      setState(() {
        errorMessage = 'Patient name is empty, cannot fetch appointments';
        isLoading = false;
      });
      return;
    }
    final appointmentsResponse = await http.post(
      Uri.parse('http://${MyApp.ip}/capstone/get_past_appointments.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'patient_name': patientName}),
    );
    if (appointmentsResponse.statusCode != 200) {
      setState(() {
        errorMessage = 'Failed to fetch past appointments: Server error ${appointmentsResponse.statusCode}';
        isLoading = false;
      });
      return;
    }

    final appointmentsData = jsonDecode(appointmentsResponse.body);
    if (appointmentsData['status'] != 'success') {
      setState(() {
        errorMessage = appointmentsData['message'] ?? 'Failed to fetch appointments';
        isLoading = false;
      });
      return;
    }
    if (appointmentsData['appointments'] == null || !(appointmentsData['appointments'] is List)) {
      setState(() {
        errorMessage = 'Invalid appointments data format';
        isLoading = false;
      });
      return;
    }

    // Log the raw response for debugging
    print('Raw appointments response: $appointmentsData');

    setState(() {
      pastAppointments = (appointmentsData['appointments'] as List<dynamic>).map((item) {
        final map = item as Map<String, dynamic>;
        // Log each appointment's key fields
        // print('Mapping appointment:');
        // print('ID: "${map['id']}"');
        // print('Doctor: "${map['doctor']}"');
        // print('Patient Name: "${map['patient_name']}"');
        return {
          'id': map['id']?.toString() ?? 'N/A',
          'doctor': map['doctor']?.toString() ?? 'Unknown',
          'date': map['date']?.toString() ?? 'N/A',
          'time': map['time']?.toString() ?? 'N/A',
          'typeOfVisit': map['typeOfVisit']?.toString() ?? 'N/A',
          'emergency': map['emergency']?.toString() ?? 'No',
          'status': map['status']?.toString() ?? 'Pending',
          'email': map['email']?.toString() ?? 'N/A',
          'gender': map['gender']?.toString() ?? 'N/A',
          'appartment': map['appartment']?.toString() ?? 'N/A',
          'landmark': map['landmark']?.toString() ?? 'N/A',
          'area': map['area']?.toString() ?? 'N/A',
          'city': map['city']?.toString() ?? 'N/A',
          'pincode': map['pincode']?.toString() ?? 'N/A',
          'patient_email': map['patient_email']?.toString() ?? 'N/A',
          'rejection_reason': map['rejection_reason']?.toString() ?? 'N/A',
          'patient_name': map['patient_name']?.toString() ?? patientName,
          'has_rated': map['has_rated']?.toString() ?? 'No',
        };
      }).where((appointment) {
        // Filter appointments where patient_name matches fetched patientName (case-insensitive)
        return (appointment['patient_name']?.toLowerCase() ?? patientName.toLowerCase()) == patientName.toLowerCase();
      }).toList();

      isLoading = false;
    });
  } catch (e) {
    setState(() {
      errorMessage = 'Error fetching past appointments: $e';
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Past Appointments",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                )
              : pastAppointments.isEmpty
                  ? Center(
                      child: Text(
                        "No past appointments available.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16.0),
                      itemCount: pastAppointments.length,
                      itemBuilder: (context, index) {
                        var appointment = pastAppointments[index];

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
                                    appointment["doctor"]!,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/patient/pastAppointmentDetail',
                                      arguments: appointment, // Pass the entire appointment map including id
                                    );
                                  },
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.confirmation_number, size: 16, color: Colors.black),
                                            SizedBox(width: 5),
                                            Text(
                                              "ID: ${appointment["id"]}",
                                              style: TextStyle(fontSize: 14, color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today, size: 16, color: Colors.black),
                                            SizedBox(width: 5),
                                            Text(
                                              appointment["date"]!,
                                              style: TextStyle(fontSize: 14, color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time, size: 16, color: Colors.black),
                                            SizedBox(width: 5),
                                            Text(
                                              appointment["time"]!,
                                              style: TextStyle(fontSize: 14, color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.local_hospital, size: 16, color: Colors.black),
                                            SizedBox(width: 5),
                                            Text(
                                              appointment["typeOfVisit"]!,
                                              style: TextStyle(fontSize: 14, color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.warning_amber_rounded,
                                              size: 16,
                                              color: appointment["emergency"] == "Yes" ? Colors.red : Colors.black,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              "Emergency: ${appointment["emergency"]}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: appointment["emergency"] == "Yes" ? Colors.red : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: appointment["status"] == "Accepted"
                                          ? Colors.green.shade100
                                          : appointment["status"] == "Rejected"
                                              ? Colors.red.shade100
                                              : Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      appointment["status"] == "" ? "Pending" : appointment["status"]!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: appointment["status"] == "Accepted"
                                            ? Colors.green.shade900
                                            : appointment["status"] == "Rejected"
                                                ? Colors.red.shade900
                                                : Colors.orange.shade900
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