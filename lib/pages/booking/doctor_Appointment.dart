import 'package:flutter/material.dart';
import 'package:flutter_3/mock_db.dart';
import 'package:flutter_3/pages/home/home_page_for_doctor.dart'
    show DoctorHomePage;
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

class AppointmentsStyledPage extends StatefulWidget {
  const AppointmentsStyledPage({super.key});

  @override
  State<AppointmentsStyledPage> createState() =>
      _DoctorAppointmentsStyledPageState();
}

class _DoctorAppointmentsStyledPageState extends State<AppointmentsStyledPage> {
  final CollectionReference _appointmentsCollection = MockDB().collection(
    'appointments',
  );

  String? get currentDoctorId => MockDB().currentUser?.uid;

  static const _darkBlue = Color(0xFF0A2540);
  static const _blue = Color(0xFF1E88E5);
  static const _lightBlue = Color(0xFF64B5F6);

  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_darkBlue, _blue, _lightBlue, Color(0xFFE3F2FD)],
  );

  // ── Status ──
  Color _statusColor(String status) {
    switch (status) {
      case "Confirmed":
        return const Color(0xFF4CAF50);
      case "Done":
        return const Color(0xFF1E88E5);
      case "Pending":
        return const Color(0xFFFFB300);
      case "Canceled":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "Confirmed":
        return Icons.check_circle_rounded;
      case "Done":
        return Icons.done_all_rounded;
      case "Pending":
        return Icons.schedule_rounded;
      case "Canceled":
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Future<void> updateStatus(String docId, String newStatus) async {
    try {
      await _appointmentsCollection.doc(docId).update({"status": newStatus});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text("Marked as $newStatus"),
              ],
            ),
            backgroundColor: _statusColor(newStatus),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Update failed: $e"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> makeCall(String phone) async {
    if (Platform.isAndroid || Platform.isIOS) {
      final Uri callUri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri, mode: LaunchMode.externalApplication);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Would call $phone")));
    }
  }

  void _addNotes(BuildContext context, String docId, String currentNotes) {
    final notesController = TextEditingController(text: currentNotes);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.note_alt_rounded, color: _blue),
            SizedBox(width: 8),
            Text("Add Notes", style: TextStyle(fontSize: 18, color: _darkBlue)),
          ],
        ),
        content: TextField(
          controller: notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Write notes...",
            filled: true,
            fillColor: const Color(0xFFF0F7FF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _blue, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              _appointmentsCollection.doc(docId).update({
                "notes": notesController.text,
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _darkBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.08),
    ),
  );

  // ── Action chip ──
  Widget _actionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DoctorHomePage(),
                            ),
                          ),
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
                              "Appointments",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Manage your schedule",
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
                      child: Column(
                        children: [
                          // ── Doctor card ──
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                            child: FutureBuilder<DocumentSnapshot>(
                              future: MockDB()
                                  .collection('doctors')
                                  .doc(currentDoctorId)
                                  .get(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const SizedBox();
                                if (!snapshot.data!.exists)
                                  return const SizedBox();

                                final d =
                                    snapshot.data!.data()
                                        as Map<String, dynamic>;
                                final name = d['name'] ?? 'Doctor';
                                final specialty = d['specialty'] ?? 'Dentist';
                                final photoUrl = d['photoUrl'];

                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEBF4FF),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: _blue.withOpacity(0.15),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.white,
                                        backgroundImage:
                                            (photoUrl != null &&
                                                photoUrl.toString().isNotEmpty)
                                            ? NetworkImage(photoUrl)
                                            : null,
                                        child:
                                            (photoUrl == null ||
                                                photoUrl.toString().isEmpty)
                                            ? const Icon(
                                                Icons.person,
                                                size: 30,
                                                color: _blue,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Dr. $name",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: _darkBlue,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              specialty,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: _blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── Appointment list ──
                          Expanded(
                            child: currentDoctorId == null
                                ? const Center(
                                    child: Text("Please login to view"),
                                  )
                                : StreamBuilder<QuerySnapshot>(
                                    stream: _appointmentsCollection
                                        .where(
                                          'doctorId',
                                          isEqualTo: currentDoctorId,
                                        )
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return const Center(
                                          child: Text("Something went wrong"),
                                        );
                                      }
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      final docs = snapshot.requireData.docs;

                                      if (docs.isEmpty) {
                                        return Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.calendar_today_rounded,
                                                size: 60,
                                                color: Colors.grey[300],
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                "No appointments yet",
                                                style: TextStyle(
                                                  color: Colors.grey[400],
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return ListView.builder(
                                        padding: const EdgeInsets.fromLTRB(
                                          20,
                                          0,
                                          20,
                                          20,
                                        ),
                                        itemCount: docs.length,
                                        itemBuilder: (context, index) {
                                          final doc = docs[index];
                                          final a =
                                              doc.data()
                                                  as Map<String, dynamic>;
                                          final docId = doc.id;

                                          final patientName =
                                              a["patient"] ?? "Unknown Patient";
                                          final service =
                                              a["service"] ?? "Service";
                                          final status =
                                              a["status"] ?? "Pending";
                                          final time = a["time"] ?? "--:--";
                                          final date = a["date"] ?? "";
                                          final phone = a["phone"] ?? "";
                                          final notes = a["notes"] ?? "";

                                          final sColor = _statusColor(status);

                                          return Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                              border: Border.all(
                                                color: sColor.withOpacity(0.2),
                                                width: 0.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.04),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // ── Name + Status ──
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 44,
                                                        height: 44,
                                                        decoration: BoxDecoration(
                                                          color: _blue
                                                              .withOpacity(
                                                                0.08,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                14,
                                                              ),
                                                        ),
                                                        child: const Icon(
                                                          Icons.person_rounded,
                                                          color: _blue,
                                                          size: 24,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              patientName,
                                                              style: const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    _darkBlue,
                                                              ),
                                                            ),
                                                            Text(
                                                              service,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .grey[500],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 5,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: sColor
                                                              .withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              _statusIcon(
                                                                status,
                                                              ),
                                                              color: sColor,
                                                              size: 13,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              status,
                                                              style: TextStyle(
                                                                color: sColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  const SizedBox(height: 12),

                                                  // ── Time + Date ──
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFF0F7FF,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .access_time_rounded,
                                                          size: 16,
                                                          color: _blue,
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Text(
                                                          time,
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    _darkBlue,
                                                                fontSize: 13,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 16,
                                                        ),
                                                        const Icon(
                                                          Icons
                                                              .calendar_today_rounded,
                                                          size: 15,
                                                          color: _blue,
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Text(
                                                          date,
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  const SizedBox(height: 12),

                                                  // ── Action chips ──
                                                  SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                      children: [
                                                        if (status !=
                                                            'Canceled') ...[
                                                          _actionChip(
                                                            icon: Icons
                                                                .check_circle_rounded,
                                                            label: "Confirm",
                                                            color: const Color(
                                                              0xFF4CAF50,
                                                            ),
                                                            onTap: () =>
                                                                updateStatus(
                                                                  docId,
                                                                  "Confirmed",
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          _actionChip(
                                                            icon: Icons
                                                                .done_all_rounded,
                                                            label: "Done",
                                                            color: _blue,
                                                            onTap: () =>
                                                                updateStatus(
                                                                  docId,
                                                                  "Done",
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                        ],
                                                        _actionChip(
                                                          icon: Icons
                                                              .call_rounded,
                                                          label: "Call",
                                                          color: const Color(
                                                            0xFFFFB300,
                                                          ),
                                                          onTap: () {
                                                            if (phone
                                                                .isNotEmpty)
                                                              makeCall(phone);
                                                            else
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                    "No phone number",
                                                                  ),
                                                                ),
                                                              );
                                                          },
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        _actionChip(
                                                          icon: Icons
                                                              .note_alt_rounded,
                                                          label: "Notes",
                                                          color: const Color(
                                                            0xFF9C27B0,
                                                          ),
                                                          onTap: () =>
                                                              _addNotes(
                                                                context,
                                                                docId,
                                                                notes,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // ── Notes preview ──
                                                  if (notes
                                                      .toString()
                                                      .isNotEmpty) ...[
                                                    const SizedBox(height: 10),
                                                    Container(
                                                      width: double.infinity,
                                                      padding:
                                                          const EdgeInsets.all(
                                                            10,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFFF9F0FF,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        border: Border.all(
                                                          color: const Color(
                                                            0xFF9C27B0,
                                                          ).withOpacity(0.2),
                                                          width: 0.5,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Icon(
                                                            Icons.note_rounded,
                                                            size: 16,
                                                            color: Color(
                                                              0xFF9C27B0,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              notes,
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                  0xFF4A0072,
                                                                ),
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ],
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
}
