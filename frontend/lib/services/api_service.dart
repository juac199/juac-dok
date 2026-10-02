import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://'
      '10.84.138.176:8000';

  // ============================================================
  // LOGIN
  // ============================================================

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    print('LOGIN DEBUG URL: $baseUrl/login');
    print('LOGIN DEBUG EMAIL: ${email.trim()}');
    print('LOGIN DEBUG EMAIL LENGTH: ${email.trim().length}');

    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    print('LOGIN DEBUG STATUS: ${response.statusCode}');
    print('LOGIN DEBUG RESPONSE: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Login failed');
  }

  // ============================================================
  // STUDENTS
  // ============================================================

  static Future<List<dynamic>> getStudents(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/students'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to load students');
  }

  static Future<Map<String, dynamic>> getStudent(
    String token,
    int studentId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/students/$studentId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to load student');
  }

  static Future<Map<String, dynamic>> getMyStudentProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/students/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to load student profile');
  }

  static Future<Map<String, dynamic>> createStudent(
    String token,
    Map<String, dynamic> student,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(student),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to create student');
  }

  static Future<Map<String, dynamic>> updateStudent(
    String token,
    int studentId,
    Map<String, dynamic> student,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/students/$studentId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(student),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to update student');
  }

  static Future<Map<String, dynamic>> deleteStudent(
    String token,
    int studentId,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/students/$studentId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to delete student');
  }

  // ============================================================
  // SUBJECTS
  // ============================================================

  static Future<List<dynamic>> getSubjects(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/subjects'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to load subjects');
  }

  static Future<Map<String, dynamic>> createSubject(
    String token,
    Map<String, dynamic> subject,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/subjects'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(subject),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to create subject');
  }

  static Future<Map<String, dynamic>> updateSubject(
    String token,
    int subjectId,
    Map<String, dynamic> subject,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/subjects/$subjectId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(subject),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to update subject');
  }

  static Future<Map<String, dynamic>> deleteSubject(
    String token,
    int subjectId,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/subjects/$subjectId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to delete subject');
  }

  // ============================================================
  // AVAILABLE SUBJECTS
  // ============================================================

  static Future<List<dynamic>> getAvailableSubjects(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/students/available-subjects'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to load available subjects');
  }

  // ============================================================
  // MY REGISTERED SUBJECTS
  // ============================================================

  static Future<List<dynamic>> getMySubjects(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/students/me/subjects'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to load registered subjects');
  }

  static Future<Map<String, dynamic>> registerSubject(
    String token,
    int subjectId,
    String semester,
    String academicYear,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students/me/subjects'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'subject_id': subjectId,
        'semester': semester,
        'academic_year': academicYear,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to register subject');
  }

  static Future<Map<String, dynamic>> dropSubject(
    String token,
    int registrationId,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/students/me/subjects/$registrationId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to drop subject');
  }

  // ============================================================
  // RESULTS
  // ============================================================

  static Future<List<dynamic>> getMyResults(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/students/me/results'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    print('STUDENT RESULTS API RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to load results');
  }

  // ============================================================
  // GPA
  // ============================================================

  static Future<List<dynamic>> getMyGpa(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/students/me/gpa'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to load GPA');
  }

  // ============================================================
  // CGPA
  // ============================================================

  static Future<Map<String, dynamic>> getMyCgpa(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/students/me/cgpa'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to load CGPA');
  }

  // ============================================================
  // ACADEMIC PERFORMANCE
  // ============================================================

  static Future<Map<String, dynamic>> getMyPerformance(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/students/me/performance'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to load academic performance');
  }

  // ============================================================
  // ATTENDANCE
  // ============================================================

  static Future<List<dynamic>> getMyAttendance(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/students/me/attendance'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to load attendance');
  }

  // ============================================================
  // ATTENDANCE SUMMARY
  // ============================================================

  static Future<Map<String, dynamic>> getMyAttendanceSummary(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/students/me/attendance/summary'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Failed to load attendance summary');
  }

  // ============================================================
  // ADMIN ENROLLMENT MANAGEMENT
  // ============================================================

  static Future<List<dynamic>> getAdminEnrollments(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/enrollments'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception('Failed to load enrollments: ${response.body}');
  }

  static Future<Map<String, dynamic>> createEnrollment(
    String token,
    Map<String, dynamic> enrollmentData,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/enrollments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(enrollmentData),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data as Map<String, dynamic>;
    }

    throw Exception(data['detail'] ?? 'Failed to create enrollment');
  }

  static Future<Map<String, dynamic>> deleteEnrollment(
    String token,
    int enrollmentId,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/enrollments/$enrollmentId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data as Map<String, dynamic>;
    }

    throw Exception(data['detail'] ?? 'Failed to remove enrollment');
  }

  // ============================================================
  // LECTURER PROFILE
  // ============================================================

  // ============================================================
  // ADMIN LECTURER MANAGEMENT
  // ============================================================

  static Future<List<dynamic>> getAdminLecturers(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/lecturers'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception('Failed to load lecturers: ${response.body}');
  }

  static Future<Map<String, dynamic>> createLecturer(
    String token,
    Map<String, dynamic> lecturerData,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/lecturers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(lecturerData),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data as Map<String, dynamic>;
    }

    throw Exception(data['detail'] ?? 'Failed to create lecturer');
  }

  static Future<Map<String, dynamic>> updateLecturer(
    String token,
    int lecturerId,
    Map<String, dynamic> lecturerData,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/lecturers/$lecturerId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(lecturerData),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data as Map<String, dynamic>;
    }

    throw Exception(data['detail'] ?? 'Failed to update lecturer');
  }

  static Future<Map<String, dynamic>> deleteLecturer(
    String token,
    int lecturerId,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/lecturers/$lecturerId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data as Map<String, dynamic>;
    }

    throw Exception(data['detail'] ?? 'Failed to delete lecturer');
  }

  static Future<Map<String, dynamic>> getMyLecturerProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/lecturers/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load lecturer profile: ${response.body}');
  }

  // ============================================================
  // LECTURER SUBJECTS
  // ============================================================

  static Future<List<dynamic>> getMyLecturerSubjects(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/lecturers/me/subjects'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('LECTURER SUBJECTS API RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      if (data is Map<String, dynamic>) {
        final subjects = data['subjects'];

        if (subjects is List) {
          return subjects;
        }
      }

      throw Exception(
        'Unexpected lecturer subjects response: ${response.body}',
      );
    }

    throw Exception('Failed to load lecturer subjects: ${response.body}');
  }

  // ============================================================
  // LECTURER SUBJECT STUDENTS
  // ============================================================

  static Future<List<dynamic>> getMySubjectStudents(
    String token,
    int subjectId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/lecturers/me/subjects/$subjectId/students'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // The backend may return either:
      // 1. A direct list of students
      // 2. An object containing a "students" list
      if (data is List) {
        return data;
      }

      if (data is Map<String, dynamic>) {
        final students = data['students'];

        if (students is List) {
          return students;
        }
      }

      throw Exception('Unexpected students response format: ${response.body}');
    }

    if (data is Map<String, dynamic>) {
      throw Exception(data['detail'] ?? 'Failed to load enrolled students');
    }

    throw Exception('Failed to load enrolled students: ${response.body}');
  }

  // ============================================================
  // LECTURER SUBJECT ATTENDANCE
  // ============================================================

  static Future<List<dynamic>> getMySubjectAttendance(
    String token,
    int subjectId,
    String date,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/attendance?subject_id=$subjectId&date=$date'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data is List) {
        return data;
      }

      if (data is Map<String, dynamic>) {
        final attendance = data['attendance'];

        if (attendance is List) {
          return attendance;
        }
      }

      throw Exception(
        'Unexpected attendance response format: ${response.body}',
      );
    }

    if (data is Map<String, dynamic>) {
      throw Exception(data['detail'] ?? 'Failed to load attendance');
    }

    throw Exception('Failed to load attendance: ${response.body}');
  }

  // ============================================================
  // LECTURER MARK ATTENDANCE
  // ============================================================

  static Future<Map<String, dynamic>> markLecturerAttendance(
    String token,
    Map<String, dynamic> attendance,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/lecturers/me/attendance'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(attendance),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      throw Exception(data['detail'] ?? 'Failed to record attendance');
    }

    throw Exception('Failed to record attendance: ${response.body}');
  }

  static Future<List<dynamic>> getLecturerResults(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/lecturers/me/results'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data is List) {
        return data;
      }

      if (data is Map<String, dynamic>) {
        final results = data['results'];

        if (results is List) {
          return results;
        }
      }

      throw Exception(
        'Unexpected lecturer results response format: ${response.body}',
      );
    }

    if (data is Map<String, dynamic>) {
      throw Exception(data['detail'] ?? 'Failed to load lecturer results');
    }

    throw Exception('Failed to load lecturer results: ${response.body}');
  }

  static Future<dynamic> addLecturerResult(
    String token,
    Map<String, dynamic> resultData,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/lecturers/me/results'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(resultData),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      throw Exception(data['detail'] ?? 'Failed to add result');
    }

    throw Exception('Failed to add result: ${response.body}');
  }

  // ============================================================
  // ADMIN GET ALL RESULTS
  // ============================================================

  static Future<List<dynamic>> getAdminResults(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/results'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data is List) {
        return data;
      }

      throw Exception(
        'Unexpected admin results response format: ${response.body}',
      );
    }

    if (data is Map<String, dynamic>) {
      throw Exception(data['detail'] ?? 'Failed to load admin results');
    }

    throw Exception('Failed to load admin results: ${response.body}');
  }

  // ============================================================
  // ADMIN PUBLISH RESULT
  // ============================================================

  static Future<Map<String, dynamic>> publishResult(
    String token,
    int resultId,
    String status,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/results/$resultId/publish'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': status}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      throw Exception(data['detail'] ?? 'Failed to update result status');
    }

    throw Exception('Failed to update result status: ${response.body}');
  }

  // ============================================================
  // ADMIN CREATE RESULT
  // ============================================================

  static Future<Map<String, dynamic>> createAdminResult(
    String token,
    Map<String, dynamic> resultData,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/results'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(resultData),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data as Map<String, dynamic>;
    }

    if (data is Map<String, dynamic>) {
      throw Exception(data['detail'] ?? 'Failed to create result');
    }

    throw Exception('Failed to create result: ${response.body}');
  }

  // ============================================================
  // ADMIN UPDATE RESULT
  // ============================================================

  static Future<Map<String, dynamic>> updateAdminResult(
    String token,
    int resultId,
    Map<String, dynamic> resultData,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/results/$resultId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(resultData),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data as Map<String, dynamic>;
    }

    if (data is Map<String, dynamic>) {
      throw Exception(data['detail'] ?? 'Failed to update result');
    }

    throw Exception('Failed to update result: ${response.body}');
  }

  // ============================================================
  // ADMIN DELETE RESULT
  // ============================================================

  static Future<Map<String, dynamic>> deleteAdminResult(
    String token,
    int resultId,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/results/$resultId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data as Map<String, dynamic>;
    }

    if (data is Map<String, dynamic>) {
      throw Exception(data['detail'] ?? 'Failed to delete result');
    }

    throw Exception('Failed to delete result: ${response.body}');
  }

  static Future<Map<String, dynamic>> getStudentFeeSummary(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/student/fees/summary'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(data['detail'] ?? 'Failed to load fee summary');
  }

  static Future<List<dynamic>> getStudentFeeInvoices(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/student/fees/invoices'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<dynamic>.from(data);
    }

    throw Exception(data['detail'] ?? 'Failed to load fee invoices');
  }

  static Future<List<dynamic>> getStudentFeePayments(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/student/fees/payments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<dynamic>.from(data);
    }

    throw Exception(data['detail'] ?? 'Failed to load payment history');
  }

  // ============================================================
  // STUDENT SERVICES
  // ============================================================

  static Future<Map<String, dynamic>> getStudentVisa(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/student/visa'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load visa information');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> requestStudentVisa(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/student/visa/request'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit visa request');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getStudentAnnouncements(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/student/announcements'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load announcements');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> askStudentAI(
    String token,
    String question,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/student/ai-help'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'question': question}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to contact Student Assistant');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getAdminAnnouncements(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/announcements'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load admin announcements');
    }

    return jsonDecode(response.body) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createAdminAnnouncement(
    String token,
    String title,
    String message,
    String category,
    bool isPublished,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/announcements'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'message': message,
        'category': category,
        'is_published': isPublished,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create announcement');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
