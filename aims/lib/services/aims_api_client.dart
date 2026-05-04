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

class DashboardReservationItem {
  const DashboardReservationItem({
    required this.bookingId,
    required this.customerName,
    required this.email,
    required this.contactDetails,
    required this.startAt,
    required this.endAt,
  });

  final int bookingId;
  final String customerName;
  final String email;
  final String contactDetails;
  final DateTime startAt;
  final DateTime endAt;
}

class DashboardActiveCustomerItem {
  const DashboardActiveCustomerItem({
    required this.sessionId,
    required this.name,
    required this.email,
    required this.membershipType,
    required this.spaceUsed,
    required this.timeIn,
    required this.status,
  });

  final int sessionId;
  final String name;
  final String email;
  final String membershipType;
  final String spaceUsed;
  final DateTime timeIn;
  final String status;
}

class DashboardWeeklyActivityItem {
  const DashboardWeeklyActivityItem({
    required this.date,
    required this.label,
    required this.count,
  });

  final DateTime date;
  final String label;
  final int count;
}

class DashboardTransactionItem {
  const DashboardTransactionItem({
    required this.transactionId,
    required this.customerName,
    required this.email,
    required this.amount,
    required this.discountApplied,
    required this.finalAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  final int transactionId;
  final String customerName;
  final String email;
  final double amount;
  final double discountApplied;
  final double finalAmount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
}

class StaffDashboardSnapshot {
  const StaffDashboardSnapshot({
    required this.summary,
    required this.weeklyActivity,
    required this.pendingReservations,
    required this.activeCustomers,
    required this.latestTransactions,
  });

  final StaffDashboardSummary summary;
  final List<DashboardWeeklyActivityItem> weeklyActivity;
  final List<DashboardReservationItem> pendingReservations;
  final List<DashboardActiveCustomerItem> activeCustomers;
  final List<DashboardTransactionItem> latestTransactions;
}

class ManagerDashboardSnapshot {
  const ManagerDashboardSnapshot({
    required this.summary,
    required this.pendingReservations,
    required this.latestTransactions,
  });

  final ManagerDashboardSummary summary;
  final List<DashboardReservationItem> pendingReservations;
  final List<DashboardTransactionItem> latestTransactions;
}

class StaffAccountRecord {
  const StaffAccountRecord({
    required this.staffId,
    required this.employeeId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.status,
    required this.createdAt,
  });

  final int staffId;
  final String employeeId;
  final String fullName;
  final String email;
  final String role;
  final String status;
  final DateTime createdAt;
}

class BookingRecord {
  const BookingRecord({
    required this.bookingId,
    required this.bookingCode,
    required this.userId,
    required this.customerName,
    required this.email,
    required this.contactDetails,
    required this.spaceType,
    required this.customerType,
    required this.status,
    required this.startAt,
    required this.endAt,
  });

  final int bookingId;
  final String bookingCode;
  final int userId;
  final String customerName;
  final String email;
  final String contactDetails;
  final String spaceType;
  final String customerType;
  final String status;
  final DateTime startAt;
  final DateTime endAt;
}

class UserRecord {
  const UserRecord({
    required this.userId,
    required this.userCode,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    required this.membershipType,
    required this.isActive,
    required this.history,
  });

  final int userId;
  final String userCode;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String userType;
  final String membershipType;
  final bool isActive;
  final List<String> history;
}

class PricingMembershipType {
  const PricingMembershipType({
    required this.membershipTypeId,
    required this.type,
    required this.duration,
    required this.price,
    required this.benefits,
  });

  final int membershipTypeId;
  final String type;
  final String duration;
  final String price;
  final String benefits;
}

class PricingPromotion {
  const PricingPromotion({
    required this.promoId,
    required this.name,
    required this.type,
    required this.discount,
    required this.expiry,
  });

  final int promoId;
  final String name;
  final String type;
  final String discount;
  final DateTime expiry;
}

class LoyaltyRewardRecord {
  const LoyaltyRewardRecord({
    required this.memberName,
    required this.entries,
    required this.freeHours,
  });

  final String memberName;
  final int entries;
  final int freeHours;
}

class SpacePricingRecord {
  const SpacePricingRecord({
    required this.boardRoomHourlyRate,
    required this.ordinarySpaceHourlyRate,
  });

  final double boardRoomHourlyRate;
  final double ordinarySpaceHourlyRate;
}

class PricingPromoSnapshot {
  const PricingPromoSnapshot({
    required this.membershipTypes,
    required this.promotions,
    required this.loyaltyRewards,
    required this.spacePricing,
  });

  final List<PricingMembershipType> membershipTypes;
  final List<PricingPromotion> promotions;
  final List<LoyaltyRewardRecord> loyaltyRewards;
  final SpacePricingRecord spacePricing;
}

class SalesReportSeries {
  const SalesReportSeries({
    required this.labels,
    required this.tooltipTitles,
    required this.tooltipValues,
    required this.areaValues,
    required this.lineValues,
    required this.highlightX,
    required this.maxY,
  });

  final List<String> labels;
  final List<String> tooltipTitles;
  final List<String> tooltipValues;
  final List<double> areaValues;
  final List<double> lineValues;
  final double highlightX;
  final double maxY;
}

class CustomerReportSummary {
  const CustomerReportSummary({
    required this.days,
    required this.from,
    required this.to,
    required this.monthlyMembership,
    required this.walkIn,
    required this.monthlySubscription,
    required this.loyalCustomers,
    required this.totalCustomers,
    required this.maxValue,
  });

  final int days;
  final DateTime from;
  final DateTime to;
  final int monthlyMembership;
  final int walkIn;
  final int monthlySubscription;
  final int loyalCustomers;
  final int totalCustomers;
  final int maxValue;

  List<double> get chartValues => <double>[
    monthlyMembership.toDouble(),
    walkIn.toDouble(),
    monthlySubscription.toDouble(),
    loyalCustomers.toDouble(),
  ];
}

class MeetingScheduleRecord {
  const MeetingScheduleRecord({
    required this.scheduleId,
    required this.title,
    required this.notes,
    required this.startAt,
    required this.endAt,
    required this.createdAt,
    required this.updatedAt,
    required this.createdByStaffId,
    required this.createdByEmployeeId,
    required this.createdByName,
  });

  final int scheduleId;
  final String title;
  final String notes;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int createdByStaffId;
  final String createdByEmployeeId;
  final String createdByName;
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

    if (kIsWeb) {
      return 'http://127.0.0.1/aims_api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2/aims_api';
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
      path: '/api/auth/login/',
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
      await _send(method: 'POST', path: '/api/auth/logout/', withAuth: true);
    } catch (_) {
      // Keep logout resilient even when backend is unavailable.
    } finally {
      AppSession.clear();
    }
  }

  Future<AdminDashboardSummary> fetchAdminDashboardSummary() async {
    final envelope = await _send(
      method: 'GET',
      path: '/api/dashboard/admin/',
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
      path: '/api/dashboard/manager/',
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
      path: '/api/dashboard/staff/',
      withAuth: true,
    );
    final data = _asMap(envelope['data']);
    return StaffDashboardSummary(
      activeCustomers: _asInt(data['activeCustomers']),
      reservedBookings: _asInt(data['reservedBookings']),
      activeSessions: _asInt(data['activeSessions']),
    );
  }

  Future<StaffDashboardSnapshot> fetchStaffDashboardSnapshot() async {
    final envelope = await _send(
      method: 'GET',
      path: '/api/dashboard/staff/',
      withAuth: true,
    );
    final data = _asMap(envelope['data']);
    final summary = StaffDashboardSummary(
      activeCustomers: _asInt(data['activeCustomers']),
      reservedBookings: _asInt(data['reservedBookings']),
      activeSessions: _asInt(data['activeSessions']),
    );

    final pendingReservations = _asList(
      data['pendingReservations'],
    ).map((item) => _parseDashboardReservation(item)).toList();
    final weeklyActivity = _asList(
      data['weeklyActivity'],
    ).map((item) => _parseDashboardWeeklyActivity(item)).toList();
    final activeCustomerRows = _asList(
      data['activeCustomerRows'],
    ).map((item) => _parseDashboardActiveCustomer(item)).toList();
    final latestTransactions = _asList(
      data['latestTransactions'],
    ).map((item) => _parseDashboardTransaction(item)).toList();

    return StaffDashboardSnapshot(
      summary: summary,
      weeklyActivity: weeklyActivity,
      pendingReservations: pendingReservations,
      activeCustomers: activeCustomerRows,
      latestTransactions: latestTransactions,
    );
  }

  Future<ManagerDashboardSnapshot> fetchManagerDashboardSnapshot() async {
    final envelope = await _send(
      method: 'GET',
      path: '/api/dashboard/manager/',
      withAuth: true,
    );
    final data = _asMap(envelope['data']);
    final summary = ManagerDashboardSummary(
      customersToday: _asInt(data['customersToday']),
      revenueToday: _asDouble(data['revenueToday']),
      reservedBookings: _asInt(data['reservedBookings']),
      completedPayments: _asInt(data['completedPayments']),
    );

    final pendingReservations = _asList(
      data['pendingReservations'],
    ).map((item) => _parseDashboardReservation(item)).toList();
    final latestTransactions = _asList(
      data['latestTransactions'],
    ).map((item) => _parseDashboardTransaction(item)).toList();

    return ManagerDashboardSnapshot(
      summary: summary,
      pendingReservations: pendingReservations,
      latestTransactions: latestTransactions,
    );
  }

  Future<List<BookingRecord>> fetchBookings({
    DateTime? day,
    String? status,
    int limit = 250,
  }) async {
    final query = <String>[];
    if (day != null) {
      query.add(
        'date=${Uri.encodeQueryComponent(day.toIso8601String().split('T').first)}',
      );
    }
    if (status != null && status.trim().isNotEmpty) {
      query.add('status=${Uri.encodeQueryComponent(status.trim())}');
    }
    if (limit > 0) {
      query.add('limit=$limit');
    }

    final path = query.isEmpty
        ? '/api/bookings/'
        : '/api/bookings/?${query.join('&')}';

    final envelope = await _send(method: 'GET', path: path, withAuth: true);
    final data = _asMap(envelope['data']);
    return _asList(
      data['bookings'],
    ).map((item) => _parseBookingRecord(item)).toList();
  }

  Future<BookingRecord> createBooking({
    required String customerName,
    required String contactDetails,
    required String spaceType,
    required DateTime startAt,
    required DateTime endAt,
    String customerType = 'Guest',
  }) async {
    final envelope = await _send(
      method: 'POST',
      path: '/api/bookings/',
      withAuth: true,
      body: {
        'customerName': customerName,
        'contactDetails': contactDetails,
        'spaceType': spaceType,
        'customerType': customerType,
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
      },
    );
    final data = _asMap(envelope['data']);
    return _parseBookingRecord(data['booking']);
  }

  Future<void> checkInBooking(int bookingId) async {
    await _send(
      method: 'POST',
      path: '/api/bookings/check-in/',
      withAuth: true,
      body: {'bookingId': bookingId},
    );
  }

  Future<void> cancelBooking(int bookingId) async {
    await _send(
      method: 'POST',
      path: '/api/bookings/cancel/',
      withAuth: true,
      body: {'bookingId': bookingId},
    );
  }

  Future<void> checkInUser({
    required String userEmail,
    required String spaceUsed,
    DateTime? checkInAt,
  }) async {
    await _send(
      method: 'POST',
      path: '/api/sessions/check-in/',
      withAuth: true,
      body: {
        'userEmail': userEmail,
        'spaceUsed': spaceUsed,
        if (checkInAt != null) 'checkInAt': checkInAt.toIso8601String(),
      },
    );
  }

  Future<void> checkOutUser({
    required String userEmail,
    required double amount,
    double discountApplied = 0,
    String paymentMethod = 'cash',
    String paymentStatus = 'paid',
  }) async {
    await _send(
      method: 'POST',
      path: '/api/sessions/check-out/',
      withAuth: true,
      body: {
        'userEmail': userEmail,
        'amount': amount,
        'discountApplied': discountApplied,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
      },
    );
  }

  Future<List<UserRecord>> fetchUsers() async {
    final envelope = await _send(
      method: 'GET',
      path: '/api/users/',
      withAuth: true,
    );
    final data = _asMap(envelope['data']);
    return _asList(
      data['users'],
    ).map((item) => _parseUserRecord(item)).toList();
  }

  Future<UserRecord> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String userType,
    required String membershipType,
    required bool isActive,
  }) async {
    final envelope = await _send(
      method: 'POST',
      path: '/api/users/',
      withAuth: true,
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'userType': userType,
        'membershipType': membershipType,
        'isActive': isActive,
      },
    );
    final data = _asMap(envelope['data']);
    return _parseUserRecord(data['user']);
  }

  Future<UserRecord> updateUser({
    required int userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String userType,
    required String membershipType,
    required bool isActive,
  }) async {
    final envelope = await _send(
      method: 'PATCH',
      path: '/api/users/',
      withAuth: true,
      body: {
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'userType': userType,
        'membershipType': membershipType,
        'isActive': isActive,
      },
    );
    final data = _asMap(envelope['data']);
    return _parseUserRecord(data['user']);
  }

  Future<void> deleteUser(int userId) async {
    await _send(
      method: 'DELETE',
      path: '/api/users/',
      withAuth: true,
      body: {'userId': userId},
    );
  }

  Future<List<StaffAccountRecord>> fetchStaffAccounts() async {
    final envelope = await _send(
      method: 'GET',
      path: '/api/staff-accounts/',
      withAuth: true,
    );
    final data = _asMap(envelope['data']);
    return _asList(
      data['staffAccounts'],
    ).map((item) => _parseStaffAccountRecord(item)).toList();
  }

  Future<StaffAccountRecord> createStaffAccount({
    required String employeeId,
    required String fullName,
    required String email,
    required String role,
    required String status,
    required String password,
  }) async {
    final envelope = await _send(
      method: 'POST',
      path: '/api/staff-accounts/',
      withAuth: true,
      body: {
        'employeeId': employeeId,
        'fullName': fullName,
        'email': email,
        'role': role,
        'status': status,
        'password': password,
      },
    );
    final data = _asMap(envelope['data']);
    return _parseStaffAccountRecord(data['staffAccount']);
  }

  Future<StaffAccountRecord> updateStaffAccount({
    required int staffId,
    required String employeeId,
    required String fullName,
    required String email,
    required String role,
    required String status,
    String password = '',
  }) async {
    final envelope = await _send(
      method: 'PATCH',
      path: '/api/staff-accounts/',
      withAuth: true,
      body: {
        'staffId': staffId,
        'employeeId': employeeId,
        'fullName': fullName,
        'email': email,
        'role': role,
        'status': status,
        if (password.isNotEmpty) 'password': password,
      },
    );
    final data = _asMap(envelope['data']);
    return _parseStaffAccountRecord(data['staffAccount']);
  }

  Future<void> deleteStaffAccount(int staffId) async {
    await _send(
      method: 'DELETE',
      path: '/api/staff-accounts/',
      withAuth: true,
      body: {'staffId': staffId},
    );
  }

  Future<PricingPromoSnapshot> fetchPricingPromoSnapshot() async {
    final envelope = await _send(
      method: 'GET',
      path: '/api/pricing-promos/',
      withAuth: true,
    );
    final data = _asMap(envelope['data']);
    final membershipTypes = _asList(
      data['membershipTypes'],
    ).map((item) => _parsePricingMembershipType(item)).toList();
    final promotions = _asList(
      data['promotions'],
    ).map((item) => _parsePricingPromotion(item)).toList();
    final loyaltyRewards = _asList(
      data['loyaltyRewards'],
    ).map((item) => _parseLoyaltyReward(item)).toList();
    final spacePricing = _parseSpacePricingRecord(data['spacePricing']);

    return PricingPromoSnapshot(
      membershipTypes: membershipTypes,
      promotions: promotions,
      loyaltyRewards: loyaltyRewards,
      spacePricing: spacePricing,
    );
  }

  Future<PricingMembershipType> createMembershipType({
    required String type,
    required String duration,
    required String price,
    required String benefits,
  }) async {
    final envelope = await _send(
      method: 'POST',
      path: '/api/pricing-promos/',
      withAuth: true,
      body: {
        'kind': 'membership',
        'type': type,
        'duration': duration,
        'price': price,
        'benefits': benefits,
      },
    );
    final data = _asMap(envelope['data']);
    return _parsePricingMembershipType(data['membershipType']);
  }

  Future<PricingMembershipType> updateMembershipType({
    required int membershipTypeId,
    required String type,
    required String duration,
    required String price,
    required String benefits,
  }) async {
    final envelope = await _send(
      method: 'PATCH',
      path: '/api/pricing-promos/',
      withAuth: true,
      body: {
        'kind': 'membership',
        'membershipTypeId': membershipTypeId,
        'type': type,
        'duration': duration,
        'price': price,
        'benefits': benefits,
      },
    );
    final data = _asMap(envelope['data']);
    return _parsePricingMembershipType(data['membershipType']);
  }

  Future<void> deleteMembershipType(int membershipTypeId) async {
    await _send(
      method: 'DELETE',
      path: '/api/pricing-promos/',
      withAuth: true,
      body: {'kind': 'membership', 'membershipTypeId': membershipTypeId},
    );
  }

  Future<PricingPromotion> createPromotion({
    required String name,
    required String type,
    required String discount,
    required String expiry,
    String benefits = '',
  }) async {
    final envelope = await _send(
      method: 'POST',
      path: '/api/pricing-promos/',
      withAuth: true,
      body: {
        'kind': 'promotion',
        'name': name,
        'type': type,
        'discount': discount,
        'expiry': expiry,
        'benefits': benefits,
      },
    );
    final data = _asMap(envelope['data']);
    return _parsePricingPromotion(data['promotion']);
  }

  Future<SpacePricingRecord> fetchSpacePricing() async {
    final snapshot = await fetchPricingPromoSnapshot();
    return snapshot.spacePricing;
  }

  Future<SpacePricingRecord> updateSpacePricing({
    required double boardRoomHourlyRate,
    required double ordinarySpaceHourlyRate,
  }) async {
    final envelope = await _send(
      method: 'PATCH',
      path: '/api/pricing-promos/',
      withAuth: true,
      body: {
        'kind': 'pricing',
        'boardRoomHourlyRate': boardRoomHourlyRate,
        'ordinarySpaceHourlyRate': ordinarySpaceHourlyRate,
      },
    );
    final data = _asMap(envelope['data']);
    return _parseSpacePricingRecord(data['spacePricing']);
  }

  Future<SalesReportSeries> fetchSalesReport({required String range}) async {
    final envelope = await _send(
      method: 'GET',
      path: '/api/reports/sales/?range=${Uri.encodeQueryComponent(range)}',
      withAuth: true,
    );
    final data = _asMap(envelope['data']);
    final labels = _asList(
      data['labels'],
    ).map((item) => _asString(item)).toList();
    final tooltipTitles = _asList(
      data['tooltipTitles'],
    ).map((item) => _asString(item)).toList();
    final tooltipValues = _asList(
      data['tooltipValues'],
    ).map((item) => _asString(item)).toList();
    final areaValues = _asList(
      data['areaValues'],
    ).map((item) => _asDouble(item)).toList();
    final lineValues = _asList(
      data['lineValues'],
    ).map((item) => _asDouble(item)).toList();

    return SalesReportSeries(
      labels: labels,
      tooltipTitles: tooltipTitles,
      tooltipValues: tooltipValues,
      areaValues: areaValues,
      lineValues: lineValues,
      highlightX: _asDouble(data['highlightX']),
      maxY: _asDouble(data['maxY']) <= 0 ? 10 : _asDouble(data['maxY']),
    );
  }

  Future<CustomerReportSummary> fetchCustomerReport({int days = 7}) async {
    final normalizedDays = days.clamp(1, 365);
    final envelope = await _send(
      method: 'GET',
      path: '/api/reports/customer/?days=$normalizedDays',
      withAuth: true,
    );
    final data = _asMap(envelope['data']);
    return CustomerReportSummary(
      days: _asInt(data['days']),
      from: _asDateTime(data['from']),
      to: _asDateTime(data['to']),
      monthlyMembership: _asInt(data['monthlyMembership']),
      walkIn: _asInt(data['walkIn']),
      monthlySubscription: _asInt(data['monthlySubscription']),
      loyalCustomers: _asInt(data['loyalCustomers']),
      totalCustomers: _asInt(data['totalCustomers']),
      maxValue: _asInt(data['maxValue']),
    );
  }

  Future<List<MeetingScheduleRecord>> fetchMeetingSchedules({
    DateTime? from,
    DateTime? to,
  }) async {
    final query = <String>[];
    if (from != null) {
      query.add(
        'from=${Uri.encodeQueryComponent(from.toIso8601String().split('T').first)}',
      );
    }
    if (to != null) {
      query.add(
        'to=${Uri.encodeQueryComponent(to.toIso8601String().split('T').first)}',
      );
    }

    final path = query.isEmpty
        ? '/api/schedules/'
        : '/api/schedules/?${query.join('&')}';
    final envelope = await _send(method: 'GET', path: path, withAuth: true);
    final data = _asMap(envelope['data']);

    return _asList(
      data['schedules'],
    ).map((item) => _parseMeetingScheduleRecord(item)).toList();
  }

  Future<MeetingScheduleRecord> createMeetingSchedule({
    required String title,
    required DateTime startAt,
    required DateTime endAt,
    String notes = '',
  }) async {
    final envelope = await _send(
      method: 'POST',
      path: '/api/schedules/',
      withAuth: true,
      body: {
        'title': title,
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
        'notes': notes,
      },
    );
    final data = _asMap(envelope['data']);
    return _parseMeetingScheduleRecord(data['schedule']);
  }

  Future<MeetingScheduleRecord> updateMeetingSchedule({
    required int scheduleId,
    required String title,
    required DateTime startAt,
    required DateTime endAt,
    String notes = '',
  }) async {
    final envelope = await _send(
      method: 'PATCH',
      path: '/api/schedules/',
      withAuth: true,
      body: {
        'scheduleId': scheduleId,
        'title': title,
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
        'notes': notes,
      },
    );
    final data = _asMap(envelope['data']);
    return _parseMeetingScheduleRecord(data['schedule']);
  }

  Future<void> deleteMeetingSchedule(int scheduleId) async {
    await _send(
      method: 'DELETE',
      path: '/api/schedules/',
      withAuth: true,
      body: {'scheduleId': scheduleId},
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
    return '$sign₱$dollars$cents';
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
              .delete(uri, headers: headers, body: jsonEncode(body ?? const {}))
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

  BookingRecord _parseBookingRecord(dynamic raw) {
    final map = _asMap(raw);
    return BookingRecord(
      bookingId: _asInt(map['bookingId']),
      bookingCode: _asString(map['bookingCode']).isEmpty
          ? 'BK-${_asInt(map['bookingId']).toString().padLeft(6, '0')}'
          : _asString(map['bookingCode']),
      userId: _asInt(map['userId']),
      customerName: _asString(map['customerName']),
      email: _asString(map['email']),
      contactDetails: _asString(map['contactDetails']),
      spaceType: _asString(map['spaceType']),
      customerType: _asString(map['customerType']),
      status: _asString(map['status']),
      startAt: _asDateTime(map['startAt']),
      endAt: _asDateTime(map['endAt']),
    );
  }

  DashboardReservationItem _parseDashboardReservation(dynamic raw) {
    final map = _asMap(raw);
    return DashboardReservationItem(
      bookingId: _asInt(map['bookingId']),
      customerName: _asString(map['customerName']),
      email: _asString(map['email']),
      contactDetails: _asString(map['contactDetails']),
      startAt: _asDateTime(map['startAt']),
      endAt: _asDateTime(map['endAt']),
    );
  }

  DashboardActiveCustomerItem _parseDashboardActiveCustomer(dynamic raw) {
    final map = _asMap(raw);
    return DashboardActiveCustomerItem(
      sessionId: _asInt(map['sessionId']),
      name: _asString(map['name']),
      email: _asString(map['email']),
      membershipType: _asString(map['membershipType']),
      spaceUsed: _asString(map['spaceUsed']),
      timeIn: _asDateTime(map['timeIn']),
      status: _asString(map['status']).isEmpty
          ? 'Active'
          : _asString(map['status']),
    );
  }

  DashboardWeeklyActivityItem _parseDashboardWeeklyActivity(dynamic raw) {
    final map = _asMap(raw);
    final date = _asDateTime(map['date']);
    final label = _asString(map['label']);
    return DashboardWeeklyActivityItem(
      date: date,
      label: label.isEmpty ? _weekdayShort(date.weekday) : label,
      count: _asInt(map['count']),
    );
  }

  DashboardTransactionItem _parseDashboardTransaction(dynamic raw) {
    final map = _asMap(raw);
    return DashboardTransactionItem(
      transactionId: _asInt(map['transactionId']),
      customerName: _asString(map['customerName']),
      email: _asString(map['email']),
      amount: _asDouble(map['amount']),
      discountApplied: _asDouble(map['discountApplied']),
      finalAmount: _asDouble(map['finalAmount']),
      paymentMethod: _asString(map['paymentMethod']),
      status: _asString(map['status']),
      createdAt: _asDateTime(map['createdAt']),
    );
  }

  UserRecord _parseUserRecord(dynamic raw) {
    final map = _asMap(raw);
    return UserRecord(
      userId: _asInt(map['userId']),
      userCode: _asString(map['userCode']),
      firstName: _asString(map['firstName']),
      lastName: _asString(map['lastName']),
      email: _asString(map['email']),
      phoneNumber: _asString(map['phoneNumber']),
      userType: _asString(map['userType']),
      membershipType: _asString(map['membershipType']),
      isActive: _asBool(map['isActive']),
      history: _asList(map['history']).map((item) => _asString(item)).toList(),
    );
  }

  StaffAccountRecord _parseStaffAccountRecord(dynamic raw) {
    final map = _asMap(raw);
    return StaffAccountRecord(
      staffId: _asInt(map['staffId']),
      employeeId: _asString(map['employeeId']),
      fullName: _asString(map['fullName']),
      email: _asString(map['email']),
      role: _asString(map['role']),
      status: _asString(map['status']),
      createdAt: _asDateTime(map['createdAt']),
    );
  }

  PricingMembershipType _parsePricingMembershipType(dynamic raw) {
    final map = _asMap(raw);
    return PricingMembershipType(
      membershipTypeId: _asInt(map['membershipTypeId']),
      type: _asString(map['type']),
      duration: _asString(map['duration']),
      price: _asString(map['price']),
      benefits: _asString(map['benefits']),
    );
  }

  PricingPromotion _parsePricingPromotion(dynamic raw) {
    final map = _asMap(raw);
    return PricingPromotion(
      promoId: _asInt(map['promoId']),
      name: _asString(map['name']),
      type: _asString(map['type']),
      discount: _asString(map['discount']),
      expiry: _asDateTime(map['expiry']),
    );
  }

  LoyaltyRewardRecord _parseLoyaltyReward(dynamic raw) {
    final map = _asMap(raw);
    return LoyaltyRewardRecord(
      memberName: _asString(map['memberName']),
      entries: _asInt(map['entries']),
      freeHours: _asInt(map['freeHours']),
    );
  }

  SpacePricingRecord _parseSpacePricingRecord(dynamic raw) {
    final map = _asMap(raw);
    return SpacePricingRecord(
      boardRoomHourlyRate: _asDouble(map['boardRoomHourlyRate']),
      ordinarySpaceHourlyRate: _asDouble(map['ordinarySpaceHourlyRate']),
    );
  }

  MeetingScheduleRecord _parseMeetingScheduleRecord(dynamic raw) {
    final map = _asMap(raw);
    return MeetingScheduleRecord(
      scheduleId: _asInt(map['scheduleId']),
      title: _asString(map['title']),
      notes: _asString(map['notes']),
      startAt: _asDateTime(map['startAt']),
      endAt: _asDateTime(map['endAt']),
      createdAt: _asDateTime(map['createdAt']),
      updatedAt: _asDateTime(map['updatedAt']),
      createdByStaffId: _asInt(map['createdByStaffId']),
      createdByEmployeeId: _asString(map['createdByEmployeeId']),
      createdByName: _asString(map['createdByName']),
    );
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

  List<dynamic> _asList(dynamic value) {
    if (value is List) {
      return value;
    }
    return const <dynamic>[];
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

  DateTime _asDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    final raw = _asString(value);
    if (raw.isEmpty) {
      return DateTime.now();
    }

    final normalized = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
    return DateTime.tryParse(normalized) ?? DateTime.now();
  }

  bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    final normalized = _asString(value).toLowerCase();
    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'active';
  }

  String _weekdayShort(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return 'Day';
    }
  }
}
