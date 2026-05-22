import os
import re

def main():
    # 1. doctorRegister_page.dart
    doc_file = r"c:\Users\org\Desktop\doctor\flutter_3\lib\pages\auth\doctorRegister_page.dart"
    with open(doc_file, 'r', encoding='utf-8') as f:
        content = f.read()
        
    content = content.replace("import 'package:cloud_firestore/cloud_firestore.dart';", "")
    content = content.replace("import 'package:firebase_storage/firebase_storage.dart';", "")
    content = content.replace("import 'package:supabase_flutter/supabase_flutter.dart' hide User;", "")
    content = content.replace("import 'package:firebase_auth/firebase_auth.dart';", "import 'package:flutter_3/mock_db.dart';")
    
    # remove supabase logic
    supabase_re = r"""                        // Upload Image if selected \(Supabase\)[\s\S]*?\} catch \(e\) \{\s*print\("Error uploading image to Supabase: \$e"\);\s*ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(\s*content: Text\(\s*"Failed to upload profile image: \$e",\s*\),\s*\),\s*\);\s*\}\s*\}"""
    content = re.sub(supabase_re, "String? photoUrl; // Mock upload skipped", content)
    
    # remove firestore saving and replace with mock user updates
    firestore_re = r"""                        // 3\. Save Doctor Data[\s\S]*?\}\);"""
    mock_save = """                        // 3. Update Mock User
                        final mockUser = MockDB().currentUser;
                        if (mockUser != null) {
                          mockUser.photoUrl = photoUrl;
                          mockUser.phone = phoneController.text.trim();
                          mockUser.specialty = specialtyController.text.trim();
                          mockUser.experience = int.tryParse(experienceController.text.trim()) ?? 0;
                          mockUser.workingHours = workingHoursController.text.trim();
                          mockUser.bio = bioController.text.trim();
                        }"""
    content = re.sub(firestore_re, mock_save, content)
    
    # replace FirebaseAuthException
    content = content.replace("catch (e) {", "catch (e) {")
    content = content.replace("on FirebaseAuthException catch (e) {", "catch (e) {")
    content = content.replace("final user = FirebaseAuth.instance.currentUser;", "final user = MockDB().currentUser;")
    
    with open(doc_file, 'w', encoding='utf-8') as f:
        f.write(content)

    print("Patched doctorRegister_page.dart")

if __name__ == '__main__':
    main()
