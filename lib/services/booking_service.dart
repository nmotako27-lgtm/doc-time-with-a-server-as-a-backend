import 'api_service.dart';
import '../mock_db.dart';

class BookingService {
  // ================= BOOK APPOINTMENT =================
  Future<void> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String service,
    required String day,
    required String date,
    required String time,
    required int duration,
    String? patientName,
    String? phone,
  }) async {
    final user = await ApiService.getUser();
    if (user == null) {
      throw Exception("User not logged in");
    }

    final String uid = (user['_id'] ?? user['id'] ?? '').toString();

    String endTime = _addMinutesToTime(time, duration);

    // 1️⃣ We skip the local overlap check as it should technically be done on the server,
    // or we fetch existing and check. For simplicity, we just send it to backend.
    
    // 3️⃣ Prepare patient data
    String nameToSave = patientName ?? user['name'];
    String phoneToSave = phone ?? user['phone'] ?? '';

    // 4️⃣ Save booking
    final data = {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientId': uid,
      'patient': nameToSave,
      'phone': phoneToSave,
      'service': service,
      'day': day,
      'date': date,
      'time': time,
      'duration': duration,
      'endTime': endTime,
      'status': 'Pending',
    };

    final response = await ApiService.post('appointments', data, requiresAuth: true);

    if (!response['success']) {
      throw Exception(response['msg']);
    }
  }

  // ================= GET BOOKED TIMES =================
  // Streams are tricky with REST APIs. We can simulate it by returning a Stream
  // that yields one Future's result.
  Stream<List<MockAppointment>> bookedTimes(String date, String doctorId) async* {
    final response = await ApiService.get('appointments?doctorId=$doctorId&date=$date', requiresAuth: true);
    if (response['success']) {
      List<dynamic> apps = response['data'];
      yield apps.map((app) => MockAppointment.fromJson(app))
          .where((app) => app.status == 'Pending' || app.status == 'Confirmed').toList();
    } else {
      yield [];
    }
  }

  // Helper: Add minutes to "HH:mm" time string
  String _addMinutesToTime(String time, int minutesToAdd) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(
        2022,
        1,
        1,
        hour,
        minute,
      ).add(Duration(minutes: minutesToAdd));
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return time; // Fallback
    }
  }
}
