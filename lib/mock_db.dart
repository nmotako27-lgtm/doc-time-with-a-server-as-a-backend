import 'dart:async';
import 'package:flutter_3/services/api_service.dart';

class MockUser {
  final String uid;
  String email;
  String name;
  final String role; // 'patient' or 'doctor'
  String? photoUrl;
  String? password;

  // Doctor specific
  String? specialty;
  int? experience;
  String? workingHours;
  String? bio;

  // Patient specific
  String? phone;
  String? birthdate;
  String? gender;
  String? address;
  String? degree;
  String? time;

  MockUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.photoUrl,
    this.password,
    this.specialty,
    this.experience,
    this.workingHours,
    this.bio,
    this.phone,
    this.birthdate,
    this.gender,
    this.address,
    this.degree,
    this.time,
  });

  factory MockUser.fromJson(Map<String, dynamic> json) {
    return MockUser(
      uid: (json['_id'] ?? json['id'] ?? '').toString(),
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'patient',
      photoUrl: json['photoUrl'],
      specialty: json['specialty'],
      experience: int.tryParse(json['experience']?.toString() ?? '0') ?? 0,
      workingHours: json['workingHours'],
      bio: json['bio'],
      phone: json['phone'],
      birthdate: json['birthdate'],
      gender: json['gender'],
      address: json['address'],
      degree: json['degree'],
      time: json['time'],
    );
  }
}

class MockAppointment {
  final String id;
  final String doctorId;
  final String patientId;
  final String service;
  final String day;
  final String date;
  final String time;
  final String endTime;
  final int duration;
  final String status;

  MockAppointment({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.service,
    required this.day,
    required this.date,
    required this.time,
    required this.endTime,
    required this.duration,
    required this.status,
  });

  factory MockAppointment.fromJson(Map<String, dynamic> json) {
    return MockAppointment(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      doctorId: (json['doctorId'] is Map) ? (json['doctorId']['_id'] ?? json['doctorId']['id'] ?? '').toString() : (json['doctorId'] ?? '').toString(),
      patientId: (json['patientId'] is Map) ? (json['patientId']['_id'] ?? json['patientId']['id'] ?? '').toString() : (json['patientId'] ?? '').toString(),
      service: json['service'] ?? '',
      day: json['day'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      endTime: json['endTime'] ?? '',
      duration: int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'Pending',
    );
  }
}

class MockDB {
  static final MockDB _instance = MockDB._internal();
  factory MockDB() => _instance;
  MockDB._internal() {
    _initUser();
  }

  MockUser? currentUser;
  final _updateController = StreamController<String>.broadcast();

  Stream<String> get onUpdate => _updateController.stream;

  void notify(String collection) {
    _updateController.add(collection);
  }

  Future<void> _initUser() async {
    final userMap = await ApiService.getUser();
    if (userMap != null) {
      currentUser = MockUser.fromJson(userMap);
    }
  }

  Future<void> updateCurrentUser() async {
     await _initUser();
  }

  List<MockUser> users = []; // Keep for compatibility, though not used much now
  List<dynamic> appointments = []; // Keep for compatibility

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  CollectionReference collection(String path) {
    return CollectionReference(path);
  }
}

// ---------------------------------------------------------
// FAKE FIRESTORE CLASSES MAPPED TO REST API
// ---------------------------------------------------------

typedef User = MockUser;

class DocumentSnapshot {
  final String id;
  final Map<String, dynamic>? _data;
  DocumentSnapshot(this.id, this._data);

  bool get exists => _data != null;
  dynamic data() => _data;
}

class QueryDocumentSnapshot extends DocumentSnapshot {
  QueryDocumentSnapshot(String id, Map<String, dynamic> data) : super(id, data);
  @override
  dynamic data() => _data!;
}

class QuerySnapshot {
  final List<QueryDocumentSnapshot> docs;
  final int size;
  QuerySnapshot(this.docs) : size = docs.length;
}

class SetOptions {
  final bool merge;
  const SetOptions({this.merge = false});
}

class DocumentReference {
  final String collectionPath;
  final String id;
  DocumentReference(this.collectionPath, this.id);

  Future<DocumentSnapshot> get() async {
    // Determine which API to call based on collection
    if (collectionPath == 'patients' || collectionPath == 'users') {
      final res = await ApiService.get('auth/user', requiresAuth: true);
      if (res['success']) {
        return DocumentSnapshot(id, res['data']);
      }
    } else if (collectionPath == 'doctors') {
      final res = await ApiService.get('auth/doctors');
      if (res['success']) {
        final docs = res['data'] as List;
        final doc = docs.firstWhere((d) => d['_id'] == id || d['id'] == id, orElse: () => null);
        if (doc != null) return DocumentSnapshot(id, doc);
      }
    } else if (collectionPath == 'appointments') {
      final res = await ApiService.get('appointments/$id', requiresAuth: true);
      if (res['success']) {
        return DocumentSnapshot(id, res['data']);
      }
    }
    return DocumentSnapshot(id, null);
  }

  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    if (collectionPath == 'patients' || collectionPath == 'doctors' || collectionPath == 'users') {
      await ApiService.put('auth/user', data, requiresAuth: true);
      MockDB().notify(collectionPath);
    }
  }

  Future<void> update(Map<String, dynamic> data) async {
    if (collectionPath == 'appointments') {
      await ApiService.put('appointments/$id', data, requiresAuth: true);
      MockDB().notify('appointments');
    } else if (collectionPath == 'patients' ||
        collectionPath == 'doctors' ||
        collectionPath == 'users') {
      final res = await ApiService.put('auth/user', data, requiresAuth: true);
      if (res['success']) {
        // Save the updated user data locally so it persists and UI updates
        final token = await ApiService.getToken();
        if (token != null) {
          await ApiService.saveAuthData(token, res['data']);
          await MockDB().updateCurrentUser();
        }
        MockDB().notify(collectionPath);
      }
    }
  }
}

class Query {
  final String collectionPath;
  String? filterField;
  dynamic filterValue;

  Query(this.collectionPath);

  Query where(String field, {dynamic isEqualTo, List<dynamic>? whereIn}) {
    filterField = field;
    filterValue = isEqualTo;
    return this;
  }

  Query orderBy(String field, {bool descending = false}) {
    return this;
  }

  Stream<QuerySnapshot> snapshots() async* {
    // Initial fetch
    yield await _fetch();

    // Listen for updates
    await for (final collection in MockDB().onUpdate) {
      if (collection == collectionPath) {
        yield await _fetch();
      }
    }
  }

  Future<QuerySnapshot> _fetch() async {
    if (collectionPath == 'doctors') {
      final res = await ApiService.get('auth/doctors');
      if (res['success']) {
        final List docs = res['data'];
        final queryDocs = docs.map((d) => QueryDocumentSnapshot(d['_id'] ?? d['id'], d)).toList();
        return QuerySnapshot(queryDocs);
      }
    } else if (collectionPath == 'appointments') {
      String queryParams = "";
      if (filterField != null && filterValue != null) {
        queryParams = "?$filterField=$filterValue";
      }
      final res = await ApiService.get('appointments$queryParams', requiresAuth: true);
      if (res['success']) {
        final List docs = res['data'];
        final queryDocs = docs.map((d) => QueryDocumentSnapshot(d['_id'] ?? d['id'], d)).toList();
        return QuerySnapshot(queryDocs);
      }
    }
    return QuerySnapshot([]);
  }
}

class CollectionReference extends Query {
  CollectionReference(String path) : super(path);

  DocumentReference doc([String? id]) {
    return DocumentReference(collectionPath, id ?? MockDB().generateId());
  }
}
