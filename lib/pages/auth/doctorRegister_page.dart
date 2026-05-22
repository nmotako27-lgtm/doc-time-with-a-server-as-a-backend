import 'package:flutter/material.dart';
import 'package:flutter_3/pages/home/home_page_for_doctor.dart';
import 'package:flutter_3/services/api_service.dart';
import 'package:flutter_3/services/auth_service.dart';
import 'package:flutter_3/mock_db.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/foundation.dart';
import 'dart:io' as io;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _selectedImage;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final TextEditingController specialtyController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController degreeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool isHidden = true;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = pickedFile);
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

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 25),
                      _buildForm(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: const [
        Text("🦷", style: TextStyle(fontSize: 60)),
        SizedBox(height: 10),
        Text(
          "Create Account",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 135, 173, 228),
          ),
        ),
        SizedBox(height: 5),
        Text("Join Dental Care", style: TextStyle(color: Colors.black54)),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 35,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white,
                backgroundImage: _selectedImage != null
                    ? (kIsWeb
                              ? NetworkImage(_selectedImage!.path)
                              : FileImage(io.File(_selectedImage!.path)))
                          as ImageProvider
                    : null,
                child: _selectedImage == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            _field(
              "Full Name",
              nameController,
              validator: (value) {
                if (value == null || value.isEmpty) return "Name cannot be empty";
                if (value.length < 3) return "Name is too short";
                return null;
              },
            ),
            _field(
              "Email",
              emailController,
              validator: (value) {
                if (value == null || value.isEmpty) return "Email cannot be empty";
                if (!value.contains("@") || !value.contains(".")) return "Enter valid email";
                return null;
              },
            ),
            _field(
              "Phone",
              phoneController,
              validator: (value) {
                if (value == null || value.isEmpty) return "Phone cannot be empty";
                if (value.length != 11) return "Phone must be 11 digits";
                return null;
              },
            ),

            _field(
              "Password",
              passController,
              obscure: isHidden,
              suffix: IconButton(
                icon: Icon(
                  isHidden ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF0A2540),
                ),
                onPressed: () => setState(() => isHidden = !isHidden),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return "Password cannot be empty";
                if (value.length < 6) return "Minimum 6 characters";
                return null;
              },
            ),

            _field(
              "Confirm Password",
              confirmController,
              obscure: true,
              validator: (value) {
                if (value == null || value.isEmpty) return "Confirm password";
                if (value != passController.text) return "Passwords do not match";
                return null;
              },
            ),
            _field(
              "Specialty",
              specialtyController,
              validator: (value) {
                if (value == null || value.isEmpty) return "Specialty cannot be empty";
                return null;
              },
            ),
            _field(
              "Degree",
              degreeController,
              validator: (value) {
                if (value == null || value.isEmpty) return "Degree cannot be empty";
                return null;
              },
            ),
            _field(
              "Experience",
              experienceController,
              validator: (value) {
                if (value == null || value.isEmpty) return "Experience cannot be empty";
                return null;
              },
            ),
            _field(
              "Address",
              addressController,
              validator: (value) {
                if (value == null || value.isEmpty) return "Address cannot be empty";
                return null;
              },
            ),
            _field(
              "Bio",
              bioController,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) return "Bio cannot be empty";
                return null;
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A2540),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                // =========================
                // 🔥 LOGIC زي ما هو 100%
                // =========================
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      String? photoUrl;

                      if (_selectedImage != null) {
                        final uploadResponse = await ApiService.uploadFile(
                          'upload',
                          kIsWeb ? _selectedImage : _selectedImage!.path,
                        );

                        if (uploadResponse['success']) {
                          photoUrl = uploadResponse['data']['url'];
                        }
                      }

                      await AuthService().register(
                        email: emailController.text.trim(),
                        password: passController.text.trim(),
                        name: nameController.text.trim(),
                        role: 'doctor',
                        phone: phoneController.text.trim(),
                        specialty: specialtyController.text.trim(),
                        degree: degreeController.text.trim(),
                        address: addressController.text.trim(),
                        experience:
                            int.tryParse(experienceController.text.trim()) ?? 0,
                        bio: bioController.text.trim(),
                        photoUrl: photoUrl,
                      );

                      final mockUser = MockDB().currentUser;
                      if (mockUser != null) {
                        mockUser.photoUrl = photoUrl;
                        mockUser.phone = phoneController.text.trim();
                        mockUser.specialty = specialtyController.text.trim();
                        mockUser.experience =
                            int.tryParse(experienceController.text.trim()) ?? 0;
                        mockUser.bio = bioController.text.trim();
                      }

                      if (mounted) Navigator.pop(context);

                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DoctorHomePage(),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) Navigator.pop(context);
                    }
                  }
                },

                child: const Text(
                  "SIGN UP",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    Widget? suffix,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          suffixIcon: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}
