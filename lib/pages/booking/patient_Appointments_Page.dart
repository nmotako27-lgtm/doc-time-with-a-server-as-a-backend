import 'package:flutter/material.dart';
import 'package:flutter_3/pages/booking/confirmation_page.dart'
    show ConfirmationPage;

// ------------------------------------------------------------------

extension ColorBrightness on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

class PatientInfoPage extends StatefulWidget {
  final String selectedDay;
  final String selectedDate;
  final String selectedTime;
  final String serviceName;
  final double? price;
  final Future<void> Function(String, String) onSubmit;

  const PatientInfoPage({
    super.key,
    required this.selectedDay,
    required this.selectedDate,
    required this.selectedTime,
    required this.serviceName,
    this.price,
    required this.onSubmit,
  });

  @override
  State<PatientInfoPage> createState() => _PatientInfoPageState();
}

class _PatientInfoPageState extends State<PatientInfoPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? nameError;
  String? phoneError;

  final Color primaryColor = const Color(0xFF64C9FF);
  final Color textDark = const Color(0xFF1B1B1B);

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  bool validateInputs() {
    bool valid = true;

    String name = nameController.text.trim();
    if (name.isEmpty) {
      nameError = "Name is required";
      valid = false;
    } else if (name.length < 3) {
      nameError = "Name must be at least 3 characters";
      valid = false;
    } else {
      nameError = null;
    }

    String phone = phoneController.text.trim();
    if (phone.isEmpty) {
      phoneError = "Phone number is required";
      valid = false;
    } else if (!RegExp(r"^01[0-9]{9}$").hasMatch(phone)) {
      phoneError = "Phone must be 11 digits";
      valid = false;
    } else {
      phoneError = null;
    }

    setState(() {});
    return valid;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ SAFE PRICE HANDLING (FIX)
    final String priceText = widget.price == null
        ? "Free"
        : "\$${widget.price!.toStringAsFixed(0)}";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          "Patient Information",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 135, 213, 249),
              Color.fromARGB(255, 218, 240, 250),
            ],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // INFO CARD
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoItem(
                        Icons.calendar_month,
                        "Date",
                        "${widget.selectedDay}, ${widget.selectedDate}",
                      ),
                      _infoItem(Icons.access_time, "Time", widget.selectedTime),

                      // ✅ FIXED PRICE HERE
                      _infoItem(Icons.attach_money, "Price", priceText),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // NAME
                _buildLabel("Full Name"),
                const SizedBox(height: 10),
                _buildInputBox(
                  nameController,
                  "Enter your full name",
                  Icons.person,
                  hasError: nameError != null,
                  onChanged: (_) => setState(() => nameError = null),
                ),
                if (nameError != null) _buildErrorText(nameError!),

                const SizedBox(height: 25),

                // PHONE
                _buildLabel("Phone Number"),
                const SizedBox(height: 10),
                _buildInputBox(
                  phoneController,
                  "010xxxxxxxxx",
                  Icons.phone,
                  keyboard: TextInputType.phone,
                  hasError: phoneError != null,
                  onChanged: (_) => setState(() => phoneError = null),
                ),
                if (phoneError != null) _buildErrorText(phoneError!),

                const SizedBox(height: 40),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!validateInputs()) return;

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        await widget.onSubmit(
                          nameController.text,
                          phoneController.text,
                        );

                        if (mounted) Navigator.pop(context);

                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConfirmationPage(
                                serviceName: widget.serviceName,
                                day: widget.selectedDay,
                                date: widget.selectedDate,
                                time: widget.selectedTime,
                                // name: nameController.text,
                                // phone: phoneController.text,
                                // price: widget.price,
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Confirm Booking",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Widget _buildLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: textDark,
    ),
  );

  Widget _buildErrorText(String error) => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Text(error, style: const TextStyle(color: Colors.red, fontSize: 12)),
  );

  Widget _buildInputBox(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    bool hasError = false,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _infoItem(IconData icon, String title, String value) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: primaryColor),
        const SizedBox(height: 5),
        Text(title),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
