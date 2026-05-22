import 'package:flutter/material.dart';
import 'package:flutter_3/mock_db.dart';

class DoctorManageServicesPage extends StatefulWidget {
  const DoctorManageServicesPage({super.key});

  @override
  State<DoctorManageServicesPage> createState() =>
      _DoctorManageServicesPageState();
}

class _DoctorManageServicesPageState extends State<DoctorManageServicesPage> {
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

  final Map<String, Map<String, dynamic>> _serviceConfig = {};
  bool _isLoading = true;

  // ── ألوان موحدة ──
  static const _darkBlue = Color(0xFF0A2540);
  static const _blue = Color(0xFF1E88E5);
  static const _lightBlue = Color(0xFF64B5F6);

  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_darkBlue, _blue, _lightBlue, Color(0xFFE3F2FD)],
  );

  // أيقونة لكل خدمة
  IconData _serviceIcon(String name) {
    switch (name) {
      case "Check up":
        return Icons.health_and_safety_rounded;
      case "Cleaning":
        return Icons.clean_hands_rounded;
      case "Whitening":
        return Icons.auto_awesome_rounded;
      case "Braces":
        return Icons.straighten_rounded;
      case "Implants":
        return Icons.medical_services_rounded;
      case "Crown":
        return Icons.workspace_premium_rounded;
      case "Filling":
        return Icons.healing_rounded;
      case "Orthodontics":
        return Icons.straighten_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  Color _serviceColor(String name) {
    switch (name) {
      case "Check up":
        return const Color(0xFF4CAF50);
      case "Cleaning":
        return const Color(0xFF26C6DA);
      case "Whitening":
        return const Color(0xFFEC407A);
      case "Braces":
        return const Color(0xFFFFB300);
      case "Implants":
        return const Color(0xFF1976D2);
      case "Crown":
        return const Color(0xFF8D6E63);
      case "Filling":
        return const Color(0xFF42A5F5);
      case "Orthodontics":
        return const Color(0xFFFFB300);
      default:
        return _blue;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchServiceData();
  }

  Future<void> _fetchServiceData() async {
    final user = MockDB().currentUser;
    if (user == null) return;

    try {
      final docSnapshot = await MockDB()
          .collection('doctors')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        if (data.containsKey('services')) {
          final loadedServices = data['services'] as Map<String, dynamic>;
          loadedServices.forEach((key, value) {
            if (value is Map) {
              _serviceConfig[key] = {
                'enabled': value['enabled'] ?? false,
                'price': value['price'] ?? 0.0,
                'duration': value['duration'] ?? 30,
              };
            }
          });
        }
      }

      for (var service in _masterServices) {
        if (!_serviceConfig.containsKey(service)) {
          _serviceConfig[service] = {'enabled': false, 'price': 0.0, 'duration': 30};
        }
      }
    } catch (e) {
      debugPrint("Error fetching services: $e");
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveServices() async {
    final user = MockDB().currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await MockDB().collection('doctors').doc(user.uid).set({
        'services': _serviceConfig,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text("Services updated successfully!"),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saving: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                              "Manage Services",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Enable & set prices",
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
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      24,
                                      20,
                                      0,
                                    ),
                                    itemCount: _masterServices.length,
                                    itemBuilder: (context, index) {
                                      final serviceName =
                                          _masterServices[index];
                                      final config =
                                          _serviceConfig[serviceName]!;
                                      final isEnabled =
                                          config['enabled'] as bool;
                                      final price = config['price'].toString();
                                      final duration = config['duration'].toString();
                                      final color = _serviceColor(serviceName);

                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                          border: Border.all(
                                            color: isEnabled
                                                ? color.withOpacity(0.3)
                                                : Colors.grey.withOpacity(0.15),
                                            width: 0.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.04,
                                              ),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  // أيقونة الخدمة
                                                  Container(
                                                    width: 48,
                                                    height: 48,
                                                    decoration: BoxDecoration(
                                                      color: color.withOpacity(
                                                        0.1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      _serviceIcon(serviceName),
                                                      color: color,
                                                      size: 24,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 14),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          serviceName,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    _darkBlue,
                                                              ),
                                                        ),
                                                        Text(
                                                          isEnabled
                                                              ? "Active"
                                                              : "Disabled",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: isEnabled
                                                                ? color
                                                                : Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Switch
                                                  Switch(
                                                    value: isEnabled,
                                                    activeColor: color,
                                                    onChanged: (val) => setState(
                                                      () => config['enabled'] =
                                                          val,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              // حقل السعر لما الخدمة مفعّلة
                                              if (isEnabled) ...[
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextField(
                                                        keyboardType:
                                                            const TextInputType.numberWithOptions(
                                                              decimal: true,
                                                            ),
                                                        decoration: InputDecoration(
                                                          labelText: "Price (EGP)",
                                                          labelStyle: TextStyle(
                                                            color: color,
                                                            fontSize: 13,
                                                          ),
                                                          prefixIcon: Icon(
                                                            Icons
                                                                .attach_money_rounded,
                                                            color: color,
                                                            size: 20,
                                                          ),
                                                          filled: true,
                                                          fillColor: color
                                                              .withOpacity(0.05),
                                                          border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  14,
                                                                ),
                                                            borderSide:
                                                                BorderSide.none,
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      14,
                                                                    ),
                                                                borderSide:
                                                                    BorderSide(
                                                                      color: color,
                                                                      width: 1.5,
                                                                    ),
                                                              ),
                                                          contentPadding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 14,
                                                                vertical: 12,
                                                              ),
                                                        ),
                                                        controller:
                                                            TextEditingController(
                                                                text: price == "0.0"
                                                                    ? ""
                                                                    : price,
                                                              )
                                                              ..selection =
                                                                  TextSelection.fromPosition(
                                                                    TextPosition(
                                                                      offset:
                                                                          (price == "0.0"
                                                                                  ? ""
                                                                                  : price)
                                                                              .length,
                                                                    ),
                                                                  ),
                                                        onChanged: (val) =>
                                                            config['price'] =
                                                                double.tryParse(
                                                                  val,
                                                                ) ??
                                                                0.0,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: TextField(
                                                        keyboardType: TextInputType.number,
                                                        decoration: InputDecoration(
                                                          labelText: "Mins",
                                                          labelStyle: TextStyle(
                                                            color: color,
                                                            fontSize: 13,
                                                          ),
                                                          prefixIcon: Icon(
                                                            Icons.schedule_rounded,
                                                            color: color,
                                                            size: 20,
                                                          ),
                                                          filled: true,
                                                          fillColor: color
                                                              .withOpacity(0.05),
                                                          border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  14,
                                                                ),
                                                            borderSide:
                                                                BorderSide.none,
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      14,
                                                                    ),
                                                                borderSide:
                                                                    BorderSide(
                                                                      color: color,
                                                                      width: 1.5,
                                                                    ),
                                                              ),
                                                          contentPadding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 14,
                                                                vertical: 12,
                                                              ),
                                                        ),
                                                        controller:
                                                            TextEditingController(
                                                                text: duration == "30"
                                                                    ? "30"
                                                                    : duration,
                                                              )
                                                              ..selection =
                                                                  TextSelection.fromPosition(
                                                                    TextPosition(
                                                                      offset:
                                                                          (duration == "30"
                                                                                  ? "30"
                                                                                  : duration)
                                                                              .length,
                                                                    ),
                                                                  ),
                                                        onChanged: (val) =>
                                                            config['duration'] =
                                                                int.tryParse(val) ?? 30,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // ── زر Save ──
                                Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    16,
                                    20,
                                    24,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(28),
                                      topRight: Radius.circular(28),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _darkBlue.withOpacity(0.08),
                                        blurRadius: 20,
                                        offset: const Offset(0, -6),
                                      ),
                                    ],
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: _saveServices,
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
                                          Icon(Icons.save_rounded, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            "Save Changes",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
