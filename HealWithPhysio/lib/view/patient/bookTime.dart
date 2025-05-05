import 'package:flutter/material.dart';

class BookTimeScreen extends StatefulWidget {
  const BookTimeScreen({super.key});

  @override
  _BookTimeScreenState createState() => _BookTimeScreenState();
}

class _BookTimeScreenState extends State<BookTimeScreen> {
  String? selectedSlot;
  bool isEmergency = false;
  Map<String, dynamic>? bookingArgs;

  final List<String> timeSlots = [
    "9:00 AM - 10:00 AM",
    "10:30 AM - 11:30 AM",
    "12:00 PM - 1:00 PM",
    "1:30 PM - 2:30 PM",
    "3:00 PM - 4:00 PM",
    "4:30 PM - 5:30 PM",
    "6:00 PM - 7:00 PM",
  ];

  void navigateToPreview() {
    Navigator.pushNamed(
      context,
      '/patient/previewSlot',
      arguments: {
        'selectedDate': bookingArgs!['appointment_date'],
        'visitType': bookingArgs!['consulting_type'],
        'selectedSlot': selectedSlot,
        'isEmergency': isEmergency,
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bookingArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
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
        child: bookingArgs == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text("Select Time Slot", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: timeSlots.map((slot) {
                final isSelected = slot == selectedSlot;
                return GestureDetector(
                  onTap: () => setState(() => selectedSlot = slot),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.indigo[900] : Colors.white,
                      border: Border.all(color: Colors.indigo, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      slot,
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
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
            const Spacer(),
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
