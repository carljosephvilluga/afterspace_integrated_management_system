import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aims/services/app_session.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AdminDashboardSummary {
  const AdminDashboardSummary({
    required this.staffCount,
    required this.userCount,
    required this.activeSessions,
    required this.totalRevenue,
    required this.bookingCount,
  });

  final int staffCount;
  final int userCount;
  final int activeSessions;
  final double totalRevenue;
  final int bookingCount;
}

class ManagerDashboardSummary {
  const ManagerDashboardSummary({
    required this.customersToday,
    required this.revenueToday,
    required this.reservedBookings,
    required this.completedPayments,
  });

  final int customersToday;
  final double revenueToday;
  final int reservedBookings;
  final int completedPayments;
}

class StaffDashboardSummary {
  const StaffDashboardSummary({
    required this.activeCustomers,
    required this.reservedBookings,
    required this.activeSessions,
  });

  final int activeCustomers;
  final int reservedBookings;
  final int activeSessions;
}

class AimsApiException implements Exception {
  const AimsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AimsApiClient {
  AimsApiClient._();

  static final AimsApiClient instance = AimsApiClient._();
  static const String _configuredBaseUrl = String.fromEnvironment(
    'AIMS_API_BASE_URL',
    defaultValue: '',
  );

  final http.Client _httpClient = http.Client();
  static const Duration _requestTimeout = Duration(seconds: 4);

  String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2/aims_api';
    }

    if (kIsWeb) {
      return 'http://127.0.0.1/aims_api';
    }

    return 'http://127.0.0.1/aims_api';
  }

  Future<void> login({
    required String role,
    required String employeeId,
    required String password,
  }) async {
    final envelope = await _send(
      method: 'POST',
      path: '/api/auth/login',
      body: {'role': role, 'employeeId': employeeId, 'password': password},
    );
    final data = _asMap(envelope['data']);
    final token = _asString(data['token']);
    final user = _asMap(data['user']);

    if (token.isEmpty) {
      throw const AimsApiException('Missing session token.');
    }

    AppSession.saveAuth(token: token, user: user);
  }

  Future<void> logout() async {
    try {
      await _send(method: 'POST', path: '/api/auth/logout', withAuth: true);
    } catch (_) {
      // Keep logout resilient even when backend is unavailable.
    } finally {
      AppSession.clear();
    }
  }

  Future<AdminDashboardSummary> fetchAdminDashboardSummary() async {
    final envelope = await _send(
      method: 'GET',
      path: '/api/dashboard/admin',
      withAuth: true,
    );
    final data = _asMap(envelope['data']);
    return AdminDashboardSummary(
      staffCount: _asInt(data['staffCount']),
      userCount: _asInt(data['userCount']),
      activeSessions: _asInt(data['activeSessions']),
      totalRevenue: _asDouble(data['totalRevenue']),
      bookingCount: _asInt(data['bookingCount']),
    );
  }

  Future<ManagerDashboardSummary> fetchManagerDashboardSummary() async {
    final envelope = await _send(
      method: 'GET',
      path: '/api/dashboard/manager',
      withAuth: true,
    );
    final data = _asMap(envelope['data']);
    return ManagerDashboardSummary(
      customersToday: _asInt(data['customersToday']),
      revenueToday: _asDouble(data['revenueToday']),
      reservedBookings: _asInt(data['reservedBookings']),
      completedPayments: _asInt(data['completedPayments']),
    );
  }

  Future<StaffDashboardSummary> fetchStaffDashboardSummary() async {
    final envelope = await _send(
      method: 'GET',
      path: '/api/dashboard/staff',
      withAuth: true,
    );
    final data = _asMap(envelope['data']);
    return StaffDashboardSummary(
      activeCustomers: _asInt(data['activeCustomers']),
      reservedBookings: _asInt(data['reservedBookings']),
      activeSessions: _asInt(data['activeSessions']),
    );
  }

  static String formatCurrency(double value) {
    final absolute = value.abs();
    final isWholeNumber = absolute % 1 == 0;
    final normalized = isWholeNumber
        ? absolute.round().toString()
        : absolute.toStringAsFixed(2);
    final parts = normalized.split('.');
    final dollars = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    final cents = parts.length > 1 ? '.${parts[1]}' : '';
    final sign = value < 0 ? '-' : '';
    return '$sign\$$dollars$cents';
  }

  static String formatCount(num value) {
    final asInt = value.toInt();
    return asInt.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
  }

  Future<Map<String, dynamic>> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    bool withAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
    };

    if (withAuth) {
      final token = AppSession.token;
      if (token == null || token.isEmpty) {
        throw const AimsApiException('Please log in first.');
      }
      headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }

    late http.Response response;
    try {
      switch (method) {
        case 'GET':
          response = await _httpClient
              .get(uri, headers: headers)
              .timeout(_requestTimeout);
          break;
        case 'POST':
          response = await _httpClient
              .post(uri, headers: headers, body: jsonEncode(body ?? const {}))
              .timeout(_requestTimeout);
          break;
        case 'PATCH':
          response = await _httpClient
              .patch(uri, headers: headers, body: jsonEncode(body ?? const {}))
              .timeout(_requestTimeout);
          break;
        case 'DELETE':
          response = await _httpClient
              .delete(uri, headers: headers)
              .timeout(_requestTimeout);
          break;
        default:
          throw AimsApiException('Unsupported method: $method');
      }
    } on TimeoutException {
      throw const AimsApiException(
        'Request timed out. Please check backend connection and try again.',
      );
    } on SocketException {
      throw const AimsApiException(
        'Cannot connect to backend. Make sure the backend server is running.',
      );
    } on http.ClientException {
      throw const AimsApiException(
        'Network error while contacting backend. Please try again.',
      );
    }

    final envelope = _decodeEnvelope(response.body);
    final isOk = envelope['ok'] == true;
    if (!isOk || response.statusCode >= HttpStatus.badRequest) {
      final error = _asMap(envelope['error']);
      final message = _asString(error['message']);
      throw AimsApiException(
        message.isEmpty ? 'Request failed (${response.statusCode}).' : message,
      );
    }

    return envelope;
  }

  Map<String, dynamic> _decodeEnvelope(String rawBody) {
    if (rawBody.trim().isEmpty) {
      return const <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      throw const AimsApiException('Invalid response from backend.');
    }

    throw const AimsApiException('Invalid response from backend.');
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const <String, dynamic>{};
  }

  String _asString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(_asString(value)) ?? 0;
  }

  double _asDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(_asString(value)) ?? 0;
  }
}
