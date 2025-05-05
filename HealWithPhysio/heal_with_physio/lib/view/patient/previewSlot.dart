import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heal_with_physio/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PreviewSlotScreen extends StatefulWidget {
  const PreviewSlotScreen({super.key});

  @override
  _PreviewSlotScreenState createState() => _PreviewSlotScreenState();
}

class _PreviewSlotScreenState extends State<PreviewSlotScreen> {
  Map<String, dynamic>? patientDetails;
  Map<String, dynamic>? appointmentDetails;
  bool isLoadingPatient = true;
  bool isLoadingAppointment = true;
  String? patientErrorMessage;
  String? appointmentErrorMessage;
  String appointmentId = '0'; // Store appointment_id as String

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();  
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    appointmentId = args?['appointment_id']?.toString() ?? '0';
    fetchData();
  }

  // Combined function to fetch both patient and appointment details
  Future<void> fetchData() async {
    await fetchPatientDetails();
    await fetchAppointmentDetails(appointmentId);
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

  Future<void> fetchPatientDetails() async {
    setState(() {
      isLoadingPatient = true;
      patientErrorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');

    if (username == null || username.isEmpty) {
      setState(() {
        patientErrorMessage = 'No user logged in';
        isLoadingPatient = false;
      });
      return;
    }

    var url = Uri.parse('http://${MyApp.ip}/capstone/get_patient_details.php?username=$username');

    try {
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out while fetching patient details');
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          setState(() {
            patientDetails = data['data'];
            isLoadingPatient = false;
          });
        } else {
          setState(() {
            patientErrorMessage = data['message'] ?? 'Failed to load patient details';
            isLoadingPatient = false;
          });
        }
      } else {
        setState(() {
          patientErrorMessage = 'Failed to load patient details. Status code: ${response.statusCode}, Response: ${response.body}';
          isLoadingPatient = false;
        });
      }
    } catch (e) {
      _showSnackBar(context,'Error occurred in fetchPatientDetails: $e', Colors.red);
      setState(() {
        patientErrorMessage = 'Error fetching patient details: $e';
        isLoadingPatient = false;
      });
    }
  }

  Future<void> fetchAppointmentDetails(String appointmentId) async {
    setState(() {
      isLoadingAppointment = true;
      appointmentErrorMessage = null;
    });

    if (appointmentId == '0') {
      setState(() {
        appointmentErrorMessage = 'Invalid appointment ID';
        isLoadingAppointment = false;
      });
      return;
    }

    var url = Uri.parse('http://${MyApp.ip}/capstone/get_appointment_details.php?appointment_id=$appointmentId');

    try {
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out while fetching appointment details');
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          setState(() {
            appointmentDetails = data['data'];
            isLoadingAppointment = false;
          });
        } else {
          setState(() {
            appointmentErrorMessage = data['message'] ?? 'Failed to load appointment details';
            isLoadingAppointment = false;
          });
        }
      } else {
        setState(() {
          appointmentErrorMessage = 'Failed to load appointment details. Status code: ${response.statusCode}, Response: ${response.body}';
          isLoadingAppointment = false;
        });
      }
    } catch (e) {
      
      setState(() {
        appointmentErrorMessage = 'Error fetching appointment details: $e';
        isLoadingAppointment = false;
      });
    }
  }

  Future<bool> updateAppointmentPatientDetails(String appointmentId) async {
    if (appointmentId == '0') {
      // print('Invalid appointment ID for updating patient details');
      return false;
    }

    if (patientDetails == null) {
      // print('Patient details not available for updating');
      return false;
    }

    var url = Uri.parse('http://${MyApp.ip}/capstone/update_appointment_patient_details.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'appointment_id': appointmentId,
          'patient_name': patientDetails!['name'],
          'patient_contactno': patientDetails!['contact_no'].toString(),
          'patient_email': patientDetails!['email'],
          'patient_gender': patientDetails!['gender'],
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out while updating patient details');
        },
      );

      print('Update Patient Details Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // print('Patient details updated successfully for appointment ID: $appointmentId');
          return true;
        } else {
          // print('Failed to update patient details: ${data['message']}');
          return false;
        }
      } else {
        // print('Failed to update patient details. Status code: ${response.statusCode}, Response: ${response.body}');
        return false;
      }
    } catch (e) {
      // print('Error occurred in updateAppointmentPatientDetails: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preview Appointment", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Center(
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.circular(50.0),
              //     child: Image.asset(
              //       "assets/images/d1.jpg",
              //       height: 100.0,
              //       width: 100.0,
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              // ),
              const SizedBox(height: 20.0),
              Text(
                  appointmentDetails != null ? appointmentDetails!['physio_name'] : "Dr. Heena Mulchandani",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[900],
                  ),
                ),
      
              const SizedBox(height: 10.0),
              // Center(
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       const Icon(Icons.star, color: Colors.orange, size: 20.0),
              //       const SizedBox(width: 5.0),
              //       Text(
              //         "4",
              //         style: TextStyle(
              //           fontSize: 18.0,
              //           color: Colors.indigo[600],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              const SizedBox(height: 20),
              isLoadingAppointment
                  ? const Text(
                "Contact No: Loading...",
                style: TextStyle(fontSize: 20),
              )
                  : appointmentErrorMessage != null
                  ? Text(
                "Contact No: Error - $appointmentErrorMessage",
                style: const TextStyle(fontSize: 20, color: Colors.red),
              )
                  : Text(
                "Contact No: ${appointmentDetails!['contact_number'].toString()}",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              isLoadingAppointment
                  ? const Text(
                "Email: Loading...",
                style: TextStyle(fontSize: 20),
              )
                  : appointmentErrorMessage != null
                  ? Text(
                "Email: Error - $appointmentErrorMessage",
                style: const TextStyle(fontSize: 20, color: Colors.red),
              )
                  : Text(
                "Email: ${appointmentDetails!['email']}",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20,),
              Divider(color: Colors.grey),
              const SizedBox(height: 30),
              Text(
                "Appointment Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.indigo[900]),
              ),
              const SizedBox(height: 10),
              Text(
                "Appointment ID: $appointmentId",
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              isLoadingAppointment
                  ? const Text(
                      "Date: Loading...",
                      style: TextStyle(fontSize: 20),
                    )
                  : appointmentErrorMessage != null
                      ? Text(
                          "Date: Error - $appointmentErrorMessage",
                          style: const TextStyle(fontSize: 20, color: Colors.red),
                        )
                      : Text(
                          "Date: ${appointmentDetails!['appointment_date']}",
                          style: const TextStyle(fontSize: 20),
                        ),
              const SizedBox(height: 10),
              isLoadingAppointment
                  ? const Text(
                      "Time: Loading...",
                      style: TextStyle(fontSize: 20),
                    )
                  : appointmentErrorMessage != null
                      ? Text(
                          "Time: Error - $appointmentErrorMessage",
                          style: const TextStyle(fontSize: 20, color: Colors.red),
                        )
                      : Text(
                          "Time: ${appointmentDetails!['selected_slot']}",
                          style: const TextStyle(fontSize: 20),
                        ),
              const SizedBox(height: 10),
              isLoadingAppointment
                  ? const Text(
                      "Type: Loading...",
                      style: TextStyle(fontSize: 20),
                    )
                  : appointmentErrorMessage != null
                      ? Text(
                          "Type: Error - $appointmentErrorMessage",
                          style: const TextStyle(fontSize: 20, color: Colors.red),
                        )
                      : Text(
                          "Type: ${appointmentDetails!['consulting_type']}",
                          style: const TextStyle(fontSize: 20),
                        ),
              const SizedBox(height: 10),
              isLoadingAppointment
                  ? const Text(
                      "Emergency: Loading...",
                      style: TextStyle(fontSize: 20),
                    )
                  : appointmentErrorMessage != null
                      ? Text(
                          "Emergency: Error - $appointmentErrorMessage",
                          style: const TextStyle(fontSize: 20, color: Colors.red),
                        )
                      : Text(
                          "Emergency: ${appointmentDetails!['is_emergency'].toString() == '1' ? 'Yes' : 'No'}",
                          style: const TextStyle(fontSize: 20),
                        ),
              const SizedBox(height: 20,),
              Divider(color: Colors.grey),
              const SizedBox(height: 30),
              Text(
                "Your Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.indigo[900]),
              ),
              const SizedBox(height: 10),
              isLoadingPatient
                  ? const Center(child: CircularProgressIndicator())
                  : patientErrorMessage != null
                      ? Text(
                          patientErrorMessage!,
                          style: const TextStyle(fontSize: 18, color: Colors.red),
                        )
                      : patientDetails != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Name: ${patientDetails!['name']}",
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Contact No: ${patientDetails!['contact_no'].toString()}",
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Email: ${patientDetails!['email']}",
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Gender: ${patientDetails!['gender']}",
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            )
                          : const Text(
                              "No patient details available",
                              style: TextStyle(fontSize: 18, color: Colors.red),
                            ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: (isLoadingPatient || isLoadingAppointment || appointmentErrorMessage != null || patientErrorMessage != null)
                      ? null
                      : () async {
                          bool isUpdated = await updateAppointmentPatientDetails(appointmentId);
                          if (isUpdated) {
                            Navigator.pushNamed(context, "/patient/appointmentStatus");
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to save patient details. Please try again.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    "Confirm Appointment",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}