import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------- AUTH ----------------
import 'pages/auth/login_page.dart';
import 'pages/auth/RoleSelection_Page.dart';
import 'pages/auth/patientRegister_Page.dart';

// ---------------- HOME ----------------
import 'pages/home/home_page.dart';
import 'pages/home/home_page_for_doctor.dart';

// ---------------- BOOKING ----------------
import 'pages/booking/booking_page.dart';
import 'pages/booking/booking_details_page.dart';
import 'pages/booking/confirmation_page.dart';
import 'pages/booking/doctor_Appointment.dart';

// ---------------- SERVICES ----------------
// import 'pages/services/check_up_cleaning.dart';
// import 'pages/services/Crown_Page.dart';
// import 'pages/services/Filling_page.dart';
// import 'pages/services/Implant_Page.dart';
// import 'pages/services/Orthodontics_Page.dart';
// import 'pages/services/Whitening_Page.dart';
import 'pages/services/services_selection_page.dart';

// ---------------- PATIENT ----------------
import 'pages/patiant/edit_profile_patient.dart';
import 'pages/patiant/patient_inf_page.dart';
import 'pages/patiant/patient_MY_Appointment.dart';
import 'pages/patiant/patientprofile.dart';

// ---------------- DOCTOR ----------------
import 'pages/doctor/edit_profile_doctor.dart';
import 'pages/doctor/doctor_profile_page.dart';
import 'pages/doctor/doctor_selection_page.dart';

// ---------------- SPLASH ----------------
import 'pages/splash/Splashscreen_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable Google Fonts runtime fetching to prevent crashes on mobile without internet
  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/splash",

      routes: {
        // SPLASH
        "/splash": (context) => Splashscreen(),

        // AUTH
        "/login": (context) => LoginPage(),
        "/role": (context) => RoleSelectionPage(),
        "/patientRegister": (context) => RegisterPage(),
        "/doctorRegister": (context) => RegisterPage(),

        // HOME
        "/home": (context) => HomePage(),
        "/doctorHome": (context) => DoctorHomePage(),

        // SERVICES
        // "/checkupCleaning": (context) => Check_up_Cleaning(),
        // "/crownPage": (context) => Crown_Page(),
        // "/fillingPage": (context) => Filling(),
        // "/implantPage": (context) => Implant_page(),
        // "/orthodonticsPage": (context) => Orthodontics_Page(),
        // "/whiteningPage": (context) => Whitening_Page(),
        "/services": (context) => ServiceSelectionPage(),

        // BOOKING
        "/bookingPage": (context) => BookingPage(),
        "/doctorAppointments": (context) => AppointmentsStyledPage(),
        "/patientAppointments": (context) => PatientAppointmentsPage(),

        // PROFILE
        "/doctorProfile": (context) => DocProfile(),
        "/patientProfile": (context) => ProfileScreen(),
        "/doctor-selection": (context) => DoctorSelectionPage(),

        "/editDoctor": (context) => EditProfilePage(
          name: '',
          specialization: '',
          degree: '',
          phone: '',
          email: '',
          time: '',
          address: '',
        ),
        "/editPatient": (context) => EditProfileScreen(),
      },

      // الصفحات اللي بتاخد بيانات (arguments)
      onGenerateRoute: (settings) {
        if (settings.name == "/bookingDetails") {
          final args = settings.arguments as Map;
          return MaterialPageRoute(
            builder: (_) => BookingDetailsPage(
              visitType: args["visitType"],
              date: args["date"],
              time: args["time"],
              patientName: args["patientName"],
            ),
          );
        }

        if (settings.name == "/confirmation") {
          final args = settings.arguments as Map;
          return MaterialPageRoute(
            builder: (_) => ConfirmationPage(
              serviceName: args["serviceName"],
              day: args["day"],
              date: args["date"],
              time: args["time"],
              // name: args["name"],
              // phone: args["phone"],
            ),
          );
        }

        if (settings.name == "/patientInfo") {
          final args = settings.arguments as Map;
          return MaterialPageRoute(
            builder: (_) => PatientInfoPage(
              selectedDay: args["selectedDay"],
              selectedDate: args["selectedDate"],
              selectedTime: args["selectedTime"],
              serviceName: args["serviceName"],
              onSubmit: args["onSubmit"],
            ),
          );
        }

        return null;
      },
    );
  }
}
