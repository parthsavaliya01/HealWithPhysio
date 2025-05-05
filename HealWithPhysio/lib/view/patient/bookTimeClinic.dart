import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:heal_with_physio/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Added for date/time formatting

class BookTimeClinic extends StatefulWidget {
  const BookTimeClinic({super.key});

  @override
  _BookTimeClinicState createState() => _BookTimeClinicState();
}

class _BookTimeClinicState extends State<BookTimeClinic> {
  String? selectedSlot;
  bool isLoading = false;
  bool isEmergency = false;
  Map<String, dynamic>? bookingArgs;
  Map<String, dynamic>? patientAddress;
  List<String> timeSlots = [];

  @override
  void initState() {
    super.initState();
    _fetchPatientAddress();
  }

  Future<void> _fetchPatientAddress() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username == null) {
      _showSnackBar(context, 'User not logged in', Colors.red);
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://${MyApp.ip}/capstone/get_patient_address.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          setState(() {
            patientAddress = result['data'];
            isLoading = false;
          });
        } else {
          _showSnackBar(context, result['message'], Colors.red);
          setState(() {
            isLoading = false;
          });
        }
      } else {
        _showSnackBar(context, 'Server error: ${response.statusCode}', Colors.red);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar(context, 'Network error: $e', Colors.red);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveAppointmentAndNavigate() async {
    setState(() {
      isLoading = true;
    });
    if (selectedSlot == null) {
      _showSnackBar(context, 'Please select a time slot', Colors.red);
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://${MyApp.ip}/capstone/save_appointment_clinic.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'appointment_id': bookingArgs!['appointment_id'] ?? '0',
          'selected_slot': selectedSlot,
          'is_emergency': isEmergency ? 1 : 0,
          'appartment': bookingArgs!['appartment']?.toString() ?? 'Not available',
          'landmark': bookingArgs!['landmark']?.toString() ?? 'Not available',
          'area': bookingArgs!['area']?.toString() ?? 'Not available',
          'city': bookingArgs!['city']?.toString() ?? 'Not available',
          'pincode': bookingArgs!['pincode']?.toString() ?? 'Not available',
        }),
      );
      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['success']) {
        Navigator.pushNamed(
          context,
          '/patient/previewSlot',
          arguments: {
            'appointment_id': bookingArgs!['appointment_id'] ?? '0',
          },
        );
      } else {
        _showSnackBar(context, result['message'] ?? 'Failed to update appointment', Colors.red);
      }
    } catch (e) {
      _showSnackBar(context, 'Error updating appointment: $e', Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToPreview() {
    _saveAppointmentAndNavigate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bookingArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (bookingArgs != null) {
      _generateTimeSlots();
    }
  }

  void _generateTimeSlots() {
    if (bookingArgs == null || bookingArgs!['clinic_start_time'] == null || bookingArgs!['clinic_end_time'] == null) {
      _showSnackBar(context, 'Booking args missing or incomplete: $bookingArgs', Colors.red);
      setState(() {
        timeSlots = ["Not available - Clinic hours missing"];
      });
      return;
    }

    var startTimeRaw = bookingArgs!['clinic_start_time'];
    var endTimeRaw = bookingArgs!['clinic_end_time'];
    String startTimeStr = startTimeRaw is int ? startTimeRaw.toString().padLeft(4, '0') : startTimeRaw.toString();
    String endTimeStr = endTimeRaw is int ? endTimeRaw.toString().padLeft(4, '0') : endTimeRaw.toString();

    if (startTimeStr.length == 4 && !startTimeStr.contains(':')) {
      startTimeStr = "${startTimeStr.substring(0, 2)}:${startTimeStr.substring(2)}";
    }
    if (endTimeStr.length == 4 && !endTimeStr.contains(':')) {
      endTimeStr = "${endTimeStr.substring(0, 2)}:${endTimeStr.substring(2)}";
    }
    try {
      DateFormat format = DateFormat("HH:mm");
      DateTime startTime = format.parse(startTimeStr);
      DateTime endTime = format.parse(endTimeStr);

      if (endTime.isBefore(startTime)) {
        setState(() {
          timeSlots = ["Invalid clinic hours"];
        });
        return;
      }

      List<String> generatedSlots = [];
      DateTime currentTime = startTime;

      while (currentTime.isBefore(endTime)) {
        DateTime nextTime = currentTime.add(Duration(hours: 1));
        if (nextTime.isAfter(endTime)) break;

        String slotStart = DateFormat("h:mm a").format(currentTime);
        String slotEnd = DateFormat("h:mm a").format(nextTime);
        generatedSlots.add("$slotStart - $slotEnd");

        currentTime = nextTime;
      }

      setState(() {
        timeSlots = generatedSlots.isNotEmpty ? generatedSlots : ["No available slots"];
      });
    } catch (e) {
      setState(() {
        timeSlots = ["Error generating slots: $e"];
        _showSnackBar(context, 'Error: $e', Colors.red);
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

  Widget _buildDetailSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title:",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[900],
            ),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(fontSize: 16.0, color: Colors.black87),
          ),
          Divider(color: Colors.grey),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Appointment", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: bookingArgs == null || isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text("Select Time Slot", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 3,
                    ),
                    itemCount: timeSlots.length,
                    itemBuilder: (context, index) {
                      final slot = timeSlots[index];
                      final isSelected = slot == selectedSlot;
                      return GestureDetector(
                        onTap: () => setState(() => selectedSlot = slot),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.indigo[900] : Colors.white,
                            border: Border.all(color: Colors.indigo, width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            slot,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  const Text("Physiotherapist Clinic Address", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  _buildDetailSection("Appartment", bookingArgs!['appartment']?.toString() ?? 'Not available'),
                  _buildDetailSection("Landmark", bookingArgs!['landmark']?.toString() ?? 'Not available'),
                  _buildDetailSection("Area", bookingArgs!['area']?.toString() ?? 'Not available'),
                  _buildDetailSection("City", bookingArgs!['city']?.toString() ?? 'Not available'),
                  _buildDetailSection("Pincode", bookingArgs!['pincode']?.toString() ?? 'Not available'),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Expanded(
                        child: Text("Need Emergency Service?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Switch(
                        value: isEmergency,
                        onChanged: (value) => setState(() => isEmergency = value),
                        activeColor: Colors.indigo[900],
                        activeTrackColor: Colors.indigo[400],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: selectedSlot != null ? navigateToPreview : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[900],
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: const Text("Next", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}