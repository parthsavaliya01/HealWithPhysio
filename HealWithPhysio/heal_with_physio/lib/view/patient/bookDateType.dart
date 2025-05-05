import 'package:flutter/material.dart';
import 'package:heal_with_physio/main.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookDateTypeScreen extends StatefulWidget {
  const BookDateTypeScreen({super.key});

  @override
  _BookDateTypeScreenState createState() => _BookDateTypeScreenState();
}

class _BookDateTypeScreenState extends State<BookDateTypeScreen> {
  DateTime? selectedDate;
  String visitType = "";

  Future<void> _selectDate(BuildContext context) async {
    DateTime today = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(Duration(days: 30)),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  

  Future<void> _updateAppointmentDetails(BuildContext context) async {
    final Map<String, dynamic>? args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final int appointmentId = args?['appointmentId'] as int? ?? 0;
    final String appartment = args?['appartment'] ?? 'Not available';
    final String landmark = args?['landmark'] ?? 'Not available';
    final String area = args?['area'] ?? 'Not available';
    final String city = args?['city'] ?? 'Not available';
    final String pincode = args?['pincode'] ?? 'Not available';
    final String? clinicStartTime = args?['clinic_start_time']; // Added
    final String? clinicEndTime = args?['clinic_end_time'];     // Added

    try {
      final response = await http.post(
        Uri.parse('http://${MyApp.ip}/capstone/update_appointment_details.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'appointment_id': appointmentId,
          'appointment_date': DateFormat('yyyy-MM-dd').format(selectedDate!),
          'consulting_type': visitType,
        }),
      );

      final result = jsonDecode(response.body);

      if (result['success']) {
        //_showSnackBar(context,'Detailed Saved Successfully', Colors.green);
      String route = visitType == "Clinic Consulting" ? '/patient/bookTimeClinic' : '/patient/bookTimeHome';

        Navigator.pushNamed(
  context,
  route,
  arguments: {
    'appointment_id': appointmentId, // Add this line
    'appointment_date': DateFormat('dd-MM-yyyy').format(selectedDate!),
    'consulting_type': visitType,
    'appartment': appartment,
    'landmark': landmark,
    'area': area,
    'city': city,
    'pincode': pincode,
    'clinic_start_time': clinicStartTime,
    'clinic_end_time': clinicEndTime,
  },
);
      } else {
        _showSnackBar(context,result['message'], Colors.red);
      }
    } catch (e) {
      _showSnackBar(context,'Error updating appointment: $e', Colors.red);
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
        title: const Text("Book Appointment", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Text("Select Date", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.indigo, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate == null
                          ? "Select a Date"
                          : DateFormat("dd-MM-yyyy").format(selectedDate!),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.indigo),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),
            const Text("Select Consulting Type", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            RadioListTile(
              title: const Text("Clinic Consulting"),
              value: "Clinic Consulting",
              groupValue: visitType,
              onChanged: (value) => setState(() => visitType = value.toString()),
              activeColor: Colors.indigo[900],
            ),
            RadioListTile(
              title: const Text("Home Consulting"),
              value: "Home Consulting",
              groupValue: visitType,
              onChanged: (value) => setState(() => visitType = value.toString()),
              activeColor: Colors.indigo[900],
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: selectedDate != null && visitType.isNotEmpty
                    ? () => _updateAppointmentDetails(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[900],
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}