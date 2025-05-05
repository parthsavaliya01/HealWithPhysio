import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Us",
          style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "About HealWithPhysio",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                "At HealWithPhysio, we are dedicated to making quality physiotherapy accessible and convenient by connecting patients with experienced physiotherapists who offer at-home treatment services.\n\nFinding reliable physiotherapy care at home can be challenging, and we aim to bridge this gap by providing a seamless platform where patients can easily search for, compare, and book appointments with certified professionals based on their expertise and availability.\n\nWith a user-friendly interface and a commitment to personalized care, HealWithPhysio ensures that patients receive effective treatment in the comfort of their own homes.",
                style: TextStyle(fontSize: 16.0, color: Colors.black87),
              ),
              SizedBox(height: 16.0),
              Text(
                "Contact Us",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                "Email: healwithphysio@gmail.com\nPhone: +91 11111 00000",
                style: TextStyle(fontSize: 16.0, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
