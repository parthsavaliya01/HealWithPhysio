import 'package:flutter/material.dart';

class PastAppointmentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> appointment;

  const PastAppointmentDetailScreen({super.key, required this.appointment});

  @override
  State<PastAppointmentDetailScreen> createState() =>
      _PastAppointmentDetailScreenState();
}

class _PastAppointmentDetailScreenState
    extends State<PastAppointmentDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Appointment Detail",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Your Detail"),
              _infoCard([
                _infoRow("Name", appointment["patient_name"] ?? "N/A"),
                _infoRow("Email", appointment["patient_email"] ?? "N/A"),
              ]),
              const SizedBox(height: 20),
              _sectionTitle("Physiotherapist Detail"),
              _infoCard([
                _infoRow("Name", appointment["doctor"] ?? "N/A"),
                _infoRow("Email", appointment["email"] ?? "N/A"),
                _infoRow("Gender", appointment["gender"] ?? "N/A"),
              ]),
              const SizedBox(height: 20),
              _sectionTitle("Appointment Detail"),
              _infoCard([
                _infoRow("ID", appointment["id"] ?? "N/A"),
                _infoRow("Date", appointment["date"] ?? "N/A"),
                _infoRow("Time", appointment["time"] ?? "N/A"),
                _infoRow(
                    "Consulting Type", appointment["typeOfVisit"] ?? "N/A"),
                _infoRow(
                    "Status",
                    appointment["status"]?.isEmpty ?? true
                        ? "Pending"
                        : appointment["status"]),
                _infoRow("Emergency", appointment["emergency"] ?? "No"),
                _infoRow("Appartment", appointment["appartment"] ?? "No"),
                _infoRow("Landmark", appointment["landmark"] ?? "No"),
                _infoRow("Area", appointment["area"] ?? "No"),
                _infoRow("City", appointment["city"] ?? "No"),
                _infoRow("Pincode", appointment["pincode"] ?? "No"),
                _infoRow("Rejection Reason",
                    appointment["rejection_reason"] ?? "No"),
              ]),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: (appointment["has_rated"] == "Yes")
                      ? null
                      : () {
                          // Log values being passed to RatingFeedbackScreen
                          // print('Navigating to RatingFeedback with:');
                          // print('Appointment ID: "${appointment["id"]}"');
                          // print('Physio Name: "${appointment["doctor"]}"');
                          // print(
                          //     'Patient Name: "${appointment["patient_name"]}"');
                          // Validate before navigation
                          if (appointment["id"] == null ||
                              appointment["id"] == 'N/A' ||
                              appointment["doctor"] == null ||
                              appointment["doctor"] == 'Unknown' ||
                              appointment["patient_name"] == null ||
                              appointment["patient_name"] == 'N/A') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Cannot rate: Missing appointment details')),
                            );
                            return;
                          }
                          Navigator.pushNamed(
                            context,
                            '/patient/ratingFeedback',
                            arguments: {
                              'appointment_id': appointment["id"].toString(),
                              'physio_name': appointment["doctor"].toString(),
                              'patient_name':
                                  appointment["patient_name"].toString(),
                            },
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text(
                    (appointment["has_rated"] == "Yes")
                        ? "Rated"
                        : "Give Rating and Feedback",
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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.indigo[900],
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label : ",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
