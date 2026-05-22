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

                content = content.replace("import 'package:cloud_firestore/cloud_firestore.dart';", "import 'package:flutter_3/mock_db.dart';")
                content = content.replace("Stream<QuerySnapshot>?", "Stream<List<MockAppointment>>?")
                content = content.replace("StreamBuilder<QuerySnapshot>", "StreamBuilder<List<MockAppointment>>")
                
                content = re.sub(
                    r'final appointments = snapshot\.data!\.docs\.map\(\(doc\) \{[\s\S]*?\}\)\.toList\(\);',
                    """final appointments = snapshot.data!.map((doc) {
                    return {
                      'start': doc.time,
                      'end': doc.endTime,
                    };
                  }).toList();""",
                    content
                )

                if content != orig_content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(content)
                    print(f"Updated {filepath}")

if __name__ == '__main__':
    main()
