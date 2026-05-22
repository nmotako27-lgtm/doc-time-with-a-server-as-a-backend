import 'package:flutter/material.dart';
import 'package:flutter_3/mock_db.dart';
import 'package:flutter_3/pages/booking/booking_page.dart';

class ServiceSelectionPage extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  const ServiceSelectionPage({
    super.key,
    this.doctorId = 'doctor_1',
    this.doctorName = 'Dr. Ahmed Hassan',
  });

  @override
  State<ServiceSelectionPage> createState() => _ServiceSelectionPageState();
}

class _ServiceSelectionPageState extends State<ServiceSelectionPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _enabledServices = [];

  final List<String> _masterServices = [
    "Check up",
    "Cleaning",
    "Whitening",
    "Braces",
    "Implants",
    "Crown",
    "Filling",
    "Orthodontics",
  ];

  IconData _serviceIcon(String name) {
    switch (name) {
      case "Check up": return Icons.health_and_safety_rounded;
      case "Cleaning": return Icons.clean_hands_rounded;
      case "Whitening": return Icons.auto_awesome_rounded;
      case "Braces": return Icons.straighten_rounded;
      case "Implants": return Icons.medical_services_rounded;
      case "Crown": return Icons.workspace_premium_rounded;
      case "Filling": return Icons.healing_rounded;
      case "Orthodontics": return Icons.straighten_rounded;
      default: return Icons.medical_services_rounded;
    }
  }

  Color _serviceColor(String name) {
    switch (name) {
      case "Check up": return const Color(0xFF4CAF50);
      case "Cleaning": return const Color(0xFF26C6DA);
      case "Whitening": return const Color(0xFFEC407A);
      case "Braces": return const Color(0xFFFFB300);
      case "Implants": return const Color(0xFF1976D2);
      case "Crown": return const Color(0xFF8D6E63);
      case "Filling": return const Color(0xFF42A5F5);
      case "Orthodontics": return const Color(0xFFFFB300);
      default: return const Color(0xFF1E88E5);
    }
  }

  String _serviceDescription(String name) {
    switch (name) {
      case "Check up": return "Routine dental check and cleaning.";
      case "Cleaning": return "Deep cleaning for healthy teeth.";
      case "Whitening": return "Brighten your smile safely.";
      case "Braces": return "Metal and ceramic braces.";
      case "Implants": return "Replace missing teeth with implants.";
      case "Crown": return "Protect and strengthen damaged teeth.";
      case "Filling": return "Restore decayed teeth with filling.";
      case "Orthodontics": return "Teeth alignment and braces check.";
      default: return "Dental treatment.";
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDoctorServices();
  }

  Future<void> _fetchDoctorServices() async {
    try {
      final docSnapshot = await MockDB().collection('doctors').doc(widget.doctorId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey('services')) {
          final loadedServices = data['services'] as Map<String, dynamic>;
          List<Map<String, dynamic>> tempServices = [];
          
          for (var serviceName in _masterServices) {
            if (loadedServices.containsKey(serviceName)) {
              final config = loadedServices[serviceName] as Map<String, dynamic>;
              if (config['enabled'] == true) {
                tempServices.add({
                  "name": serviceName,
                  "duration": "${config['duration'] ?? 30} min",
                  "rawDuration": config['duration'] ?? 30,
                  "price": "EGP ${config['price'] ?? 0}",
                  "rawPrice": (config['price'] as num?)?.toDouble() ?? 0.0,
                  "description": _serviceDescription(serviceName),
                  "icon": _serviceIcon(serviceName),
                  "color": _serviceColor(serviceName),
                });
              }
            }
          }
          if (mounted) {
            setState(() {
              _enabledServices = tempServices;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching services: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.08),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A2540),
              Color(0xFF1E88E5),
              Color(0xFF64B5F6),
              Color(0xFFE3F2FD),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -80,
                right: -50,
                child: _circle(size.width * 0.7),
              ),
              Positioned(
                bottom: -40,
                left: -60,
                child: _circle(size.width * 0.5),
              ),
              Column(
                children: [
                  // ===== HEADER =====
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                        const Column(
                          children: [
                            Text(
                              "Dental Services",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Choose your treatment",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ===== BODY =====
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
                      child: _isLoading 
                          ? const Center(child: CircularProgressIndicator())
                          : _enabledServices.isEmpty
                              ? const Center(
                                  child: Text(
                                    "This doctor hasn't configured any services yet.",
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.all(22),
                                  itemCount: _enabledServices.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 22,
                                    crossAxisSpacing: 18,
                                    childAspectRatio: 0.72,
                                  ),
                                  itemBuilder: (context, index) {
                                    return ServiceCard(
                                      service: _enabledServices[index],
                                      doctorId: widget.doctorId,
                                      doctorName: widget.doctorName,
                                    );
                                  },
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

class ServiceCard extends StatefulWidget {
  final Map<String, dynamic> service;
  final String doctorId;
  final String doctorName;

  const ServiceCard({
    super.key,
    required this.service,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final Color color = widget.service['color'];

    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapCancel: () => setState(() => isPressed = false),
      onTapUp: (_) {
        setState(() => isPressed = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingPage(
              doctorId: widget.doctorId,
              doctorName: widget.doctorName,
              serviceName: widget.service['name'],
              duration: widget.service['rawDuration'] ?? 30,
              price: widget.service['rawPrice'] ?? 0.0,
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.identity()..scale(isPressed ? 0.96 : 1.0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF8FBFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== ICON =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: color.withOpacity(0.12),
                  ),
                  child: Icon(widget.service['icon'], size: 32, color: color),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.grey[400],
                ),
              ],
            ),
            const Spacer(),

            // ===== NAME =====
            Text(
              widget.service['name'],
              maxLines: 2,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2540),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),

            // ===== DESCRIPTION =====
            Text(
              widget.service['description'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),

            // ===== BOTTOM INFO =====
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 14, color: color),
                      const SizedBox(width: 5),
                      Text(
                        widget.service['duration'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  widget.service['price'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
