import 'package:flutter/material.dart';
import 'package:flutter_3/mock_db.dart';
import 'package:flutter_3/pages/patiant/edit_profile_patient.dart'
    show EditProfileScreen;
import 'package:flutter_3/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
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
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final User? user = MockDB().currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await MockDB()
            .collection('patients')
            .doc(user.uid)
            .get();
        if (!userDoc.exists) {
          userDoc = await MockDB().collection('users').doc(user.uid).get();
        }
        if (userDoc.exists) {
          setState(() {
            userData = userDoc.data() as Map<String, dynamic>;
            isLoading = false;
          });
          debugPrint("User Data Loaded: $userData");
          return;
        }
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
    if (mounted) setState(() => isLoading = false);
  }

  Widget _circle(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.08),
    ),
  );

  // icon per field
  IconData _fieldIcon(String label) {
    switch (label) {
      case "Name":
        return Icons.person_rounded;
      case "Email":
        return Icons.email_rounded;
      case "Phone":
        return Icons.phone_rounded;
      case "Address":
        return Icons.location_on_rounded;
      case "Birthdate":
        return Icons.cake_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _fieldColor(String label) {
    switch (label) {
      case "Name":
        return _blue;
      case "Email":
        return _blue;
      case "Phone":
        return const Color(0xFF4CAF50);
      case "Address":
        return const Color(0xFFEC407A);
      case "Birthdate":
        return const Color(0xFFFFB300);
      default:
        return _blue;
    }
  }

  // دالة مساعدة معالجة وعرض التاريخ بشكل آمن ومتوافق مع Dart
  String? _getBirthdateValue() {
    if (userData == null) return null;

    final rawDate = userData!['birthdate'] ?? userData!['birthDate'];

    if (rawDate == null) return null;

    if (rawDate is String) {
      return rawDate;
    }

    try {
      if (rawDate.runtimeType.toString().contains('Timestamp')) {
        return (rawDate as dynamic).toDate().toString().split(' ')[0];
      }
    } catch (_) {}

    return rawDate.toString();
  }

  @override
  Widget build(BuildContext context) {
    final String? photoUrl = userData?['photoUrl'];
    final String userRole = userData?['role'] ?? 'patient';

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
                              "My Profile",
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

                  // ── Avatar ──
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
                      backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                          ? NetworkImage(ApiService.getFullImageUrl(photoUrl))
                          : null,
                      child: (photoUrl == null || photoUrl.isEmpty)
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    userData?['name'] ?? "User",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData?['role'] ?? "Patient",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
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
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : userData == null
                          ? const Center(child: Text("No User Data Found"))
                          : SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                28,
                                20,
                                24,
                              ),
                              child: Column(
                                children: [
                                  // ── الحقول العامة المشتركة ──
                                  _infoCard("Name", userData?['name']),
                                  const SizedBox(height: 12),
                                  _infoCard("Email", userData?['email']),
                                  const SizedBox(height: 12),

                                  // ── حقول المريض (تظهر فقط لو الـ role هو patient) ──
                                  if (userRole == 'patient') ...[
                                    _infoCard("Phone", userData?['phone']),
                                    const SizedBox(height: 12),
                                    _infoCard("Address", userData?['address']),
                                    const SizedBox(height: 12),
                                    _infoCard(
                                      "Birthdate",
                                      _getBirthdateValue(),
                                    ),
                                    const SizedBox(height: 28),
                                  ],

                                  // ── زر التعديل ──
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditProfileScreen(
                                              currentPhotoUrl:
                                                  userData?['photoUrl'],
                                            ),
                                          ),
                                        ).then((_) => fetchUserData());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _darkBlue,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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

  Widget _infoCard(String label, String? value) {
    final color = _fieldColor(label);
    return Container(
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
            child: Icon(_fieldIcon(label), color: color, size: 22),
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
                  (value == null || value.trim().isEmpty) ? "N/A" : value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _darkBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
