import 'package:flutter/material.dart';
import 'package:heal_with_physio/view/patient/bookTimeClinic.dart';
import 'package:heal_with_physio/view/patient/bookTimeHome.dart';
import 'package:heal_with_physio/view/patient/pastAppointmentDetail.dart';
import 'package:heal_with_physio/view/physiotherapist/viewRatingFeedback.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Role Selection
import 'view/role.dart';

// Patient Screens
import 'view/patient/login.dart';
import 'view/patient/forgotPassword.dart';
import 'view/patient/changePassword.dart';
import 'view/patient/signup.dart';
import 'view/patient/dashboard.dart';
import 'view/patient/manageProfile.dart';
import 'view/patient/pastAppointment.dart';
import 'view/patient/aboutUs.dart';
import 'view/patient/doctorDetail.dart';
import 'view/patient/bookDateType.dart';
import 'view/patient/bookTime.dart';
import 'view/patient/previewSlot.dart';
import 'view/patient/confirmation.dart';
import 'view/patient/appointmentStatus.dart';
import 'view/patient/ratingFeedback.dart';
import 'view/patient/logout_success.dart';
import 'view/patient/signout_success.dart';

// Physiotherapist Screens
import 'view/physiotherapist/login.dart';
import 'view/physiotherapist/forgotPassword.dart';
import 'view/physiotherapist/changePassword.dart';
import 'view/physiotherapist/signup.dart';
import 'view/physiotherapist/dashboard.dart';
import 'view/physiotherapist/manageProfile.dart';
import 'view/physiotherapist/aboutUs.dart';
import 'view/physiotherapist/confirmedAppointments.dart';
import 'view/physiotherapist/rejectedAppointments.dart';
import 'view/physiotherapist/pendingAppointments.dart';
import 'view/physiotherapist/allAppointments.dart';
import 'view/physiotherapist/logout_success.dart';
import 'view/physiotherapist/signout_success.dart';
import 'view/physiotherapist/reject_reason.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  //  static String ip = "192.168.1.6";  // tisha
  static String ip = "192.168.131.72";  //keshwi
  // static String ip = "172.20.10.2";  //parth phone
  // static String ip = "192.168.1.14";  //parth wifi
  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>(); // Added RouteObserver
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Heal with Physio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: [routeObserver], // Added navigatorObservers
      initialRoute: '/',
      routes: {
        // Role selection
        '/': (context) => RolePage(),

        // Patient routes
        '/patient/login': (context) => LoginScreen(),
        '/patient/forgotPassword': (context) => ForgotPasswordScreen(),
        '/patient/changePassword': (context) => ChangePasswordScreen(email: ''),
        '/patient/signup': (context) => SignupScreen(),
        '/patient/dashboard': (context) => DashboardScreen(userData: {}),
        '/patient/manageProfile': (context) => ManageProfile(),
        '/patient/pastAppointment': (context) => PastAppointmentScreen(),
        '/patient/aboutUs': (context) => AboutUsScreen(),
        '/patient/pastAppointmentDetail': (context) {
          // Extract appointment from route arguments
          final appointment = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return PastAppointmentDetailScreen(
            appointment: appointment ?? {}, // Fallback to empty map if null
          );
        },
        '/patient/doctorDetail': (context) => DoctorDetailScreen(
          name: '',
          specialization: '',
          image: '',
          email: '',
          gender: '',
          qualification: '',
          experience: '',
          contactNo: '',
        ),
        '/patient/bookDateType': (context) => BookDateTypeScreen(),

        '/patient/bookTime': (context) => BookTimeScreen(),
        '/patient/bookTimeHome': (context) => BookTimeHome(),
        '/patient/bookTimeClinic': (context) => BookTimeClinic(),


        '/patient/previewSlot': (context) => PreviewSlotScreen(), // ✅ Route causing previous error
        '/patient/confirmation': (context) => ConfirmationScreen(),
        '/patient/appointmentStatus': (context) => AppointmentStatusScreen(),
        '/patient/ratingFeedback': (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args == null) {
        // Handle null arguments by redirecting or showing an error
        return Scaffold(
          body: Center(child: Text('Error: No appointment details provided')),
        );
      }
      return RatingFeedbackScreen(
        appointmentId: args['appointment_id']?.toString() ?? 'N/A',
        physioName: args['physio_name']?.toString() ?? 'Unknown',
        patientName: args['patient_name']?.toString() ?? 'N/A',
      );
    },
        '/patient/logout_success': (context) => LogoutPage(),
        '/patient/signout_success': (context) => SignoutPage(),

        // Physiotherapist routes
        '/physio/login': (context) => LoginScreenPhysio(),
        '/physio/forgotPassword': (context) => ForgotPasswordScreenPhysio(),
        '/physio/changePassword': (context) => ChangePasswordScreenPhysio(),
        '/physio/signup': (context) => SignupScreenPhysio(),
        '/physio/dashboard': (context) => DashboardScreenPhysio(userData: {}),
        '/physio/manageProfile': (context) => ManageProfileScreenPhysio(),
        '/physio/aboutUs': (context) => AboutUsScreenPhysio(),
        '/physio/confirmedAppointments': (context) => ConfirmedAppointmentsScreenPhysio(),
        '/physio/rejectedAppointments': (context) => RejectedAppointmentsScreenPhysio(),
        '/physio/pendingAppointments': (context) => PendingAppointmentsScreenPhysio(),
        '/physio/allAppointments': (context) => AllAppointmentsScreenPhysio(),
        '/physio/logout_success': (context) => LogoutPagePhysio(),
        '/physio/signout_success': (context) => SignoutPagePhysio(),
        '/physio/reject_reason': (context) => RejectReasonScreen(appointmentId: 102,),
        '/physio/view_rating_feedback': (context) => ViewRatingFeedback(),
      },
    );
  }
}