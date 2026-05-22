import os
import re

def main():
    pat_file = r"c:\Users\org\Desktop\doctor\flutter_3\lib\pages\auth\patientRegister_Page.dart"
    with open(pat_file, 'r', encoding='utf-8') as f:
        content = f.read()

    content = content.replace("import 'package:cloud_firestore/cloud_firestore.dart';", "")
    content = content.replace("import 'package:firebase_storage/firebase_storage.dart';", "")
    content = content.replace("import 'package:supabase_flutter/supabase_flutter.dart' hide User;", "")
    content = content.replace("import 'package:firebase_auth/firebase_auth.dart';", "import 'package:flutter_3/mock_db.dart';")

    supabase_re = r"""                        // Upload Image if selected \(Supabase\)[\s\S]*?\} catch \(e\) \{\s*print\("Error uploading image to Supabase: \$e"\);\s*\}\s*\}"""
    content = re.sub(supabase_re, "String? photoUrl; // Mock upload skipped", content)

    firestore_re = r"""                        // Save User Data to Firestore[\s\S]*?\}\);"""
    mock_save = """                        // 3. Update Mock User
                        final mockUser = MockDB().currentUser;
                        if (mockUser != null) {
                          mockUser.photoUrl = photoUrl;
                          mockUser.phone = phoneController.text.trim();
                          mockUser.birthdate = birthdateController.text.trim();
                          mockUser.gender = genderValue;
                          mockUser.address = addressController.text.trim();
                        }"""
    content = re.sub(firestore_re, mock_save, content)

    content = content.replace("catch (e) {", "catch (e) {")
    content = content.replace("on FirebaseAuthException catch (e) {", "catch (e) {")
    content = content.replace("final user = FirebaseAuth.instance.currentUser;", "final user = MockDB().currentUser;")
    
    # fix the error messages
    content = content.replace("e.code", "e.toString()")
    content = content.replace("e.message ?? e.code", "e.toString()")

    with open(pat_file, 'w', encoding='utf-8') as f:
        f.write(content)

    print("Patched patientRegister_Page.dart")

if __name__ == '__main__':
    main()
