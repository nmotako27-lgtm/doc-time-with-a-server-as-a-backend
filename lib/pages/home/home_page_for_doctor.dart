import 'package:flutter/material.dart';
import 'package:flutter_3/services/api_service.dart';
import 'package:flutter_3/mock_db.dart';
import 'package:flutter_3/pages/auth/login_page.dart' show LoginPage;
import 'package:flutter_3/pages/doctor/doctor_profile_page.dart'
    show DocProfile;
import 'package:flutter_3/pages/booking/doctor_Appointment.dart'
    show AppointmentsStyledPage;
import 'package:flutter_3/pages/common/about_page.dart';
import 'package:flutter_3/pages/common/help_page.dart';
import 'package:flutter_3/pages/doctor/doctor_manage_services.dart';

class DoctorHomePage extends StatelessWidget {
  const DoctorHomePage({super.key});

  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A2540),
      Color(0xFF1E88E5),
      Color(0xFF64B5F6),
      Color(0xFFE3F2FD),
    ],
  );

  Widget _circle(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.08),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final uid = MockDB().currentUser?.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: uid != null
          ? MockDB().collection('doctors').doc(uid).get()
          : null,
      builder: (context, snapshot) {
        String doctorName = "Doctor";
        String? photoUrl;
        String specialization = "Dentist Specialist";

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          doctorName = data['name'] ?? "Doctor";
          photoUrl = data['photoUrl'];
          specialization = data['specialty'] ?? "Dentist Specialist";
        }

        Widget buildAvatar(double radius) {
          if (photoUrl != null && photoUrl!.isNotEmpty) {
            return CircleAvatar(
              radius: radius,
              backgroundImage: NetworkImage(
                ApiService.getFullImageUrl(photoUrl!),
              ),
              onBackgroundImageError: (_, __) {},
              backgroundColor: Colors.white.withOpacity(0.2),
            );
          }
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(Icons.person, size: radius, color: Colors.white),
          );
        }

        return Scaffold(
          drawer: _buildDrawer(
            context,
            doctorName,
            specialization,
            buildAvatar,
          ),
          body: Container(
            decoration: const BoxDecoration(gradient: _gradient),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(top: -80, right: -50, child: _circle(260)),
                  Positioned(bottom: -40, left: -60, child: _circle(200)),
                  Column(
                    children: [
                      // ── HEADER ──
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Builder(
                              builder: (ctx) => GestureDetector(
                                onTap: () => Scaffold.of(ctx).openDrawer(),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.menu_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Welcome back 👋",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Dr. $doctorName",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── BODY ──
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.97),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Greeting
                                const Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        "Manage Your Clinic",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0A2540),
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        "Check your appointments and stay\nconnected with patients.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),
                                const SizedBox(height: 22),

                                // Action cards
                                _actionCard(
                                  context,
                                  icon: Icons.calendar_month_rounded,
                                  color: const Color(0xFF1E88E5),
                                  title: "Appointments",
                                  subtitle: "View & manage bookings",
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AppointmentsStyledPage(),
                                    ),
                                  ),
                                ),
                                _actionCard(
                                  context,
                                  icon: Icons.settings_suggest_rounded,
                                  color: const Color(0xFF4CAF50),
                                  title: "Manage Services",
                                  subtitle: "Update your offered services",
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const DoctorManageServicesPage(),
                                    ),
                                  ),
                                ),
                                _actionCard(
                                  context,
                                  icon: Icons.person_rounded,
                                  color: const Color(0xFFEC407A),
                                  title: "Profile",
                                  subtitle: "Edit your info & photo",
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const DocProfile(),
                                    ),
                                  ),
                                ),
                                _actionCard(
                                  context,
                                  icon: Icons.help_outline_rounded,
                                  color: const Color(0xFF8D6E63),
                                  title: "Help & About",
                                  subtitle: "Support & app info",
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const HelpPage(),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Main CTA button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AppointmentsStyledPage(),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.calendar_month_rounded,
                                      size: 22,
                                    ),
                                    label: const Text(
                                      "View Appointments",
                                      style: TextStyle(fontSize: 17),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0A2540),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A2540),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[350],
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(
    BuildContext context,
    String name,
    String spec,
    Widget Function(double) buildAvatar,
  ) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildAvatar(35),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    spec,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            _drawerTile(
              context,
              Icons.calendar_month,
              "Appointments",
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AppointmentsStyledPage()),
              ),
            ),
            _drawerTile(
              context,
              Icons.settings_suggest,
              "Manage Services",
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DoctorManageServicesPage(),
                ),
              ),
            ),
            _drawerTile(
              context,
              Icons.person,
              "Profile",
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DocProfile()),
              ),
            ),
            _drawerTile(
              context,
              Icons.info,
              "About",
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              ),
            ),
            _drawerTile(
              context,
              Icons.contact_support,
              "Help",
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpPage()),
              ),
            ),
            _drawerTile(
              context,
              Icons.logout,
              "Logout",
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _drawerTile(
    BuildContext ctx,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
