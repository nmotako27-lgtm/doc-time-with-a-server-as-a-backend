import 'package:flutter/material.dart';
import 'package:flutter_3/services/api_service.dart';
import 'package:flutter_3/mock_db.dart';
import 'package:flutter_3/pages/auth/login_page.dart' show LoginPage;
import 'package:flutter_3/pages/patiant/patient_MY_Appointment.dart';
import 'package:flutter_3/pages/patiant/patientprofile.dart' show ProfileScreen;
import 'package:flutter_3/pages/services/services_selection_page.dart'
    show ServiceSelectionPage;
import 'package:flutter_3/pages/common/about_page.dart';
import 'package:flutter_3/pages/common/help_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  Future<DocumentSnapshot>? _patientFuture;

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

  final List<Widget> _pages = [
    const HomeTab(),
    const PatientAppointmentsPage(),
  ];

  @override
  void initState() {
    super.initState();
    final uid = MockDB().currentUser?.uid;
    if (uid != null) {
      _patientFuture = MockDB().collection('patients').doc(uid).get();
    }
  }

  Widget _circle(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.08),
    ),
  );

  Widget _buildProfileImage(String? photoUrl, double size) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          ApiService.getFullImageUrl(photoUrl),
          width: size * 2,
          height: size * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.person, size: size, color: Colors.white),
        ),
      );
    }
    return Icon(Icons.person, size: size, color: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _patientFuture,
      builder: (context, snapshot) {
        String patientName = "Patient";
        String? photoUrl;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          patientName = data['name'] ?? "Patient";
          photoUrl = data['photoUrl'];
        }

        return Scaffold(
          extendBody: true,
          drawer: _buildDrawer(context, patientName, photoUrl),
          body: Container(
            decoration: const BoxDecoration(gradient: _gradient),
            child: SafeArea(
              bottom: false,
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
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Builder(
                              builder: (ctx) => _iconBtn(
                                Icons.menu_rounded,
                                onTap: () => Scaffold.of(ctx).openDrawer(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Good morning 👋",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    _currentIndex == 0
                                        ? "DocTime"
                                        : "My Appointments",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _iconBtn(
                              Icons.notifications_none_rounded,
                              onTap: () {},
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfileScreen(),
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                child: _buildProfileImage(photoUrl, 20),
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
                          child: _pages[_currentIndex],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── BOTTOM NAV ──
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0A2540).withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor: const Color(0xFF1E88E5),
              unselectedItemColor: Colors.grey[400],
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              elevation: 0,
              onTap: (i) => setState(() => _currentIndex = i),
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.grid_view_rounded),
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.calendar_today_rounded),
                  ),
                  label: "Appointments",
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _iconBtn(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context, String name, String? photoUrl) {
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
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: _buildProfileImage(photoUrl, 35),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Patient",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            _drawerTile(
              Icons.person_outline_rounded,
              "Profile",
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              ),
            ),
            _drawerTile(
              Icons.info_outline_rounded,
              "About Us",
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              ),
            ),
            _drawerTile(
              Icons.help_outline_rounded,
              "Help & Support",
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpPage()),
              ),
            ),
            const Divider(
              color: Colors.white24,
              thickness: 0.5,
              indent: 16,
              endIndent: 16,
            ),
            _drawerTile(
              Icons.logout_rounded,
              "Logout",
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
              color: Colors.redAccent[100],
            ),
          ],
        ),
      ),
    );
  }

  ListTile _drawerTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}

// ── HOME TAB ──
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF0A2540);
    const primaryBlue = Color(0xFF1E88E5);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      children: [
        const Text(
          "Find Your Doctor",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darkBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Book an appointment with top specialists",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 16),

        // Search bar
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        //   decoration: BoxDecoration(
        //     color: const Color(0xFFF0F7FF),
        //     borderRadius: BorderRadius.circular(18),
        //   ),
        //   child: Row(
        //     children: [
        //       const Icon(Icons.search_rounded, color: primaryBlue, size: 20),
        //       const SizedBox(width: 10),
        //       Text(
        //         "Search doctors, specialties...",
        //         style: TextStyle(color: Colors.grey[400], fontSize: 14),
        //       ),
        //     ],
        //   ),
        // ),
        const SizedBox(height: 20),

        StreamBuilder<QuerySnapshot>(
          stream: MockDB().collection('doctors').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return const Center(child: Text("Something went wrong"));
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No doctors found"));
            }

            final doctors = snapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index].data() as Map<String, dynamic>;
                final name = doctor['name'] ?? 'Doctor Name';
                final specialty = doctor['specialty'] ?? 'Dentist Specialist';
                final photoUrl = doctor['photoUrl'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: primaryBlue.withOpacity(0.1),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: darkBlue.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: (photoUrl != null && photoUrl != "")
                            ? Image.network(
                                ApiService.getFullImageUrl(photoUrl),
                                width: 82,
                                height: 82,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _avatarPlaceholder(),
                              )
                            : _avatarPlaceholder(),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dr. $name",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: darkBlue,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              specialty,
                              style: const TextStyle(
                                fontSize: 12,
                                color: primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber[600],
                                  size: 15,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${doctor['experience'] ?? '5'}+ Yrs",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.access_time_rounded,
                                  color: Colors.grey[400],
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    doctor['workingHours'] ?? "9 AM – 9 PM",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ServiceSelectionPage(
                                      doctorId: doctors[index].id,
                                      doctorName: name,
                                    ),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0A2540),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 9,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  "Book Now",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _avatarPlaceholder() => Container(
    width: 82,
    height: 82,
    decoration: BoxDecoration(
      color: const Color(0xFF1E88E5).withOpacity(0.07),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Icon(Icons.person_rounded, size: 38, color: Color(0xFF1E88E5)),
  );
}
