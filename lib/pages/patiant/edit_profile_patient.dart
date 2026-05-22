import 'package:flutter/material.dart';
import 'package:flutter_3/mock_db.dart';
import 'package:flutter_3/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' as io;

class EditProfileScreen extends StatefulWidget {
  final String? currentPhotoUrl;
  const EditProfileScreen({super.key, this.currentPhotoUrl});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _gender;

  final User? user = MockDB().currentUser;
  bool isLoading = true;
  bool isUploading = false;

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final Color dark = const Color(0xFF0A2540);
  final Color blue = const Color(0xFF1E88E5);
  final Color light = const Color(0xFFE3F2FD);
  final Color bg = const Color(0xFFF5F7FB);

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() {
    if (user != null) {
      _nameController.text = user!.name;
      _phoneController.text = user!.phone ?? '';
      _emailController.text = user!.email;
      _birthdateController.text = user!.birthdate ?? '';
      _addressController.text = user!.address ?? '';
      _gender = user!.gender;
    }
    setState(() => isLoading = false);
  }

  // دالة لفتح روزنامة اختيار التاريخ بشكل احترافي
  Future<void> _selectBirthdate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 20),
      ), // الافتراضي عمر 20 سنة
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: blue, // اللون الأساسي للـ Header
              onPrimary: Colors.white,
              onSurface: dark, // لون نصوص الأيام
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // تنسيق التاريخ ليصبح YYYY-MM-DD
        _birthdateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() => _imageFile = picked);
    }
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text("Camera"),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
              icon: const Icon(Icons.photo),
              label: const Text("Gallery"),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _uploadImage(XFile image) async {
    final res = await ApiService.uploadFile(
      'upload',
      kIsWeb ? image : image.path,
    );

    if (res['success']) return res['data']['url'];
    return null;
  }

  Future<void> _saveChanges() async {
    if (user == null) return;
    setState(() => isUploading = true);

    try {
      String? photoUrl = widget.currentPhotoUrl;

      if (_imageFile != null) {
        photoUrl = await _uploadImage(_imageFile!);
      }

      final data = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'birthdate': _birthdateController.text,
        'address': _addressController.text,
        'gender': _gender,
        if (photoUrl != null) 'photoUrl': photoUrl,
      };

      await MockDB().collection('users').doc(user!.uid).update(data);

      user!
        ..name = data['name'] as String
        ..phone = data['phone'] as String
        ..birthdate = data['birthdate'] as String
        ..address = data['address'] as String
        ..gender = data['gender'] as String?;

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Saved successfully")));
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? img;

    if (_imageFile != null) {
      img = kIsWeb
          ? NetworkImage(_imageFile!.path)
          : FileImage(io.File(_imageFile!.path));
    } else if (widget.currentPhotoUrl != null) {
      img = NetworkImage(widget.currentPhotoUrl!);
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A2540), Color(0xFF1E88E5), Color(0xFFE3F2FD)],
          ),
        ),
        child: Column(
          children: [
            _header(img),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _card(_field("Name", _nameController)),
                    _card(_field("Email", _emailController, readOnly: true)),
                    _card(_field("Phone", _phoneController)),

                    // تعديل حقل تاريخ الميلاد ليفتح الـ Date Picker عند الضغط عليه
                    GestureDetector(
                      onTap: () => _selectBirthdate(context),
                      child: AbsorbPointer(
                        child: _card(
                          _field(
                            "Birthdate",
                            _birthdateController,
                            readOnly:
                                true, // يبقى true لمنع الكيبورد العادي ولكن يعمل عبر الـ GestureDetector
                          ),
                        ),
                      ),
                    ),

                    _card(_field("Address", _addressController)),

                    const SizedBox(height: 10),

                    _card(_genderWidget()),

                    const SizedBox(height: 20),

                    _saveButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _header(ImageProvider? img) {
    return Container(
      padding: const EdgeInsets.only(top: 55, bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  "Edit Profile",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),

          const SizedBox(height: 10),

          Stack(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white,
                backgroundImage: img,
                child: img == null
                    ? Icon(Icons.person, size: 40, color: blue)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showPicker,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.edit, size: 16, color: blue),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // CARD
  Widget _card(Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: child,
    );
  }

  // FIELD
  Widget _field(
    String label,
    TextEditingController c, {
    bool readOnly = false,
  }) {
    return TextField(
      controller: c,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none,
        suffixIcon: label == "Birthdate"
            ? Icon(Icons.calendar_month, color: blue)
            : null,
      ),
    );
  }

  // GENDER
  Widget _genderWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Gender", style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Radio<String>(
              value: "male",
              groupValue: _gender,
              onChanged: (v) => setState(() => _gender = v),
            ),
            const Text("Male"),
            Radio<String>(
              value: "female",
              groupValue: _gender,
              onChanged: (v) => setState(() => _gender = v),
            ),
            const Text("Female"),
          ],
        ),
      ],
    );
  }

  // SAVE BUTTON
  Widget _saveButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A2540), Color(0xFF1E88E5)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: isUploading ? null : _saveChanges,
        child: isUploading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Save Changes",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
