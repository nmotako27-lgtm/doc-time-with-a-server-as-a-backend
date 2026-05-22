import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_3/pages/auth/login_page.dart';
import 'package:flutter_3/services/api_service.dart';
import 'package:flutter_3/services/auth_service.dart';
import 'package:flutter_3/mock_db.dart';

import 'package:flutter/foundation.dart';
import 'dart:io' as io;

import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> formState = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? genderValue;

  XFile? _selectedImage;

  bool isHidden = true;
  bool isConfirmHidden = true;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
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

  Widget _buildField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    bool obscure = false,
    Widget? suffix,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboard,
        inputFormatters: inputFormatters,
        validator: validator,

        decoration: InputDecoration(
          labelText: label,

          prefixIcon: Icon(icon, color: const Color(0xFF0A2540)),

          suffixIcon: suffix,

          filled: true,
          fillColor: Colors.white,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF0A2540), width: 2),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.red),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmpassController.dispose();
    phoneController.dispose();
    birthdateController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),

      child: Scaffold(
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
                        const SizedBox(height: 10),

                        // ===== HEADER =====
                        Column(
                          children: const [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white,

                              child: Icon(
                                Icons.health_and_safety_rounded,
                                size: 45,
                                color: Color(0xFF0A2540),
                              ),
                            ),

                            SizedBox(height: 15),

                            Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              "Join Dental Care",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // ===== FORM =====
                        Container(
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
                            key: formState,

                            child: Column(
                              children: [
                                // ===== IMAGE =====
                                GestureDetector(
                                  onTap: _pickImage,

                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 52,

                                        backgroundColor: const Color(
                                          0xFFE3F2FD,
                                        ),

                                        backgroundImage: _selectedImage != null
                                            ? (kIsWeb
                                                      ? NetworkImage(
                                                          _selectedImage!.path,
                                                        )
                                                      : FileImage(
                                                          io.File(
                                                            _selectedImage!
                                                                .path,
                                                          ),
                                                        ))
                                                  as ImageProvider
                                            : null,

                                        child: _selectedImage == null
                                            ? const Icon(
                                                Icons.person,
                                                size: 45,
                                                color: Color(0xFF0A2540),
                                              )
                                            : null,
                                      ),

                                      Positioned(
                                        bottom: 0,
                                        right: 0,

                                        child: Container(
                                          padding: const EdgeInsets.all(6),

                                          decoration: const BoxDecoration(
                                            color: Color(0xFF0A2540),
                                            shape: BoxShape.circle,
                                          ),

                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 25),

                                // ===== FULL NAME =====
                                _buildField(
                                  "Full Name",
                                  nameController,

                                  icon: Icons.person,

                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z\s]'),
                                    ),
                                  ],

                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Name cannot be empty";
                                    }

                                    if (value.length < 3) {
                                      return "Name is too short";
                                    }

                                    return null;
                                  },
                                ),

                                // ===== EMAIL =====
                                _buildField(
                                  "Email",
                                  emailController,

                                  icon: Icons.email,

                                  keyboard: TextInputType.emailAddress,

                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Email cannot be empty";
                                    }

                                    if (!value.contains("@") ||
                                        !value.contains(".")) {
                                      return "Enter valid email";
                                    }

                                    return null;
                                  },
                                ),

                                // ===== PASSWORD =====
                                _buildField(
                                  "Password",
                                  passController,

                                  icon: Icons.lock,

                                  obscure: isHidden,

                                  suffix: IconButton(
                                    icon: Icon(
                                      isHidden
                                          ? Icons.visibility_off
                                          : Icons.visibility,

                                      color: const Color(0xFF0A2540),
                                    ),

                                    onPressed: () {
                                      setState(() {
                                        isHidden = !isHidden;
                                      });
                                    },
                                  ),

                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Password cannot be empty";
                                    }

                                    if (value.length < 6) {
                                      return "Minimum 6 characters";
                                    }

                                    return null;
                                  },
                                ),

                                // ===== CONFIRM PASSWORD =====
                                _buildField(
                                  "Confirm Password",
                                  confirmpassController,

                                  icon: Icons.lock,

                                  obscure: isConfirmHidden,

                                  suffix: IconButton(
                                    icon: Icon(
                                      isConfirmHidden
                                          ? Icons.visibility_off
                                          : Icons.visibility,

                                      color: const Color(0xFF0A2540),
                                    ),

                                    onPressed: () {
                                      setState(() {
                                        isConfirmHidden = !isConfirmHidden;
                                      });
                                    },
                                  ),

                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Confirm password";
                                    }

                                    if (value != passController.text) {
                                      return "Passwords do not match";
                                    }

                                    return null;
                                  },
                                ),

                                // ===== PHONE =====
                                _buildField(
                                  "Phone Number",
                                  phoneController,

                                  icon: Icons.phone,

                                  keyboard: TextInputType.phone,

                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],

                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Phone cannot be empty";
                                    }

                                    if (value.length != 11) {
                                      return "Phone must be 11 digits";
                                    }

                                    return null;
                                  },
                                ),

                                // ===== BIRTHDATE =====
                                _buildField(
                                  "Birthdate",
                                  birthdateController,

                                  icon: Icons.cake,

                                  readOnly: true,

                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime(2000),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    );

                                    if (pickedDate != null) {
                                      birthdateController.text =
                                          "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                                    }
                                  },

                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Select birthdate";
                                    }

                                    return null;
                                  },
                                ),

                                // ===== ADDRESS =====
                                _buildField(
                                  "Address",
                                  addressController,

                                  icon: Icons.home,

                                  maxLines: 2,

                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Address cannot be empty";
                                    }

                                    return null;
                                  },
                                ),

                                // ===== GENDER =====
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15),

                                  child: DropdownButtonFormField<String>(
                                    value: genderValue,

                                    decoration: InputDecoration(
                                      labelText: "Gender",

                                      prefixIcon: const Icon(
                                        Icons.people,
                                        color: Color(0xFF0A2540),
                                      ),

                                      filled: true,
                                      fillColor: Colors.white,

                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        borderSide: BorderSide.none,
                                      ),

                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        borderSide: BorderSide.none,
                                      ),

                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF0A2540),
                                          width: 2,
                                        ),
                                      ),
                                    ),

                                    items: const [
                                      DropdownMenuItem(
                                        value: "male",
                                        child: Text("Male"),
                                      ),

                                      DropdownMenuItem(
                                        value: "female",
                                        child: Text("Female"),
                                      ),
                                    ],

                                    onChanged: (value) {
                                      setState(() {
                                        genderValue = value;
                                      });
                                    },

                                    validator: (value) {
                                      if (value == null) {
                                        return "Please select gender";
                                      }

                                      return null;
                                    },
                                  ),
                                ),

                                const SizedBox(height: 25),

                                // ===== BUTTON =====
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,

                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0A2540),

                                      elevation: 8,

                                      shadowColor: Colors.black26,

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),

                                    onPressed: () async {
                                      if (formState.currentState!.validate()) {
                                        try {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,

                                            builder: (context) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            },
                                          );

                                          String? photoUrl;

                                          if (_selectedImage != null) {
                                            final uploadResponse =
                                                await ApiService.uploadFile(
                                                  'upload',

                                                  kIsWeb
                                                      ? _selectedImage!
                                                      : _selectedImage!.path,
                                                );

                                            if (uploadResponse['success']) {
                                              photoUrl =
                                                  uploadResponse['data']['url'];
                                            }
                                          }

                                          await AuthService().register(
                                            email: emailController.text.trim(),

                                            password: passController.text
                                                .trim(),

                                            name: nameController.text.trim(),

                                            role: 'patient',

                                            phone: phoneController.text.trim(),

                                            address: addressController.text
                                                .trim(),

                                            birthdate: birthdateController.text
                                                .trim(),

                                            gender: genderValue,

                                            photoUrl: photoUrl,
                                          );

                                          final mockUser = MockDB().currentUser;

                                          if (mockUser != null) {
                                            mockUser.photoUrl = photoUrl;

                                            mockUser.phone = phoneController
                                                .text
                                                .trim();

                                            mockUser.birthdate =
                                                birthdateController.text.trim();

                                            mockUser.gender = genderValue;

                                            mockUser.address = addressController
                                                .text
                                                .trim();
                                          }

                                          if (mounted) {
                                            Navigator.of(
                                              context,
                                              rootNavigator: true,
                                            ).pop();
                                          }

                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Account created successfully',
                                                ),

                                                backgroundColor: Colors.green,
                                              ),
                                            );

                                            Navigator.pushReplacementNamed(
                                              context,
                                              "/home",
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            Navigator.of(
                                              context,
                                              rootNavigator: true,
                                            ).pop();
                                          }

                                          String message = e
                                              .toString()
                                              .replaceAll('Exception: ', '');

                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(message),

                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    },

                                    child: const Text(
                                      "SIGN UP",

                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: [
                                    const Text("Already have an account? "),

                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,

                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginPage(),
                                          ),
                                        );
                                      },

                                      child: const Text(
                                        "Sign In",

                                        style: TextStyle(
                                          color: Color(0xFF0A2540),

                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
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
}
