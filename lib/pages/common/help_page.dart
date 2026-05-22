import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

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
                              "Help & Support",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "We're here to help",
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
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                        children: [
                          // ── FAQ Section ──
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.quiz_rounded,
                                  color: _blue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Frequently Asked Questions",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _darkBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildFaqItem(
                            "How do I book an appointment?",
                            "Navigate to the Home screen, browse the list of doctors, select a doctor, and tap 'Book Now'. Choose your preferred service, date, and time slot.",
                            Icons.calendar_month_rounded,
                            const Color(0xFF4CAF50),
                          ),
                          _buildFaqItem(
                            "Can I cancel an appointment?",
                            "Yes, go to the 'Appointments' tab, find your upcoming appointment, and select cancel if the option is available.",
                            Icons.cancel_rounded,
                            const Color(0xFFEC407A),
                          ),
                          _buildFaqItem(
                            "How do I update my profile?",
                            "Open the side menu, tap on 'Profile', then click 'Edit Profile' to update your details and photo.",
                            Icons.person_rounded,
                            _blue,
                          ),
                          _buildFaqItem(
                            "How do I view my past appointments?",
                            "Go to the 'Appointments' tab from the bottom navigation bar to see all your past and upcoming bookings.",
                            Icons.history_rounded,
                            const Color(0xFFFFB300),
                          ),

                          const SizedBox(height: 28),

                          // ── Contact Section ──
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF4CAF50,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.support_agent_rounded,
                                  color: Color(0xFF4CAF50),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Contact Support",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _darkBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _contactCard(
                            icon: Icons.email_rounded,
                            color: _blue,
                            title: "Email Support",
                            subtitle: "support@doctime.com",
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _contactCard(
                            icon: Icons.phone_rounded,
                            color: const Color(0xFF4CAF50),
                            title: "Call Us",
                            subtitle: "+123 456 7890",
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _contactCard(
                            icon: Icons.chat_rounded,
                            color: const Color(0xFFFFB300),
                            title: "Live Chat",
                            subtitle: "Available 9 AM – 9 PM",
                            onTap: () {},
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

  Widget _buildFaqItem(
    String question,
    String answer,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _darkBlue,
            ),
          ),
          iconColor: color,
          collapsedIconColor: Colors.grey[400],
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
              width: 48,
              height: 48,
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
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _darkBlue,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
}
