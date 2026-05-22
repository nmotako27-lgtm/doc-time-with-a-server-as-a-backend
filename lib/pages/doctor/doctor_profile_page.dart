import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_3/mock_db.dart';
import 'package:flutter_3/pages/doctor/edit_profile_doctor.dart'
    show EditProfilePage;

class DocProfile extends StatefulWidget {
  const DocProfile({super.key});

  @override
  State<DocProfile> createState() => _DocProfileState();
}

class _DocProfileState extends State<DocProfile> {
  Map<String, dynamic>? doctorData;
  bool isLoading = true;

  static const _darkBlue = Color(0xFF0A2540);
  static const _blue = Color(0xFF1E88E5);
  static const _lightBlue = Color(0xFF64B5F6);

  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_darkBlue, _blue, _lightBlue, Color(0xFFE3F2FD)],
  );

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
  }

  Future<void> _fetchDoctorData() async {
    final user = MockDB().currentUser;
    if (user != null) {
      try {
        final doc = await MockDB().collection('doctors').doc(user.uid).get();
        if (doc.exists) {
          debugPrint("Doctor Data from DB: ${doc.data()}");
          setState(() {
            doctorData = doc.data();
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } catch (e) {
        debugPrint("Error fetching doctor data: $e");
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
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

  void _showSnack(String msg, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.info_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(msg),
          ],
        ),
        backgroundColor: success ? const Color(0xFF4CAF50) : _blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    String safe(String? val, String fallback) {
      if (val == null || val.trim().isEmpty) return fallback;
      return val;
    }

    // ── جلب البيانات الحقيقية المتطابقة مع الـ DB ──
    final String name = safe(doctorData?['name'], "Doctor");
    final String specialization = safe(doctorData?['specialty'], "Specialist");
    final int experience = doctorData?['experience'] ?? 0;
    final String time = safe(doctorData?['workingHours'], "Not Set");
    final String email = safe(doctorData?['email'], "No Email");
    final String bio = safe(doctorData?['bio'], "No Bio Provided");

    return Scaffold(
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
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Column(
                          children: [
                            Text(
                              "Doctor Profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Your information",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),

                  // ── AVATAR ──
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const ClipOval(
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // اسم الطبيب الرئيسي أعلى الصفحة
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // تخصص الطبيب الرئيسي أعلى الصفحة
                  Text(
                    specialization,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 18),

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
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                        child: Column(
                          children: [
                            // 1. كارت الاسم (Name) القادم من الـ DB
                            _infoCard(
                              icon: Icons.person_rounded,
                              label: "Full Name",
                              value: name,
                              color: const Color(0xFF673AB7),
                            ),
                            const SizedBox(height: 12),

                            // 2. البريد الإلكتروني (email)
                            _infoCard(
                              icon: Icons.email_rounded,
                              label: "Email",
                              value: email,
                              color: _blue,
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: email));
                                _showSnack("Email copied");
                              },
                            ),
                            const SizedBox(height: 12),

                            // 3. سنوات الخبرة (experience)
                            _infoCard(
                              icon: Icons.workspace_premium_rounded,
                              label: "Experience",
                              value: "$experience Years",
                              color: const Color(0xFF4CAF50),
                            ),
                            const SizedBox(height: 12),

                            // 4. ساعات العمل (workingHours)
                            _infoCard(
                              icon: Icons.schedule_rounded,
                              label: "Working Hours",
                              value: time,
                              color: const Color(0xFFFFB300),
                            ),
                            const SizedBox(height: 12),

                            // 5. السيرة الذاتية (bio)
                            _infoCard(
                              icon: Icons.description_rounded,
                              label: "Bio",
                              value: bio,
                              color: const Color(0xFFEC407A),
                            ),

                            const SizedBox(height: 28),

                            // ── زر التعديل ──
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditProfilePage(
                                        name: name,
                                        specialization: specialization,
                                        email: email,
                                        time: time,
                                        degree: "$experience Years",
                                        address: bio,
                                        phone: "",
                                        currentPhotoUrl: null,
                                      ),
                                    ),
                                  ).then((_) => _fetchDoctorData());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _darkBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.edit_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      "Edit Profile",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
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
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _darkBlue,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.copy_rounded, size: 18, color: Colors.grey[350]),
          ],
        ),
      ),
    );
  }
}
