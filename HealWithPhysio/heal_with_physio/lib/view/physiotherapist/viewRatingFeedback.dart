import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heal_with_physio/main.dart'; // To access MyApp.ip

class ViewRatingFeedback extends StatefulWidget {
  const ViewRatingFeedback({Key? key}) : super(key: key);

  @override
  _ViewRatingFeedbackState createState() => _ViewRatingFeedbackState();
}

class _ViewRatingFeedbackState extends State<ViewRatingFeedback> {
  // Dynamic list to store fetched feedback
  List<Map<String, dynamic>> fetchedFeedbackList = [];
  bool isLoading = true;
  String errorMessage = '';
  double? averageRating; // Added to store average rating

  @override
  void initState() {
    super.initState();
    _fetchPhysioData();
  }

  Future<void> _fetchPhysioData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Get username from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');

      if (username == null || username.isEmpty) {
        setState(() {
          errorMessage = 'No user logged in';
          isLoading = false;
        });
        return;
      }

      // Fetch physiotherapist name and average rating
      final nameResponse = await http.post(
        Uri.parse('http://${MyApp.ip}/capstone/get_average_rating.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (nameResponse.statusCode != 200) {
        setState(() {
          errorMessage = 'Failed to fetch physiotherapist name: Server error ${nameResponse.statusCode}';
          isLoading = false;
        });
        return;
      }

      final nameData = jsonDecode(nameResponse.body);

      if (nameData['status'] != 'success' || nameData['name'] == null) {
        setState(() {
          errorMessage = nameData['message'] ?? 'Physiotherapist not found';
          isLoading = false;
        });
        return;
      }

      // Store average rating
      setState(() {
        averageRating = (nameData['average_rating'] != null)
            ? double.tryParse(nameData['average_rating'].toString()) ?? 0.0
            : 3.0;
      });

      // Fetch feedback for the physiotherapist
      final feedbackResponse = await http.post(
        Uri.parse('http://${MyApp.ip}/capstone/get_physio_feedback.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'physio_name': nameData['name']}),
      );

      if (feedbackResponse.statusCode != 200) {
        setState(() {
          errorMessage = 'Failed to fetch feedback: Server error ${feedbackResponse.statusCode}';
          isLoading = false;
        });
        return;
      }

      final feedbackData = jsonDecode(feedbackResponse.body);

      if (feedbackData['status'] != 'success' || feedbackData['feedback'] == null) {
        setState(() {
          errorMessage = feedbackData['message'] ?? 'No feedback available';
          isLoading = false;
        });
        return;
      }

      setState(() {
        fetchedFeedbackList = List<Map<String, dynamic>>.from(feedbackData['feedback']);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ratings & Feedback'),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                  ),
                )
              : Column(
                  children: [
                    // Static average rating box
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: averageRating != null && averageRating! < 3
                            ? Colors.red
                            : Colors.green,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Your rating is ${averageRating?.toStringAsFixed(1) ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            averageRating != null && averageRating! < 3
                                ? 'Patients are not satisfied. Kindly improve your services.'
                                : 'Great job! Patients are satisfied. Keep up the good work!',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Scrollable feedback list
                    Expanded(
                      child: fetchedFeedbackList.isEmpty
                          ? const Center(
                              child: Text(
                                'No feedback available',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: fetchedFeedbackList.length,
                              itemBuilder: (context, index) {
                                final feedback = fetchedFeedbackList[index];
                                return Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              feedback['patient_name'] ?? 'Unknown',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1A237E),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  feedback['rating'].toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Appointment ID: ${feedback['appointment_id'] ?? 'N/A'}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          feedback['feedback'] ?? 'No feedback provided',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}