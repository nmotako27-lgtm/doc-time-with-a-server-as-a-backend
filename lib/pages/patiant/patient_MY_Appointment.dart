import 'package:flutter/material.dart';
import 'package:flutter_3/mock_db.dart';
import 'package:flutter_3/pages/booking/booking_page.dart';

class PatientAppointmentsPage extends StatefulWidget {
  const PatientAppointmentsPage({super.key});

  @override
  State<PatientAppointmentsPage> createState() =>
      _PatientAppointmentsPageState();
}

class _PatientAppointmentsPageState extends State<PatientAppointmentsPage> {
  final Color dark = const Color(0xFF0A2540);
  final Color blue = const Color(0xFF1E88E5);
  final Color light = const Color(0xFFE3F2FD);
  final Color bg = const Color(0xFFF5F7FB);

  Color getStatusColor(String status) {
    switch (status) {
      case "Confirmed":
        return Colors.green;
      case "Done":
        return Colors.blue;
      case "Pending":
        return Colors.orange;
      case "Canceled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void cancelAppointment(String docId) {
    MockDB().collection('appointments').doc(docId).update({
      "status": "Canceled",
    });
  }

  void rebook(String doctorId, String doctorName, String serviceName) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => BookingPage(
      doctorId: doctorId,
      doctorName: doctorName,
      serviceName: serviceName,
      duration: 30, // Default duration
      price: 0.0, // Default price
    )));
  }

  String _getServiceImage(String name) {
    final n = name.toLowerCase();
    if (n.contains("clean")) return "assets/services/cleaning.png";
    if (n.contains("fill")) return "assets/services/filling.png";
    if (n.contains("brace")) return "assets/services/braces.png";
    return "assets/services/cleaning.png";
  }

  @override
  Widget build(BuildContext context) {
    final uid = MockDB().currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text("Please login"));
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bg, light.withOpacity(0.7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              // Container(
              //   padding: const EdgeInsets.all(20),
              //   child: Row(
              //     children: [
              //       Icon(Icons.calendar_month, color: dark),
              //       const SizedBox(width: 10),
              //       Text(
              //         "My Appointments",
              //         style: TextStyle(
              //           fontSize: 22,
              //           fontWeight: FontWeight.bold,
              //           color: dark,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Expanded(
                child: StreamBuilder(
                  stream: MockDB()
                      .collection('appointments')
                      .where('patientId', isEqualTo: uid)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No appointments yet 📅",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;

                        final service = data['service'] ?? '';
                        final time = data['time'] ?? '';
                        final date = data['date'] ?? '';
                        final status = data['status'] ?? 'Pending';
                        final doctor = data['doctorName'] ?? '';
                        final doctorId = data['doctorId'] ?? 'doctor_1';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      _getServiceImage(service),
                                      width: 55,
                                      height: 55,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          doctor,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: getStatusColor(
                                        status,
                                      ).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: getStatusColor(status),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 18,
                                    color: blue,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(time),

                                  const SizedBox(width: 20),

                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: blue,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(date),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (status != "Canceled" && status != "Done")
                                    TextButton(
                                      onPressed: () =>
                                          cancelAppointment(doc.id),
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  if (status == "Canceled" || status == "Done")
                                    TextButton(
                                      onPressed: () =>
                                          rebook(doctorId, doctor, service),
                                      child: const Text("Rebook"),
                                    ),
                                ],
                              ),
                            ],
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
    );
  }
}
