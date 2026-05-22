import 'package:flutter/material.dart';
import 'package:flutter_3/pages/booking/confirmation_page.dart';

class PatientInfoPage extends StatefulWidget {
  final String selectedDay;
  final String selectedDate;
  final String selectedTime;
  final String serviceName;
  final Function(String, String) onSubmit;

  const PatientInfoPage({
    super.key,
    required this.selectedDay,
    required this.selectedDate,
    required this.selectedTime,
    required this.serviceName,
    required this.onSubmit,
  });

  @override
  State<PatientInfoPage> createState() => _PatientInfoPageState();
}

class _PatientInfoPageState extends State<PatientInfoPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  String? nameError;
  String? phoneError;

  static const _darkBlue = Color(0xFF0A2540);
  static const _blue = Color(0xFF1E88E5);
  static const _lightBlue = Color(0xFF64B5F6);

  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_darkBlue, _blue, _lightBlue, Color(0xFFE3F2FD)],
  );

  Widget _circle(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.08),
    ),
  );

  bool _validate() {
    bool valid = true;

    if (nameController.text.trim().isEmpty) {
      nameError = "Name is required";
      valid = false;
    } else {
      nameError = null;
    }

    if (!RegExp(r"^01[0-9]{9}$").hasMatch(phoneController.text.trim())) {
      phoneError = "Invalid phone number";
      valid = false;
    } else {
      phoneError = null;
    }

    setState(() {});
    return valid;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
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
                  // HEADER
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
                              "Patient Info",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 2),

                            Text(
                              "Enter your details",
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

                  const SizedBox(height: 12),

                  // APPOINTMENT CARD
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _infoChip(
                          Icons.calendar_month_rounded,
                          "${widget.selectedDay}\n${widget.selectedDate}",
                        ),

                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.3),
                        ),

                        _infoChip(
                          Icons.access_time_rounded,
                          widget.selectedTime,
                        ),

                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.3),
                        ),

                        _infoChip(
                          Icons.medical_services_rounded,
                          widget.serviceName,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // BODY
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
                            _buildTextField(
                              "Full Name",
                              nameController,
                              icon: Icons.person_rounded,
                              color: const Color(0xFF673AB7),
                              error: nameError,
                            ),

                            _buildTextField(
                              "Phone Number",
                              phoneController,
                              icon: Icons.phone_rounded,
                              color: const Color(0xFF4CAF50),
                              keyboardType: TextInputType.phone,
                              error: phoneError,
                            ),

                            const SizedBox(height: 28),

                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!_validate()) return;

                                  await widget.onSubmit(
                                    nameController.text.trim(),
                                    phoneController.text.trim(),
                                  );

                                  if (!mounted) return;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ConfirmationPage(
                                        serviceName: widget.serviceName,
                                        day: widget.selectedDay,
                                        date: widget.selectedDate,
                                        time: widget.selectedTime,
                                        // name: nameController.text.trim(),
                                        // phone: phoneController.text.trim(),
                                      ),
                                    ),
                                  );
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
                                    Icon(Icons.check_circle_rounded, size: 20),

                                    SizedBox(width: 8),

                                    Text(
                                      "Confirm Booking",
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    required IconData icon,
    required Color color,
    TextInputType? keyboardType,
    String? error,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: color, fontSize: 13),
          errorText: error,
          prefixIcon: Icon(icon, color: color, size: 20),
          filled: true,
          fillColor: color.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: color, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),

        const SizedBox(height: 6),

        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
