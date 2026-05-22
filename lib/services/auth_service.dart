import 'api_service.dart';
import '../mock_db.dart';

class AuthService {
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String role, // patient / doctor
    String? phone,
    String? address,
    String? specialty,
    String? birthdate,
    String? gender,
    int? experience,
    String? workingHours,
    String? bio,
    String? photoUrl,
    String? degree,
  }) async {
    print('🔵 AuthService: Creating $role with email: $email');

    final data = {
      'email': email,
      'password': password,
      'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (specialty != null) 'specialty': specialty,
      if (birthdate != null) 'birthdate': birthdate,
      if (gender != null) 'gender': gender,
      if (experience != null) 'experience': experience,
      if (workingHours != null) 'workingHours': workingHours,
      if (bio != null) 'bio': bio,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (degree != null) 'degree': degree,
    };

    final response = await ApiService.post('auth/signup/$role', data);

    if (response['success']) {
      final token = response['data']['token'];
      // Backend now returns 'patient' or 'doctor' key instead of 'user'
      final userData = response['data'][role] ?? response['data']['user'];
      await ApiService.saveAuthData(token, userData);
      await MockDB().updateCurrentUser();
      print('✅ AuthService: $role created');
    } else {
      throw Exception(response['msg']);
    }
  }

  Future<void> login(String email, String password, {String role = 'patient'}) async {
    final data = {
      'email': email,
      'password': password,
    };

    // Use generic login endpoint that handles both roles
    final response = await ApiService.post('auth/login', data);

    if (response['success']) {
      final token = response['data']['token'];
      final userData = response['data']['user'];
      await ApiService.saveAuthData(token, userData);
      await MockDB().updateCurrentUser();
    } else {
      throw Exception(response['msg']);
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    MockDB().currentUser = null;
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    return await ApiService.getUser();
  }
}
