import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:heal_with_physio/main.dart'; // To access MyApp.ip

class RatingFeedbackScreen extends StatefulWidget {
  final String appointmentId;
  final String physioName;
  final String patientName;

  const RatingFeedbackScreen({
    super.key,
    required this.appointmentId,
    required this.physioName,
    required this.patientName,
  });

  @override
  _RatingFeedbackScreenState createState() => _RatingFeedbackScreenState();
}

class _RatingFeedbackScreenState extends State<RatingFeedbackScreen> {
  double _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool isSubmitting = false; // Added to handle submission state
  String errorMessage = ''; // Added to handle error messages

  @override
  void initState() {
    super.initState();
    // Log received arguments at initialization
    // print('RatingFeedbackScreen initialized with:');
    // print('Appointment ID: "${widget.appointmentId}"');
    // print('Physio Name: "${widget.physioName}"');
    // print('Patient Name: "${widget.patientName}"');
    // Check for invalid arguments
    if (widget.appointmentId.isEmpty || widget.appointmentId == 'N/A' ||
        widget.physioName.isEmpty || widget.physioName == 'Unknown' ||
        widget.patientName.isEmpty || widget.patientName == 'N/A') {
      setState(() {
        errorMessage = 'Invalid appointment details received. Please try again.';
      });
    }
  }

  void _submitFeedback() {
    String feedback = _feedbackController.text;

    // Log input values for debugging
    // print('Submitting feedback with:');
    // print('Appointment ID: "${widget.appointmentId}"');
    // print('Physio Name: "${widget.physioName}"');
    // print('Patient Name: "${widget.patientName}"');
    // print('Rating: ${_rating.toInt()}');
    // print('Feedback: "$feedback"');

    // Client-side validation with specific error messages
    List<String> missingFields = [];
    if (widget.appointmentId.isEmpty || widget.appointmentId == 'N/A') missingFields.add('Appointment ID');
    if (widget.physioName.isEmpty || widget.physioName == 'Unknown') missingFields.add('Physiotherapist Name');
    if (widget.patientName.isEmpty || widget.patientName == 'N/A') missingFields.add('Patient Name');
    if (_rating == 0) missingFields.add('Rating');

    if (missingFields.isNotEmpty) {
      setState(() {
        errorMessage = 'Please provide valid: ${missingFields.join(', ')}';
        isSubmitting = false;
      });
      return;
    }

    // Modified to handle HTTP request to backend
    setState(() {
      isSubmitting = true;
      errorMessage = '';
    });

    http.post(
      Uri.parse('http://${MyApp.ip}/capstone/submit_rating_feedback.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'appointment_id': widget.appointmentId,
        'physio_name': widget.physioName,
        'patient_name': widget.patientName,
        'rating': _rating.toInt(), // Convert to int for backend
        'feedback': feedback,
      }),
    ).then((response) {
      setState(() {
        isSubmitting = false;
      });

      if (response.statusCode != 200) {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
        });
        return;
      }

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        // Show confirmation dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Thank You!"),
            content: Text("Your rating and feedback has been submitted successfully."),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.indigo[900], // Change text color to indigo
                ),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushNamed(context, '/patient/dashboard'); // Navigate to dashboard
                },
                child: Text("Back to Home"),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          errorMessage = data['message'] ?? 'Failed to submit rating';
        });
      }
    }).catchError((e) {
      setState(() {
        isSubmitting = false;
        errorMessage = 'Error: $e';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rate Your Experience", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("How was your experience?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Write your feedback here...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            if (errorMessage.isNotEmpty) // Added to display error messages
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            if (errorMessage.isNotEmpty) // Added spacing for error message
              SizedBox(height: 10),
            ElevatedButton(
              onPressed: (isSubmitting || _rating == 0) // Disable button during submission or if no rating
                  ? null
                  : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: isSubmitting // Show loading indicator during submission
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Submit", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}