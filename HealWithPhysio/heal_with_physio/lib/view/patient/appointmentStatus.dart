import 'package:flutter/material.dart';

class AppointmentStatusScreen extends StatelessWidget {
  final String status = 'Confirmed'; // "Confirmed", "Rejected", or "Pending"

  const AppointmentStatusScreen({super.key});  // Add the emergency flag
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Appointment Status", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon and status message based on appointment status
              if (status == 'Confirmed')
                Icon(
                  Icons.hourglass_empty,
                  size: 100,
                  color: Colors.orange,
                ),
              if (status == 'Rejected')
                Icon(
                  Icons.cancel,
                  size: 100,
                  color: Colors.red,
                ),
              if (status == 'Pending')
                Icon(
                  Icons.hourglass_empty,
                  size: 100,
                  color: Colors.orange,
                ),
              SizedBox(height: 20),
              Text(
                status == 'Confirmed'
                    ? "Confirmation Pending"
                    : status == 'Rejected'
                    ? "Appointment Rejected"
                    : "Appointment Pending",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                status == 'Confirmed'
                    ? "Your appointment has been sent successfully."
                    : status == 'Rejected'
                    ? "Unfortunately, your appointment request was rejected. \nRequest for another appointment by clicking below."
                    : "Your appointment is currently pending. Wait until the doctor confirm or reject your appointment.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              SizedBox(height: 30),
              if (status == 'Confirmed' || status == 'Rejected')
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/patient/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text("Back to Home", style: TextStyle(color: Colors.white,fontSize: 18)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
