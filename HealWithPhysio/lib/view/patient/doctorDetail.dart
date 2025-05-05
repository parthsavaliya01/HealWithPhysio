import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:heal_with_physio/main.dart';

class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key, required String name, required String specialization, required String image, required String email, required String gender, required String qualification, required String experience, required String contactNo});

  Future<void> _bookAppointment({
    required String physioName,
    required String contactNumber,
    required String email,
    required String gender,
    required String specialization,
    required BuildContext context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://${MyApp.ip}/capstone/save_appointment.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'physio_name': physioName,
          'contact_number': contactNumber,
          'email': email,
          'gender': gender,
          'specialization': specialization,
        }),
      );

      final result = jsonDecode(response.body);
      
      if (result['success']) {
        _showSnackBar(context,result['message'], Colors.red);
        Navigator.pushNamed(
          context,
          '/patient/bookDateType',
          arguments: {
            'physioName': physioName,
            'physioId': '',
          },
        );
      } else {
        _showSnackBar(context,result['message'], Colors.red);
      }
    } catch (e) {
      _showSnackBar(context,'Error booking appointment: $e', Colors.red);
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
    final Map<String, dynamic>? args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    
    final String name = (args?['name'] ?? 'Unknown').toString();
    final String specialization = (args?['specialization'] ?? 'Not specified').toString();
    final String image = (args?['image'] ?? 'assets/images/d1.jpg').toString();
    final String email = (args?['email'] ?? 'Not available').toString();
    final String gender = (args?['gender'] ?? 'Not specified').toString();
    final String qualification = (args?['qualification'] ?? 'Not specified').toString();
    final String experience = (args?['experience'] ?? '0').toString();
    final String contactNo = (args?['contactNo'] ?? 'Not available').toString();
    final String clinicAddress = (args?['clinicAddress'] ?? 'Not available').toString();
    final String clinicStartTime = (args?['clinicStartTime'] ?? 'N/A').toString();
    final String clinicEndTime = (args?['clinicEndTime'] ?? 'N/A').toString();
    final String appartment = (args?['appartment'] ?? 'Not available').toString();
    final String landmark = (args?['landmark'] ?? 'Not available').toString();
    final String area = (args?['area'] ?? 'Not available').toString();
    final String city = (args?['city'] ?? 'Not available').toString();
    final String pincode = (args?['pincode'] ?? 'Not available').toString();
    
    final double rating = double.tryParse(args?['average_rating']?.toString() ?? '0.0') ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Physiotherapist Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: image.isNotEmpty && image.contains('http')
                      ? Image.network(
                          image,
                          height: 100.0,
                          width: 100.0,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              height: 100.0,
                              width: 100.0,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('Image loading error: $error');
                            return Image.asset(
                              'assets/images/d1.jpg',
                              height: 100.0,
                              width: 100.0,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/d1.jpg',
                          height: 100.0,
                          width: 100.0,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              SizedBox(height: 20.0),
              Center(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[900],
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 20.0),
                    SizedBox(width: 5.0),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.indigo[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildDetailSection("Contact Number", contactNo),
              _buildDetailSection("Email", email),
              _buildDetailSection("Gender", gender),
              _buildDetailSection("Specialization", specialization),
              _buildDetailSection("Timing", "$clinicStartTime to $clinicEndTime"),
              _buildDetailSection("Appartment", appartment),
              _buildDetailSection("Landmark", landmark),
              _buildDetailSection("Area", area),
              _buildDetailSection("City", city),
              _buildDetailSection("Pincode", pincode),
              _buildDetailSection("Qualification", qualification),
              _buildDetailSection("Years of Experience", "$experience years"),
              
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final response = await http.post(
                        Uri.parse('http://${MyApp.ip}/capstone/save_appointment.php'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'physio_name': name,
                          'contact_number': contactNo,
                          'email': email,
                          'gender': gender,
                          'specialization': specialization,
                        }),
                      );

                      final result = jsonDecode(response.body);

                      if (result['success']) {
                        final int appointmentId = result['appointment_id'] as int;
                        // _showSnackBar(context,'Detailed Saved', Colors.green);
                        Navigator.pushNamed(
  context,
  '/patient/bookDateType',
  arguments: {
    'physioName': name,
    'contactNo': contactNo,
    'email': email,
    'gender': gender,
    'specialization': specialization,
    'appointmentId': appointmentId,
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result['message'])),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error booking appointment: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text(
                    "Book Appointment",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
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
            "$title",
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
}