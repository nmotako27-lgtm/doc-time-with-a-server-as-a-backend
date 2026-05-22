import 'package:flutter/material.dart';
import 'package:flutter_3/mock_db.dart';
import 'package:flutter_3/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' as io;

class EditProfilePage extends StatefulWidget {
  final String name;
  final String specialization;
  final String degree; // ستُعامل هنا كـ Experience
  final String phone;
  final String email;
  final String time; // Working Hours
  final String address; // ستُعامل كـ Bio
  final String? currentPhotoUrl;

  const EditProfilePage({
    super.key,
    required this.name,
    required this.specialization,
    required this.degree,
    required this.phone,
    required this.email,
    required this.time,
    required this.address,
    this.currentPhotoUrl,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController specializationController;
  late TextEditingController
  experienceController; // تم تعديل الاسم ليتوافق مع الـ DB
  late TextEditingController emailController;
  late TextEditingController timeController;
  late TextEditingController bioController; // تم تعديل الاسم ليتوافق مع الـ DB

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

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
    nameController = TextEditingController(text: widget.name);
    specializationController = TextEditingController(
      text: widget.specialization,
    );

    // استخراج الرقم فقط من نص الخبرة المرسل (مثال: "5 Years" تحول إلى "5")
    String expDigits = widget.degree.replaceAll(RegExp(r'[^0-9]'), '');
    experienceController = TextEditingController(
      text: expDigits.isEmpty ? "0" : expDigits,
    );

    emailController = TextEditingController(text: widget.email);
    timeController = TextEditingController(text: widget.time);
    bioController = TextEditingController(
      text: widget.address,
    ); // خرائط الـ Bio
  }

  @override
  void dispose() {
    nameController.dispose();
    specializationController.dispose();
    experienceController.dispose();
    emailController.dispose();
    timeController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (picked != null) setState(() => _imageFile = picked);
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Choose Photo",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _darkBlue,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _blue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _blue.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            color: _blue,
                            size: 28,
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Camera",
                            style: TextStyle(color: _blue, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF4CAF50).withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.photo_library_rounded,
                            color: Color(0xFF4CAF50),
                            size: 28,
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Gallery",
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 13,
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
    );
  }

  Future<String?> _uploadImage(XFile image) async {
    try {
      final res = await ApiService.uploadFile(
        'upload',
        kIsWeb ? image : image.path,
      );
      if (res['success']) return res['data']['url'];
      return null;
    } catch (e) {
      debugPrint("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isUploading = true);

    try {
      String? photoUrl = widget.currentPhotoUrl;
      if (_imageFile != null) {
        final newUrl = await _uploadImage(_imageFile!);
        if (newUrl != null) photoUrl = newUrl;
      }

      // تجهيز البيانات طبقاً لمفاتيح كولكشن الـ doctors الثابتة
      final updateData = {
        'name': nameController.text.trim(),
        'specialty': specializationController.text.trim(),
        'experience':
            int.tryParse(experienceController.text.trim()) ??
            0, // يجب أن يكون رقم int
        'email': emailController.text.trim(),
        'workingHours': timeController.text.trim(),
        'bio': bioController.text.trim(),
        if (photoUrl != null) 'photoUrl': photoUrl,
      };

      final user = MockDB().currentUser;
      if (user != null) {
        // التعديل يتم في كولكشن doctors ليتطابق مع صفحة الـ Profile الأساسية
        await MockDB().collection('doctors').doc(user.uid).update(updateData);

        // تحديث كائن المستخدم الحالي محلياً إن وُجدت الحقول فيه
        user.name = updateData['name'] as String;
        user.specialty = updateData['specialty'] as String;
        user.workingHours = updateData['workingHours'] as String;
        if (photoUrl != null) user.photoUrl = photoUrl;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text("Profile updated successfully!"),
              ],
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context, true); // إرجاع القيمة true لتحديث الصفحة السابقة
      }
    } catch (e) {
      debugPrint("Error saving profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isUploading = false);
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    required IconData icon,
    required Color color,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: color, fontSize: 13),
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

  @override
  Widget build(BuildContext context) {
    ImageProvider? bgImage;
    if (_imageFile != null) {
      bgImage =
          (kIsWeb
                  ? NetworkImage(_imageFile!.path)
                  : FileImage(io.File(_imageFile!.path)))
              as ImageProvider;
    } else if (widget.currentPhotoUrl != null &&
        widget.currentPhotoUrl!.isNotEmpty) {
      bgImage = NetworkImage(
        ApiService.getFullImageUrl(widget.currentPhotoUrl!),
      );
    }

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
                              "Edit Profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Update your information",
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
                  Stack(
                    children: [
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
                          backgroundImage: bgImage,
                          child: bgImage == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showImagePickerOptions,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: _darkBlue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                      child: isUploading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                28,
                                20,
                                24,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // 1. الاسم كامل
                                    _buildTextField(
                                      "Full Name",
                                      nameController,
                                      icon: Icons.person_rounded,
                                      color: const Color(
                                        0xFF673AB7,
                                      ), // اللون البنفسجي المطابق للـ Profile
                                    ),

                                    // 2. التخصص
                                    _buildTextField(
                                      "Specialization",
                                      specializationController,
                                      icon: Icons.medical_services_rounded,
                                      color: const Color(0xFF4CAF50),
                                    ),

                                    // 3. البريد الإلكتروني
                                    _buildTextField(
                                      "Email",
                                      emailController,
                                      icon: Icons.email_rounded,
                                      color: _blue,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (v) {
                                        if (v == null || v.isEmpty)
                                          return "Email is required";
                                        if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                        ).hasMatch(v)) {
                                          return "Invalid email";
                                        }
                                        return null;
                                      },
                                    ),

                                    // 4. سنوات الخبرة (عوضاً عن الـ Degree القديمة لتطابق الـ DB كـ رقم)
                                    _buildTextField(
                                      "Experience (Years)",
                                      experienceController,
                                      icon: Icons.workspace_premium_rounded,
                                      color: const Color(0xFF4CAF50),
                                      keyboardType: TextInputType.number,
                                      validator: (v) {
                                        if (v == null || v.isEmpty)
                                          return "Experience is required";
                                        if (int.tryParse(v) == null)
                                          return "Enter a valid number";
                                        return null;
                                      },
                                    ),

                                    // 5. ساعات العمل المتاحة
                                    _buildTextField(
                                      "Working Hours",
                                      timeController,
                                      icon: Icons.schedule_rounded,
                                      color: const Color(0xFFFFB300),
                                    ),

                                    // 6. السيرة الذاتية الـ Bio (عوضاً عن الـ Address القديمة)
                                    _buildTextField(
                                      "Bio",
                                      bioController,
                                      icon: Icons.description_rounded,
                                      color: const Color(0xFFEC407A),
                                    ),

                                    const SizedBox(height: 24),

                                    // ── Save button ──
                                    SizedBox(
                                      width: double.infinity,
                                      height: 54,
                                      child: ElevatedButton(
                                        onPressed: _saveProfile,
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
                                  ],
                                ),
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
}
