import os
import re

def main():
    folder_path = r"c:\Users\org\Desktop\doctor\flutter_3\lib"
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            if file.endswith(".dart"):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()

                orig_content = content

                content = content.replace("import 'package:cloud_firestore/cloud_firestore.dart';", "")
                content = content.replace("import 'package:firebase_storage/firebase_storage.dart';", "")
                content = content.replace("import 'package:supabase_flutter/supabase_flutter.dart' hide User;", "")
                content = content.replace("import 'package:firebase_auth/firebase_auth.dart';", "import 'package:flutter_3/mock_db.dart';")
                
                content = content.replace("import 'package:firebase_core/firebase_core.dart';", "")
                content = content.replace("import 'firebase_options.dart';", "")
                
                if "FutureBuilder<DocumentSnapshot>" in content:
                    content = content.replace("FutureBuilder<DocumentSnapshot>", "Builder")
                
                content = content.replace("FirebaseFirestore.instance", "MockDB()")
                content = content.replace("FirebaseAuth.instance.currentUser", "MockDB().currentUser")

                if content != orig_content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(content)
                    print(f"Updated {filepath}")

if __name__ == '__main__':
    main()
