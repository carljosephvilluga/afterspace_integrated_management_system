import 'dart:convert';

import 'package:aims/services/app_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  static const String _supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://yifpferiexemkghcipze.supabase.co',
  );
  static const String _supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    if (_supabaseAnonKey.isEmpty) {
      throw const AimsApiException(
        'Missing SUPABASE_ANON_KEY. Run Flutter with --dart-define=SUPABASE_ANON_KEY=your-anon-key.',
      );
    }
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
    _isInitialized = true;
  }

  Future<SupabaseClient> _client() async {
    await initialize();
    return Supabase.instance.client;
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
    try {
      if (withAuth && !AppSession.isAuthenticated) {
        throw const AimsApiException('Please log in first.');
      }
      final uri = Uri.parse('supabase://aims$path');
      final route = uri.path.endsWith('/') ? uri.path : '${uri.path}/';
      final requestBody = body ?? const <String, dynamic>{};

      switch ('$method $route') {
        case 'POST /api/auth/login/':
          return _handleLogin(requestBody);
        case 'POST /api/auth/logout/':
          AppSession.clear();
          return _ok(<String, dynamic>{});
        case 'GET /api/dashboard/admin/':
          return _handleAdminDashboard();
        case 'GET /api/dashboard/manager/':
          return _handleManagerDashboard();
        case 'GET /api/dashboard/staff/':
          return _handleStaffDashboard();
        case 'GET /api/bookings/':
          return _handleGetBookings(uri.queryParameters);
        case 'POST /api/bookings/':
          return _handleCreateBooking(requestBody);
        case 'POST /api/bookings/check-in/':
          return _handleCheckInBooking(requestBody);
        case 'POST /api/bookings/cancel/':
          return _handleCancelBooking(requestBody);
        case 'POST /api/sessions/check-in/':
          return _handleCheckInUser(requestBody);
        case 'POST /api/sessions/check-out/':
          return _handleCheckOutUser(requestBody);
        case 'GET /api/users/':
          return _handleGetUsers();
        case 'POST /api/users/':
          return _handleCreateUser(requestBody);
        case 'PATCH /api/users/':
          return _handleUpdateUser(requestBody);
        case 'DELETE /api/users/':
          return _handleDeleteUser(requestBody);
        case 'GET /api/staff-accounts/':
          return _handleGetStaffAccounts();
        case 'POST /api/staff-accounts/':
          return _handleCreateStaffAccount(requestBody);
        case 'PATCH /api/staff-accounts/':
          return _handleUpdateStaffAccount(requestBody);
        case 'DELETE /api/staff-accounts/':
          return _handleDeleteStaffAccount(requestBody);
        case 'GET /api/pricing-promos/':
          return _handleGetPricingPromos();
        case 'POST /api/pricing-promos/':
          return _handlePostPricingPromos(requestBody);
        case 'PATCH /api/pricing-promos/':
          return _handlePatchPricingPromos(requestBody);
        case 'DELETE /api/pricing-promos/':
          return _handleDeletePricingPromos(requestBody);
        case 'GET /api/reports/sales/':
          return _handleSalesReport(uri.queryParameters);
        case 'GET /api/reports/customer/':
          return _handleCustomerReport(uri.queryParameters);
        case 'GET /api/schedules/':
          return _handleGetSchedules(uri.queryParameters);
        case 'POST /api/schedules/':
          return _handleCreateSchedule(requestBody);
        case 'PATCH /api/schedules/':
          return _handleUpdateSchedule(requestBody);
        case 'DELETE /api/schedules/':
          return _handleDeleteSchedule(requestBody);
      }

      throw AimsApiException('Unsupported Supabase route: $method $route');
    } on PostgrestException catch (error) {
      throw AimsApiException(_friendlySupabaseMessage(error));
    } on AimsApiException {
      rethrow;
    } catch (_) {
      throw const AimsApiException(
        'Network error while contacting Supabase. Please try again.',
      );
    }
  }

  Future<Map<String, dynamic>> _handleLogin(Map<String, dynamic> body) async {
    final client = await _client();
    final role = _normalizeLoginRole(_asString(body['role']));
    final identifier = _asString(
      body['employeeId'] ??
          body['staffId'] ??
          body['managerId'] ??
          body['adminId'] ??
          body['email'],
    );
    final password = _asString(body['password']);
    if (identifier.isEmpty || password.isEmpty) {
      throw const AimsApiException('Missing login credentials.');
    }

    final result = await client.rpc(
      'aims_verify_staff_login',
      params: <String, dynamic>{
        'input_role': role,
        'input_identifier': identifier,
        'input_password': password,
      },
    );
    final rows = _rows(result);
    if (rows.isEmpty) {
      throw const AimsApiException('Invalid login credentials.');
    }

    final user = rows.first;
    AppSession.saveAuth(
      token:
          'supabase:${user['staff_id']}:${DateTime.now().millisecondsSinceEpoch}',
      user: user,
    );
    return _ok(<String, dynamic>{'token': AppSession.token, 'user': user});
  }

  Future<Map<String, dynamic>> _handleAdminDashboard() async {
    final staff = await _tableRows('staff_accounts');
    final users = await _tableRows('users');
    final sessions = await _tableRows('sessions');
    final transactions = await _tableRows('transactions');
    final bookings = await _tableRows('bookings');

    return _ok(<String, dynamic>{
      'staffCount': staff.length,
      'userCount': users.length,
      'activeSessions': sessions
          .where((row) => _asString(row['status']).toLowerCase() == 'active')
          .length,
      'totalRevenue': transactions.fold<double>(
        0,
        (sum, row) => sum + _asDouble(row['final_amount']),
      ),
      'bookingCount': bookings.length,
    });
  }

  Future<Map<String, dynamic>> _handleManagerDashboard() async {
    final summary = await _managerSummary();
    return _ok(<String, dynamic>{
      ...summary,
      'pendingReservations': await _pendingReservations(limit: 8),
      'latestTransactions': await _latestTransactions(limit: 10),
    });
  }

  Future<Map<String, dynamic>> _handleStaffDashboard() async {
    final client = await _client();
    final sessions = await _tableRows('sessions');
    final bookings = await _tableRows('bookings');
    final activeSessions = sessions
        .where((row) => _asString(row['status']).toLowerCase() == 'active')
        .toList();
    final weeklyActivity = await _weeklyActivity();

    final activeRows = await client
        .from('sessions')
        .select()
        .eq('status', 'Active')
        .order('check_in', ascending: false)
        .limit(8);

    return _ok(<String, dynamic>{
      'activeCustomers': activeSessions
          .map((row) => row['user_id'])
          .toSet()
          .length,
      'reservedBookings': bookings
          .where((row) => _asString(row['status']).toLowerCase() == 'pending')
          .length,
      'activeSessions': activeSessions.length,
      'weeklyActivity': weeklyActivity,
      'pendingReservations': await _pendingReservations(limit: 8),
      'activeCustomerRows': await _activeCustomerPayloads(_rows(activeRows)),
      'latestTransactions': await _latestTransactions(limit: 8),
    });
  }

  Future<Map<String, dynamic>> _handleGetBookings(
    Map<String, String> queryParameters,
  ) async {
    final client = await _client();
    final limit = _clampInt(
      int.tryParse(queryParameters['limit'] ?? '') ?? 200,
      1,
      500,
    );
    dynamic query = client.from('bookings').select();
    final status = _asString(queryParameters['status']);
    if (status.isNotEmpty) {
      query = query.eq('status', _bookingStatusFromFilter(status));
    }
    final date = _asString(queryParameters['date']);
    if (date.isNotEmpty) {
      query = query.eq('booking_date', date);
    }
    final rows = _rows(
      await query
          .order('booking_date', ascending: true)
          .order('start_time', ascending: true)
          .order('booking_id', ascending: true)
          .limit(limit),
    );
    return _ok(<String, dynamic>{'bookings': await _bookingPayloads(rows)});
  }

  Future<Map<String, dynamic>> _handleCreateBooking(
    Map<String, dynamic> body,
  ) async {
    final client = await _client();
    final customerName = _requiredString(body, 'customerName');
    final contactDetails = _requiredString(body, 'contactDetails');
    final spaceType = _spaceLabel(_requiredString(body, 'spaceType'));
    final customerType = _asString(body['customerType']).isEmpty
        ? 'Guest'
        : _asString(body['customerType']);
    final startAt = _asDateTime(_requiredString(body, 'startAt'));
    final endAt = _asDateTime(_requiredString(body, 'endAt'));
    if (!endAt.isAfter(startAt)) {
      throw const AimsApiException('endAt must be later than startAt.');
    }
    if (_dateSql(startAt) != _dateSql(endAt)) {
      throw const AimsApiException(
        'Booking startAt and endAt must be on the same date.',
      );
    }

    final userId = await _resolveOrCreateUser(customerName, contactDetails);
    final booking = _asMap(
      await client
          .from('bookings')
          .insert(<String, dynamic>{
            'user_id': userId,
            'booking_date': _dateSql(startAt),
            'start_time': _timeSql(startAt),
            'end_time': _timeSql(endAt),
            'status': 'Pending',
          })
          .select()
          .single(),
    );
    final bookingId = _asInt(booking['booking_id']);
    await client.from('booking_meta').insert(<String, dynamic>{
      'booking_id': bookingId,
      'space_type': spaceType,
      'customer_type': customerType,
    });
    return _ok(<String, dynamic>{
      'booking': await _fetchBookingPayload(bookingId),
    });
  }

  Future<Map<String, dynamic>> _handleCheckInBooking(
    Map<String, dynamic> body,
  ) async {
    final client = await _client();
    final bookingId = _asInt(body['bookingId']);
    if (bookingId <= 0) {
      throw const AimsApiException('Missing required field: bookingId.');
    }

    final booking = _asMap(
      await client
          .from('bookings')
          .select()
          .eq('booking_id', bookingId)
          .maybeSingle(),
    );
    if (booking.isEmpty) {
      throw const AimsApiException('Booking not found.');
    }
    if (_asString(booking['status']).toLowerCase() == 'cancelled') {
      throw const AimsApiException('Cancelled bookings cannot be checked in.');
    }
    final userId = _asInt(booking['user_id']);
    await client
        .from('bookings')
        .update(<String, dynamic>{'status': 'Confirmed'})
        .eq('booking_id', bookingId);

    final sessionId = await _ensureActiveSession(userId);
    final meta = await _bookingMeta(bookingId);
    await client.from('session_meta').upsert(<String, dynamic>{
      'session_id': sessionId,
      'space_used': _spaceLabel(
        _asString(meta['space_type']).isEmpty
            ? 'Open Space'
            : _asString(meta['space_type']),
      ),
    }, onConflict: 'session_id');
    await client
        .from('users')
        .update(<String, dynamic>{'status': 'Active'})
        .eq('user_id', userId);
    await _appendUserHistory(userId, 'User checked in');
    return _ok(<String, dynamic>{
      'bookingId': bookingId,
      'sessionId': sessionId,
      'status': 'checkedIn',
    });
  }

  Future<Map<String, dynamic>> _handleCancelBooking(
    Map<String, dynamic> body,
  ) async {
    final client = await _client();
    final bookingId = _asInt(body['bookingId']);
    if (bookingId <= 0) {
      throw const AimsApiException('Missing required field: bookingId.');
    }
    await client
        .from('bookings')
        .update(<String, dynamic>{'status': 'Cancelled'})
        .eq('booking_id', bookingId);
    return _ok(<String, dynamic>{
      'bookingId': bookingId,
      'status': 'cancelled',
    });
  }

  Future<Map<String, dynamic>> _handleCheckInUser(
    Map<String, dynamic> body,
  ) async {
    final client = await _client();
    final userEmail = _requiredString(body, 'userEmail').toLowerCase();
    final spaceUsed = _spaceLabel(
      _asString(body['spaceUsed']).isEmpty
          ? 'Open Space'
          : _asString(body['spaceUsed']),
    );
    final user = await _findUserByEmail(userEmail);
    if (user.isEmpty) {
      throw const AimsApiException('User account not found for this email.');
    }
    final userId = _asInt(user['user_id']);
    final existing = await _activeSessionForUser(userId);
    if (existing.isNotEmpty) {
      return _ok(<String, dynamic>{
        'sessionId': _asInt(existing['session_id']),
        'userId': userId,
        'status': 'active',
        'checkInAt': _asString(existing['check_in']),
        'alreadyActive': true,
      });
    }

    final checkInAt = _asString(body['checkInAt']).isEmpty
        ? DateTime.now()
        : _asDateTime(body['checkInAt']);
    final session = _asMap(
      await client
          .from('sessions')
          .insert(<String, dynamic>{
            'user_id': userId,
            'check_in': checkInAt.toIso8601String(),
            'check_out': null,
            'status': 'Active',
          })
          .select()
          .single(),
    );
    final sessionId = _asInt(session['session_id']);
    await client.from('session_meta').insert(<String, dynamic>{
      'session_id': sessionId,
      'space_used': spaceUsed,
    });
    await client
        .from('users')
        .update(<String, dynamic>{'status': 'Active'})
        .eq('user_id', userId);
    await _appendUserHistory(userId, 'User checked in');
    return _ok(<String, dynamic>{
      'sessionId': sessionId,
      'userId': userId,
      'status': 'active',
      'checkInAt': checkInAt.toIso8601String(),
      'alreadyActive': false,
    });
  }

  Future<Map<String, dynamic>> _handleCheckOutUser(
    Map<String, dynamic> body,
  ) async {
    final client = await _client();
    final userEmail = _requiredString(body, 'userEmail').toLowerCase();
    final user = await _findUserByEmail(userEmail);
    if (user.isEmpty) {
      throw const AimsApiException('User account not found for this email.');
    }
    final userId = _asInt(user['user_id']);
    final session = await _activeSessionForUser(userId);
    if (session.isEmpty) {
      throw const AimsApiException('No active session found for this user.');
    }
    final sessionId = _asInt(session['session_id']);
    final amount = _asDouble(
      body['amount'],
    ).clamp(0, double.infinity).toDouble();
    final discountApplied = _asDouble(
      body['discountApplied'],
    ).clamp(0, double.infinity).toDouble();
    final finalAmount = (amount - discountApplied)
        .clamp(0, double.infinity)
        .toDouble();
    final paymentMethod = _asString(body['paymentMethod']).isEmpty
        ? 'cash'
        : _asString(body['paymentMethod']);
    final paymentStatus = _asString(body['paymentStatus']).isEmpty
        ? 'paid'
        : _asString(body['paymentStatus']).toLowerCase();
    final checkOutAt = DateTime.now();

    await client
        .from('sessions')
        .update(<String, dynamic>{
          'check_out': checkOutAt.toIso8601String(),
          'status': 'Completed',
        })
        .eq('session_id', sessionId);
    final transaction = _asMap(
      await client
          .from('transactions')
          .insert(<String, dynamic>{
            'user_id': userId,
            'session_id': sessionId,
            'amount': amount,
            'discount_applied': discountApplied,
            'final_amount': finalAmount,
            'payment_method': paymentMethod,
            'status': paymentStatus,
          })
          .select()
          .single(),
    );
    if ((await _activeSessionForUser(userId)).isEmpty) {
      await client
          .from('users')
          .update(<String, dynamic>{'status': 'Inactive'})
          .eq('user_id', userId);
    }
    await _appendUserHistory(userId, 'User checked out & paid');
    return _ok(<String, dynamic>{
      'transactionId': _asInt(transaction['transaction_id']),
      'sessionId': sessionId,
      'userId': userId,
      'amount': amount,
      'discountApplied': discountApplied,
      'finalAmount': finalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'checkOutAt': checkOutAt.toIso8601String(),
    });
  }

  Future<Map<String, dynamic>> _handleGetUsers() async {
    final users = await _tableRows('users');
    final profiles = _byIntKey(await _tableRows('user_profiles'), 'user_id');
    final payloads =
        users
            .map((row) => _userPayload(row, profiles[_asInt(row['user_id'])]))
            .toList()
          ..sort((a, b) => _asInt(b['userId']).compareTo(_asInt(a['userId'])));
    return _ok(<String, dynamic>{'users': payloads});
  }

  Future<Map<String, dynamic>> _handleCreateUser(
    Map<String, dynamic> body,
  ) async {
    final client = await _client();
    final firstName = _requiredString(body, 'firstName');
    final lastName = _requiredString(body, 'lastName');
    final email = _requiredString(body, 'email').toLowerCase();
    final phoneNumber = _requiredString(body, 'phoneNumber');
    final userType = _normalizeUserType(_asString(body['userType']));
    final membershipType = _normalizeMembershipType(
      _asString(body['membershipType']),
    );
    final status = _asBool(body['isActive']) ? 'Active' : 'Inactive';
    final user = _asMap(
      await client
          .from('users')
          .insert(<String, dynamic>{
            'full_name': '$firstName $lastName'.trim(),
            'contact_number': phoneNumber,
            'email': email,
            'status': status,
          })
          .select()
          .single(),
    );
    final userId = _asInt(user['user_id']);
    await client.from('user_profiles').insert(<String, dynamic>{
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'user_type': userType,
      'membership_type': membershipType,
      'history_json': jsonEncode(<String>[_historyLabel('User added')]),
    });
    await _upsertMembership(userId, membershipType);
    return _ok(<String, dynamic>{'user': await _fetchUserPayload(userId)});
  }

  Future<Map<String, dynamic>> _handleUpdateUser(
    Map<String, dynamic> body,
  ) async {
    final client = await _client();
    final userId = _asInt(body['userId']);
    if (userId <= 0) {
      throw const AimsApiException('Missing required field: userId.');
    }
    final firstName = _requiredString(body, 'firstName');
    final lastName = _requiredString(body, 'lastName');
    final email = _requiredString(body, 'email').toLowerCase();
    final phoneNumber = _requiredString(body, 'phoneNumber');
    final userType = _normalizeUserType(_asString(body['userType']));
    final membershipType = _normalizeMembershipType(
      _asString(body['membershipType']),
    );
    final status = _asBool(body['isActive']) ? 'Active' : 'Inactive';
    final existing = await _fetchUserPayload(userId);
    final history = <String>[
      ..._asList(existing['history']).map(_asString),
      _historyLabel('User edited'),
    ];

    await client
        .from('users')
        .update(<String, dynamic>{
          'full_name': '$firstName $lastName'.trim(),
          'contact_number': phoneNumber,
          'email': email,
          'status': status,
        })
        .eq('user_id', userId);
    await client.from('user_profiles').upsert(<String, dynamic>{
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'user_type': userType,
      'membership_type': membershipType,
      'history_json': jsonEncode(history),
    }, onConflict: 'user_id');
    await _upsertMembership(userId, membershipType);
    return _ok(<String, dynamic>{'user': await _fetchUserPayload(userId)});
  }

  Future<Map<String, dynamic>> _handleDeleteUser(
    Map<String, dynamic> body,
  ) async {
    final client = await _client();
    final userId = _asInt(body['userId']);
    if (userId <= 0) {
      throw const AimsApiException('Missing required field: userId.');
    }
    await client.from('users').delete().eq('user_id', userId);
    return _ok(<String, dynamic>{'userId': userId});
  }

  Future<Map<String, dynamic>> _handleGetStaffAccounts() async {
    final rows = await _tableRows('staff_accounts');
    final accounts = rows.map(_staffPayload).toList()
      ..sort((a, b) => _asInt(b['staffId']).compareTo(_asInt(a['staffId'])));
    return _ok(<String, dynamic>{'staffAccounts': accounts});
  }

  Future<Map<String, dynamic>> _handleCreateStaffAccount(
    Map<String, dynamic> body,
  ) async {
    final client = await _client();
    final role = _normalizeStaffRole(_requiredString(body, 'role'));
    final employeeId = _asString(body['employeeId']).isEmpty
        ? await _generateNextEmployeeId(role)
        : _asString(body['employeeId']).toUpperCase();
    final password = _requiredString(body, 'password');
    if (password.length < 6) {
      throw const AimsApiException('Password must be at least 6 characters.');
    }
    final result = await client.rpc(
      'aims_create_staff_account',
      params: <String, dynamic>{
        'input_employee_id': employeeId,
        'input_full_name': _requiredString(body, 'fullName'),
        'input_email': _requiredString(body, 'email').toLowerCase(),
        'input_password': password,
        'input_role': role,
        'input_status': _normalizeStaffStatus(_asString(body['status'])),
      },
    );
    return _ok(<String, dynamic>{
      'staffAccount': _staffPayload(_rows(result).first),
    });
  }

  Future<Map<String, dynamic>> _handleUpdateStaffAccount(
    Map<String, dynamic> body,
  ) async {
    final client = await _client();
    final staffId = _asInt(body['staffId']);
    if (staffId <= 0) {
      throw const AimsApiException('Missing required field: staffId.');
    }
    final password = _asString(body['password']);
    if (password.isNotEmpty && password.length < 6) {
      throw const AimsApiException('Password must be at least 6 characters.');
    }
    final result = await client.rpc(
      'aims_update_staff_account',
      params: <String, dynamic>{
        'input_staff_id': staffId,
        'input_employee_id': _requiredString(body, 'employeeId'),
        'input_full_name': _requiredString(body, 'fullName'),
        'input_email': _requiredString(body, 'email').toLowerCase(),
        'input_password': password,
        'input_role': _normalizeStaffRole(_requiredString(body, 'role')),
        'input_status': _normalizeStaffStatus(_asString(body['status'])),
      },
    );
    final rows = _rows(result);
    if (rows.isEmpty) {
      throw const AimsApiException('Staff account not found.');
    }
    return _ok(<String, dynamic>{'staffAccount': _staffPayload(rows.first)});
  }

  Future<Map<String, dynamic>> _handleDeleteStaffAccount(
    Map<String, dynamic> body,
  ) async {
    final client = await _client();
    final staffId = _asInt(body['staffId']);
    if (staffId <= 0) {
      throw const AimsApiException('Missing required field: staffId.');
    }
    if (staffId == _currentStaffId) {
      throw const AimsApiException(
        'You cannot delete your own account while logged in.',
      );
    }
    await client.from('staff_accounts').delete().eq('staff_id', staffId);
    return _ok(<String, dynamic>{'staffId': staffId});
  }

  Future<Map<String, dynamic>> _handleGetPricingPromos() async {
    final membershipRows = await _tableRows('membership_types');
    final promotionRows = await _tableRows('promotions');
    final pricing = await _spacePricingPayload();
    final loyalty = await _loyaltyPayloads();
    return _ok(<String, dynamic>{
      'membershipTypes': membershipRows.map(_membershipPayload).toList()
        ..sort(
          (a, b) => _asInt(
            b['membershipTypeId'],
          ).compareTo(_asInt(a['membershipTypeId'])),
        ),
      'promotions': promotionRows.map(_promotionPayload).toList(),
      'loyaltyRewards': loyalty,
      'spacePricing': pricing,
    });
  }

  Future<Map<String, dynamic>> _handlePostPricingPromos(
    Map<String, dynamic> body,
  ) async {
    final kind = _requiredString(body, 'kind').toLowerCase();
    if (kind == 'membership') {
      final client = await _client();
      final row = _asMap(
        await client
            .from('membership_types')
            .insert(<String, dynamic>{
              'plan_name': _requiredString(body, 'type'),
              'duration_label': _requiredString(body, 'duration'),
              'price_label': _requiredString(body, 'price'),
              'benefits': _requiredString(body, 'benefits'),
              'created_by_staff_id': _currentStaffId == 0
                  ? null
                  : _currentStaffId,
            })
            .select()
            .single(),
      );
      return _ok(<String, dynamic>{'membershipType': _membershipPayload(row)});
    }
    if (kind == 'promotion') {
      final client = await _client();
      final row = _asMap(
        await client
            .from('promotions')
            .insert(<String, dynamic>{
              'promo_name': _requiredString(body, 'name'),
              'promo_type': _requiredString(body, 'type'),
              'discount_rate': _parseDiscountRate(
                _requiredString(body, 'discount'),
              ),
              'discount_label': _requiredString(body, 'discount'),
              'start_date': _dateSql(DateTime.now()),
              'end_date': _dateSql(
                _asDateTime(_requiredString(body, 'expiry')),
              ),
              'benefits': _asString(body['benefits']).isEmpty
                  ? null
                  : _asString(body['benefits']),
            })
            .select()
            .single(),
      );
      return _ok(<String, dynamic>{'promotion': _promotionPayload(row)});
    }
    throw const AimsApiException('kind must be membership or promotion.');
  }

  Future<Map<String, dynamic>> _handlePatchPricingPromos(
    Map<String, dynamic> body,
  ) async {
    final kind = _requiredString(body, 'kind').toLowerCase();
    final client = await _client();
    if (kind == 'membership') {
      final id = _asInt(body['membershipTypeId']);
      await client
          .from('membership_types')
          .update(<String, dynamic>{
            'plan_name': _requiredString(body, 'type'),
            'duration_label': _requiredString(body, 'duration'),
            'price_label': _requiredString(body, 'price'),
            'benefits': _requiredString(body, 'benefits'),
          })
          .eq('membership_type_id', id);
      final row = _asMap(
        await client
            .from('membership_types')
            .select()
            .eq('membership_type_id', id)
            .single(),
      );
      return _ok(<String, dynamic>{'membershipType': _membershipPayload(row)});
    }
    if (kind == 'pricing') {
      final boardRoomRate = _asDouble(body['boardRoomHourlyRate']);
      final ordinarySpaceRate = _asDouble(body['ordinarySpaceHourlyRate']);
      if (boardRoomRate <= 0 || ordinarySpaceRate <= 0) {
        throw const AimsApiException(
          'boardRoomHourlyRate and ordinarySpaceHourlyRate must be greater than 0.',
        );
      }
      await client.from('space_pricing').upsert(<String, dynamic>{
        'pricing_id': 1,
        'board_room_hourly_rate': boardRoomRate,
        'ordinary_space_hourly_rate': ordinarySpaceRate,
        'updated_by_staff_id': _currentStaffId == 0 ? null : _currentStaffId,
      }, onConflict: 'pricing_id');
      return _ok(<String, dynamic>{
        'spacePricing': await _spacePricingPayload(),
      });
    }
    throw const AimsApiException('kind must be membership or pricing.');
  }

  Future<Map<String, dynamic>> _handleDeletePricingPromos(
    Map<String, dynamic> body,
  ) async {
    final client = await _client();
    final kind = _requiredString(body, 'kind').toLowerCase();
    if (kind == 'membership') {
      final id = _asInt(body['membershipTypeId']);
      await client
          .from('membership_types')
          .delete()
          .eq('membership_type_id', id);
      return _ok(<String, dynamic>{'membershipTypeId': id});
    }
    if (kind == 'promotion') {
      final id = _asInt(body['promoId']);
      await client.from('promotions').delete().eq('promo_id', id);
      return _ok(<String, dynamic>{'promoId': id});
    }
    throw const AimsApiException('kind must be membership or promotion.');
  }

  Future<Map<String, dynamic>> _handleSalesReport(
    Map<String, String> queryParameters,
  ) async {
    final range = _asString(queryParameters['range']).isEmpty
        ? 'monthly'
        : _asString(queryParameters['range']).toLowerCase();
    if (!['daily', 'weekly', 'monthly', 'yearly'].contains(range)) {
      throw const AimsApiException(
        'range must be daily, weekly, monthly, or yearly.',
      );
    }
    final points = await _salesPoints(range);
    final revenues = points
        .map((point) => _asDouble(point['revenue']))
        .toList();
    final transactions = points
        .map((point) => _asInt(point['transactions']))
        .toList();
    final maxRevenue = [1.0, ...revenues].reduce((a, b) => a > b ? a : b);
    final maxTransactions = [
      1,
      ...transactions,
    ].reduce((a, b) => a > b ? a : b);
    final lineValues = transactions
        .map((count) => (count / maxTransactions) * (maxRevenue * 0.6))
        .toList();
    var highlightIndex = 0;
    for (var i = revenues.length - 1; i >= 0; i--) {
      if (revenues[i] > 0) {
        highlightIndex = i;
        break;
      }
    }
    return _ok(<String, dynamic>{
      'range': range,
      'labels': points.map((point) => _asString(point['label'])).toList(),
      'tooltipTitles': points
          .map((point) => _asString(point['title']))
          .toList(),
      'tooltipValues': points
          .map((point) => '₱${_asDouble(point['revenue']).toStringAsFixed(2)}')
          .toList(),
      'areaValues': revenues,
      'lineValues': lineValues,
      'highlightX': highlightIndex,
      'maxY': (maxRevenue * 1.25) > 10 ? maxRevenue * 1.25 : 10,
      'totals': <String, dynamic>{
        'revenue': revenues.fold<double>(0, (sum, value) => sum + value),
        'transactions': transactions.fold<int>(0, (sum, value) => sum + value),
      },
    });
  }

  Future<Map<String, dynamic>> _handleCustomerReport(
    Map<String, String> queryParameters,
  ) async {
    final days = _clampInt(
      int.tryParse(queryParameters['days'] ?? '') ?? 7,
      1,
      365,
    );
    final today = _today();
    final endAt = today.add(const Duration(days: 1));
    final startAt = today.subtract(Duration(days: days - 1));
    final sessions = await _sessionsBetween(startAt, endAt);
    final profiles = _byIntKey(await _tableRows('user_profiles'), 'user_id');
    final groupsByUser = <int, String>{};
    for (final session in sessions) {
      final userId = _asInt(session['user_id']);
      final membership = _asString(
        profiles[userId]?['membership_type'],
      ).toLowerCase();
      groupsByUser[userId] = switch (membership) {
        'monthly membership' => 'Monthly Membership',
        'loyalty rewards' => 'Loyal Customers',
        'annual' => 'Monthly Subscription',
        _ => 'Walk-in',
      };
    }
    final monthlyMembership = groupsByUser.values
        .where((value) => value == 'Monthly Membership')
        .length;
    final walkIn = groupsByUser.values
        .where((value) => value == 'Walk-in')
        .length;
    final monthlySubscription = groupsByUser.values
        .where((value) => value == 'Monthly Subscription')
        .length;
    final loyalCustomers = groupsByUser.values
        .where((value) => value == 'Loyal Customers')
        .length;
    final maxValue = [
      1,
      monthlyMembership,
      walkIn,
      monthlySubscription,
      loyalCustomers,
    ].reduce((a, b) => a > b ? a : b);
    return _ok(<String, dynamic>{
      'days': days,
      'from': _dateSql(startAt),
      'to': _dateSql(endAt.subtract(const Duration(days: 1))),
      'monthlyMembership': monthlyMembership,
      'walkIn': walkIn,
      'monthlySubscription': monthlySubscription,
      'loyalCustomers': loyalCustomers,
      'totalCustomers': groupsByUser.length,
      'maxValue': maxValue,
      'categories': <Map<String, dynamic>>[
        {
          'key': 'monthlyMembership',
          'label': 'Monthly Membership',
          'count': monthlyMembership,
        },
        {'key': 'walkIn', 'label': 'Walk-in', 'count': walkIn},
        {
          'key': 'monthlySubscription',
          'label': 'Monthly Subscription',
          'count': monthlySubscription,
        },
        {
          'key': 'loyalCustomers',
          'label': 'Loyal Customers',
          'count': loyalCustomers,
        },
      ],
    });
  }

  Future<Map<String, dynamic>> _handleGetSchedules(
    Map<String, String> queryParameters,
  ) async {
    final client = await _client();
    dynamic query = client.from('meeting_schedules').select();
    final from = _asString(queryParameters['from']);
    final to = _asString(queryParameters['to']);
    if (from.isNotEmpty) {
      query = query.gte('end_at', '${from}T00:00:00');
    }
    if (to.isNotEmpty) {
      final toExclusive = _asDateTime(to).add(const Duration(days: 1));
      query = query.lt('start_at', toExclusive.toIso8601String());
    }
    final rows = _rows(
      await query
          .order('start_at', ascending: true)
          .order('schedule_id', ascending: true)
          .limit(500),
    );
    return _ok(<String, dynamic>{'schedules': await _schedulePayloads(rows)});
  }

  Future<Map<String, dynamic>> _handleCreateSchedule(
    Map<String, dynamic> body,
  ) async {
    final client = await _client();
    final title = _requiredString(body, 'title');
    final startAt = _asDateTime(_requiredString(body, 'startAt'));
    final endAt = _asDateTime(_requiredString(body, 'endAt'));
    if (!endAt.isAfter(startAt)) {
      throw const AimsApiException('endAt must be later than startAt.');
    }
    final row = _asMap(
      await client
          .from('meeting_schedules')
          .insert(<String, dynamic>{
            'title': title,
            'notes': _asString(body['notes']).isEmpty
                ? null
                : _asString(body['notes']),
            'start_at': startAt.toIso8601String(),
            'end_at': endAt.toIso8601String(),
            'created_by_staff_id': _currentStaffId == 0
                ? null
                : _currentStaffId,
          })
          .select()
          .single(),
    );
    return _ok(<String, dynamic>{'schedule': await _schedulePayload(row)});
  }

  Future<Map<String, dynamic>> _handleUpdateSchedule(
    Map<String, dynamic> body,
  ) async {
    final client = await _client();
    final scheduleId = _asInt(body['scheduleId']);
    final title = _requiredString(body, 'title');
    final startAt = _asDateTime(_requiredString(body, 'startAt'));
    final endAt = _asDateTime(_requiredString(body, 'endAt'));
    if (!endAt.isAfter(startAt)) {
      throw const AimsApiException('endAt must be later than startAt.');
    }
    await client
        .from('meeting_schedules')
        .update(<String, dynamic>{
          'title': title,
          'notes': _asString(body['notes']).isEmpty
              ? null
              : _asString(body['notes']),
          'start_at': startAt.toIso8601String(),
          'end_at': endAt.toIso8601String(),
        })
        .eq('schedule_id', scheduleId);
    final row = _asMap(
      await client
          .from('meeting_schedules')
          .select()
          .eq('schedule_id', scheduleId)
          .single(),
    );
    return _ok(<String, dynamic>{'schedule': await _schedulePayload(row)});
  }

  Future<Map<String, dynamic>> _handleDeleteSchedule(
    Map<String, dynamic> body,
  ) async {
    final client = await _client();
    final scheduleId = _asInt(body['scheduleId']);
    if (scheduleId <= 0) {
      throw const AimsApiException('Missing required field: scheduleId.');
    }
    await client
        .from('meeting_schedules')
        .delete()
        .eq('schedule_id', scheduleId);
    return _ok(<String, dynamic>{'scheduleId': scheduleId});
  }

  Map<String, dynamic> _ok(Map<String, dynamic> data) {
    return <String, dynamic>{'ok': true, 'data': data};
  }

  String _friendlySupabaseMessage(PostgrestException error) {
    if (error.code == '23505') {
      return 'Duplicate record already exists.';
    }
    if (error.message.trim().isNotEmpty) {
      return error.message;
    }
    return 'Supabase request failed.';
  }

  Future<List<Map<String, dynamic>>> _tableRows(String table) async {
    final client = await _client();
    return _rows(await client.from(table).select());
  }

  List<Map<String, dynamic>> _rows(dynamic value) {
    if (value is List) {
      return value.map(_asMap).where((row) => row.isNotEmpty).toList();
    }
    final row = _asMap(value);
    return row.isEmpty ? <Map<String, dynamic>>[] : <Map<String, dynamic>>[row];
  }

  Map<int, Map<String, dynamic>> _byIntKey(
    List<Map<String, dynamic>> rows,
    String key,
  ) {
    return <int, Map<String, dynamic>>{
      for (final row in rows) _asInt(row[key]): row,
    };
  }

  Future<Map<String, dynamic>> _managerSummary() async {
    final sessions = await _tableRows('sessions');
    final transactions = await _tableRows('transactions');
    final bookings = await _tableRows('bookings');
    final today = _today();
    final tomorrow = today.add(const Duration(days: 1));
    final todaysSessions = sessions.where((row) {
      final value = _asDateTime(row['check_in']);
      return !value.isBefore(today) && value.isBefore(tomorrow);
    }).toList();
    final todaysTransactions = transactions.where((row) {
      final value = _asDateTime(row['created_at']);
      return !value.isBefore(today) && value.isBefore(tomorrow);
    }).toList();

    return <String, dynamic>{
      'customersToday': todaysSessions
          .map((row) => row['user_id'])
          .toSet()
          .length,
      'revenueToday': todaysTransactions.fold<double>(
        0,
        (sum, row) => sum + _asDouble(row['final_amount']),
      ),
      'reservedBookings': bookings
          .where((row) => _asString(row['status']).toLowerCase() == 'pending')
          .length,
      'completedPayments': todaysTransactions
          .where((row) => _asString(row['status']).toLowerCase() == 'paid')
          .length,
    };
  }

  Future<List<Map<String, dynamic>>> _pendingReservations({
    required int limit,
  }) async {
    final client = await _client();
    final rows = _rows(
      await client
          .from('bookings')
          .select()
          .eq('status', 'Pending')
          .order('booking_date', ascending: true)
          .order('start_time', ascending: true)
          .order('booking_id', ascending: true)
          .limit(limit),
    );
    final users = await _userByIdMap();
    return rows.map((row) {
      final user = users[_asInt(row['user_id'])] ?? const <String, dynamic>{};
      final date = _asString(row['booking_date']);
      return <String, dynamic>{
        'bookingId': _asInt(row['booking_id']),
        'customerName': _asString(user['full_name']),
        'email': _asString(user['email']),
        'contactDetails': _asString(user['email']).isNotEmpty
            ? _asString(user['email'])
            : _asString(user['contact_number']),
        'startAt': '$date ${_asString(row['start_time'])}',
        'endAt': '$date ${_asString(row['end_time'])}',
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _latestTransactions({
    required int limit,
  }) async {
    final client = await _client();
    final rows = _rows(
      await client
          .from('transactions')
          .select()
          .order('created_at', ascending: false)
          .order('transaction_id', ascending: false)
          .limit(limit),
    );
    final users = await _userByIdMap();
    return rows.map((row) {
      final user = users[_asInt(row['user_id'])] ?? const <String, dynamic>{};
      return <String, dynamic>{
        'transactionId': _asInt(row['transaction_id']),
        'customerName': _asString(user['full_name']),
        'email': _asString(user['email']),
        'amount': _asDouble(row['amount']),
        'discountApplied': _asDouble(row['discount_applied']),
        'finalAmount': _asDouble(row['final_amount']),
        'paymentMethod': _asString(row['payment_method']).isEmpty
            ? 'cash'
            : _asString(row['payment_method']),
        'status': _asString(row['status']).isEmpty
            ? 'paid'
            : _asString(row['status']),
        'createdAt': _asString(row['created_at']),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _weeklyActivity() async {
    final today = _today();
    final weekStart = today.subtract(const Duration(days: 6));
    final weekEnd = today.add(const Duration(days: 1));
    final sessions = await _sessionsBetween(weekStart, weekEnd);
    final counts = <String, int>{};
    for (final session in sessions) {
      final key = _dateSql(_asDateTime(session['check_in']));
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return List<Map<String, dynamic>>.generate(7, (index) {
      final day = weekStart.add(Duration(days: index));
      final key = _dateSql(day);
      return <String, dynamic>{
        'date': key,
        'label': _weekdayShort(day.weekday),
        'count': counts[key] ?? 0,
      };
    });
  }

  Future<List<Map<String, dynamic>>> _activeCustomerPayloads(
    List<Map<String, dynamic>> sessions,
  ) async {
    final users = await _userByIdMap();
    final sessionMeta = await _sessionMetaByIdMap();
    final memberships = await _membershipByUserMap();
    return sessions.map((session) {
      final user =
          users[_asInt(session['user_id'])] ?? const <String, dynamic>{};
      final meta =
          sessionMeta[_asInt(session['session_id'])] ??
          const <String, dynamic>{};
      final membership =
          memberships[_asInt(session['user_id'])] ?? const <String, dynamic>{};
      return <String, dynamic>{
        'sessionId': _asInt(session['session_id']),
        'name': _asString(user['full_name']),
        'email': _asString(user['email']),
        'spaceUsed': _asString(meta['space_used']).isEmpty
            ? 'Open Space'
            : _asString(meta['space_used']),
        'membershipType': _asString(membership['membership_type']).isEmpty
            ? 'Open Time'
            : _asString(membership['membership_type']),
        'timeIn': _asString(session['check_in']),
        'status': 'Active',
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _bookingPayloads(
    List<Map<String, dynamic>> bookings,
  ) async {
    final users = await _userByIdMap();
    final metas = _byIntKey(await _tableRows('booking_meta'), 'booking_id');
    return bookings
        .map(
          (row) => _bookingPayload(
            row,
            users[_asInt(row['user_id'])],
            metas[_asInt(row['booking_id'])],
          ),
        )
        .toList();
  }

  Future<Map<String, dynamic>> _fetchBookingPayload(int bookingId) async {
    final client = await _client();
    final booking = _asMap(
      await client
          .from('bookings')
          .select()
          .eq('booking_id', bookingId)
          .single(),
    );
    final user = await _userById(_asInt(booking['user_id']));
    final meta = await _bookingMeta(bookingId);
    return _bookingPayload(booking, user, meta);
  }

  Map<String, dynamic> _bookingPayload(
    Map<String, dynamic> row,
    Map<String, dynamic>? user,
    Map<String, dynamic>? meta,
  ) {
    final statusRaw = _asString(row['status']).toLowerCase();
    final status = switch (statusRaw) {
      'confirmed' => 'checkedIn',
      'cancelled' => 'cancelled',
      _ => 'reserved',
    };
    final date = _asString(row['booking_date']);
    return <String, dynamic>{
      'bookingId': _asInt(row['booking_id']),
      'bookingCode':
          'BK-${_asInt(row['booking_id']).toString().padLeft(6, '0')}',
      'userId': _asInt(row['user_id']),
      'customerName': _asString(user?['full_name']),
      'email': _asString(user?['email']),
      'contactDetails': _asString(user?['email']).isNotEmpty
          ? _asString(user?['email'])
          : _asString(user?['contact_number']),
      'spaceType': _asString(meta?['space_type']).isEmpty
          ? 'Open Space'
          : _asString(meta?['space_type']),
      'customerType': _asString(meta?['customer_type']).isEmpty
          ? 'Guest'
          : _asString(meta?['customer_type']),
      'status': status,
      'rawStatus': _asString(row['status']),
      'startAt': '$date ${_asString(row['start_time'])}',
      'endAt': '$date ${_asString(row['end_time'])}',
      'createdAt': _asString(row['created_at']),
    };
  }

  Future<Map<String, dynamic>> _bookingMeta(int bookingId) async {
    final client = await _client();
    return _asMap(
      await client
          .from('booking_meta')
          .select()
          .eq('booking_id', bookingId)
          .maybeSingle(),
    );
  }

  Future<Map<int, Map<String, dynamic>>> _userByIdMap() async {
    return _byIntKey(await _tableRows('users'), 'user_id');
  }

  Future<Map<String, dynamic>> _userById(int userId) async {
    final client = await _client();
    return _asMap(
      await client.from('users').select().eq('user_id', userId).maybeSingle(),
    );
  }

  Future<Map<int, Map<String, dynamic>>> _sessionMetaByIdMap() async {
    return _byIntKey(await _tableRows('session_meta'), 'session_id');
  }

  Future<Map<int, Map<String, dynamic>>> _membershipByUserMap() async {
    final memberships = await _tableRows('memberships');
    final result = <int, Map<String, dynamic>>{};
    for (final row in memberships) {
      final userId = _asInt(row['user_id']);
      final current = result[userId];
      if (current == null ||
          _asInt(row['membership_id']) > _asInt(current['membership_id'])) {
        result[userId] = row;
      }
    }
    return result;
  }

  Future<int> _resolveOrCreateUser(
    String customerName,
    String contactDetails,
  ) async {
    final client = await _client();
    final email = contactDetails.contains('@')
        ? contactDetails.toLowerCase()
        : '';
    if (email.isNotEmpty) {
      final existing = await _findUserByEmail(email);
      if (existing.isNotEmpty) {
        return _asInt(existing['user_id']);
      }
    }
    final contact = email.isEmpty ? contactDetails : '';
    if (contact.isNotEmpty) {
      final existing = _asMap(
        await client
            .from('users')
            .select()
            .eq('contact_number', contact)
            .maybeSingle(),
      );
      if (existing.isNotEmpty) {
        return _asInt(existing['user_id']);
      }
    }
    final row = _asMap(
      await client
          .from('users')
          .insert(<String, dynamic>{
            'full_name': customerName,
            'contact_number': contact.isEmpty ? null : contact,
            'email': email.isEmpty ? null : email,
            'status': 'Inactive',
          })
          .select()
          .single(),
    );
    return _asInt(row['user_id']);
  }

  Future<int> _ensureActiveSession(int userId) async {
    final client = await _client();
    final active = await _activeSessionForUser(userId);
    if (active.isNotEmpty) {
      return _asInt(active['session_id']);
    }
    final row = _asMap(
      await client
          .from('sessions')
          .insert(<String, dynamic>{
            'user_id': userId,
            'check_in': DateTime.now().toIso8601String(),
            'check_out': null,
            'status': 'Active',
          })
          .select()
          .single(),
    );
    return _asInt(row['session_id']);
  }

  Future<Map<String, dynamic>> _activeSessionForUser(int userId) async {
    final client = await _client();
    return _asMap(
      await client
          .from('sessions')
          .select()
          .eq('user_id', userId)
          .eq('status', 'Active')
          .order('session_id', ascending: false)
          .limit(1)
          .maybeSingle(),
    );
  }

  Future<void> _appendUserHistory(int userId, String label) async {
    final client = await _client();
    final user = await _userById(userId);
    final profile = _asMap(
      await client
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle(),
    );
    final history = <String>[
      ..._decodeHistory(profile['history_json']),
      _historyLabel(label),
    ];
    final names = _splitName(_asString(user['full_name']));
    await client.from('user_profiles').upsert(<String, dynamic>{
      'user_id': userId,
      'first_name': _asString(profile['first_name']).isEmpty
          ? names.first
          : _asString(profile['first_name']),
      'last_name': _asString(profile['last_name']).isEmpty
          ? names.last
          : _asString(profile['last_name']),
      'user_type': _asString(profile['user_type']).isEmpty
          ? 'Student'
          : _asString(profile['user_type']),
      'membership_type': _asString(profile['membership_type']).isEmpty
          ? 'Open Time'
          : _asString(profile['membership_type']),
      'history_json': jsonEncode(history),
    }, onConflict: 'user_id');
  }

  Future<Map<String, dynamic>> _findUserByEmail(String email) async {
    final client = await _client();
    return _asMap(
      await client
          .from('users')
          .select()
          .eq('email', email.toLowerCase())
          .maybeSingle(),
    );
  }

  Future<Map<String, dynamic>> _fetchUserPayload(int userId) async {
    final user = await _userById(userId);
    if (user.isEmpty) {
      throw const AimsApiException('User not found.');
    }
    final client = await _client();
    final profile = _asMap(
      await client
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle(),
    );
    return _userPayload(user, profile);
  }

  Map<String, dynamic> _userPayload(
    Map<String, dynamic> user,
    Map<String, dynamic>? profile,
  ) {
    final names = _splitName(_asString(user['full_name']));
    final userId = _asInt(user['user_id']);
    return <String, dynamic>{
      'userId': userId,
      'userCode': 'USR-${userId.toString().padLeft(4, '0')}',
      'firstName': _asString(profile?['first_name']).isEmpty
          ? names.first
          : _asString(profile?['first_name']),
      'lastName': _asString(profile?['last_name']).isEmpty
          ? names.last
          : _asString(profile?['last_name']),
      'email': _asString(user['email']),
      'phoneNumber': _asString(user['contact_number']),
      'userType': _asString(profile?['user_type']).isEmpty
          ? 'Student'
          : _asString(profile?['user_type']),
      'membershipType': _asString(profile?['membership_type']).isEmpty
          ? 'Open Time'
          : _asString(profile?['membership_type']),
      'isActive': _asString(user['status']).toLowerCase() == 'active',
      'history': _decodeHistory(profile?['history_json']),
      'createdAt': _asString(user['created_at']),
    };
  }

  Future<void> _upsertMembership(int userId, String membershipType) async {
    final client = await _client();
    final existing = _asMap(
      await client
          .from('memberships')
          .select()
          .eq('user_id', userId)
          .order('membership_id', ascending: false)
          .limit(1)
          .maybeSingle(),
    );
    if (existing.isNotEmpty) {
      await client
          .from('memberships')
          .update(<String, dynamic>{'membership_type': membershipType})
          .eq('membership_id', _asInt(existing['membership_id']));
      return;
    }
    await client.from('memberships').insert(<String, dynamic>{
      'user_id': userId,
      'membership_type': membershipType,
      'discount_rate': null,
      'start_date': null,
      'end_date': null,
    });
  }

  Map<String, dynamic> _staffPayload(Map<String, dynamic> row) {
    return <String, dynamic>{
      'staffId': _asInt(row['staff_id']),
      'employeeId': _asString(row['employee_id']),
      'fullName': _asString(row['full_name']),
      'email': _asString(row['email']),
      'role': _normalizeStaffRole(_asString(row['role'])),
      'status': _normalizeStaffStatus(_asString(row['status'])),
      'createdAt': _asString(row['created_at']),
    };
  }

  Future<String> _generateNextEmployeeId(String role) async {
    final prefix = switch (role.toLowerCase()) {
      'admin' => 'ADMIN',
      'manager' => 'MGR',
      _ => 'STF',
    };
    final rows = await _tableRows('staff_accounts');
    var highest = 0;
    for (final row in rows) {
      final employeeId = _asString(row['employee_id']).toUpperCase();
      final match = RegExp('^$prefix-(\\d+)\$').firstMatch(employeeId);
      if (match == null) {
        continue;
      }
      final value = int.tryParse(match.group(1) ?? '') ?? 0;
      if (value > highest) {
        highest = value;
      }
    }
    return '$prefix-${(highest + 1).toString().padLeft(3, '0')}';
  }

  Future<Map<String, dynamic>> _spacePricingPayload() async {
    final client = await _client();
    final row = _asMap(
      await client
          .from('space_pricing')
          .select()
          .eq('pricing_id', 1)
          .maybeSingle(),
    );
    return <String, dynamic>{
      'boardRoomHourlyRate': _asDouble(row['board_room_hourly_rate']),
      'ordinarySpaceHourlyRate': _asDouble(row['ordinary_space_hourly_rate']),
    };
  }

  Future<List<Map<String, dynamic>>> _loyaltyPayloads() async {
    final users = await _userByIdMap();
    final sessions = await _tableRows('sessions');
    final counts = <int, int>{};
    for (final session in sessions) {
      final userId = _asInt(session['user_id']);
      counts[userId] = (counts[userId] ?? 0) + 1;
    }
    final rows =
        counts.entries.map((entry) {
          final user = users[entry.key] ?? const <String, dynamic>{};
          return <String, dynamic>{
            'memberName': _asString(user['full_name']),
            'entries': entry.value,
            'freeHours': entry.value ~/ 5,
          };
        }).toList()..sort(
          (a, b) => _asInt(b['entries']).compareTo(_asInt(a['entries'])),
        );
    return rows.take(20).toList();
  }

  Map<String, dynamic> _membershipPayload(Map<String, dynamic> row) {
    return <String, dynamic>{
      'membershipTypeId': _asInt(row['membership_type_id']),
      'type': _asString(row['plan_name']),
      'duration': _asString(row['duration_label']),
      'price': _asString(row['price_label']),
      'benefits': _asString(row['benefits']),
    };
  }

  Map<String, dynamic> _promotionPayload(Map<String, dynamic> row) {
    var discount = _asString(row['discount_label']);
    if (discount.isEmpty) {
      final rate = _asDouble(row['discount_rate']);
      discount = rate > 0 ? rate.toStringAsFixed(2) : '';
    }
    return <String, dynamic>{
      'promoId': _asInt(row['promo_id']),
      'name': _asString(row['promo_name']),
      'type': _asString(row['promo_type']),
      'discount': discount,
      'expiry': _asString(row['end_date']),
    };
  }

  double? _parseDiscountRate(String label) {
    final cleaned = label.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) {
      return null;
    }
    final value = double.tryParse(cleaned);
    return value == null || value <= 0 ? null : value;
  }

  Future<List<Map<String, dynamic>>> _salesPoints(String range) async {
    final points = <Map<String, dynamic>>[];
    final today = _today();
    if (range == 'daily') {
      for (final hour in <int>[6, 8, 10, 12, 14, 16, 18]) {
        final start = DateTime(today.year, today.month, today.day, hour);
        final end = start.add(const Duration(hours: 2));
        final summary = await _salesSummary(start, end);
        points.add(<String, dynamic>{
          'label': _formatHourLabel(hour),
          'title': '${_formatHourLabel(hour)} Today',
          ...summary,
        });
      }
      return points;
    }
    if (range == 'weekly') {
      for (var i = 6; i >= 0; i--) {
        final day = today.subtract(Duration(days: i));
        final summary = await _salesSummary(
          day,
          day.add(const Duration(days: 1)),
        );
        points.add(<String, dynamic>{
          'label': _weekdayShort(day.weekday),
          'title':
              '${_weekdayShort(day.weekday)}, ${_monthShort(day.month)} ${day.day} ${day.year}',
          ...summary,
        });
      }
      return points;
    }
    if (range == 'monthly') {
      final currentMonth = DateTime(today.year, today.month);
      for (var i = 11; i >= 0; i--) {
        final start = DateTime(currentMonth.year, currentMonth.month - i);
        final end = DateTime(start.year, start.month + 1);
        final summary = await _salesSummary(start, end);
        points.add(<String, dynamic>{
          'label': _monthShort(start.month),
          'title': '${_monthName(start.month)} ${start.year}',
          ...summary,
        });
      }
      return points;
    }
    final currentYear = DateTime(today.year);
    for (var i = 5; i >= 0; i--) {
      final start = DateTime(currentYear.year - i);
      final end = DateTime(start.year + 1);
      final summary = await _salesSummary(start, end);
      points.add(<String, dynamic>{
        'label': start.year.toString(),
        'title': 'Year ${start.year}',
        ...summary,
      });
    }
    return points;
  }

  Future<Map<String, dynamic>> _salesSummary(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _transactionsBetween(start, end);
    return <String, dynamic>{
      'revenue': rows.fold<double>(
        0,
        (sum, row) => sum + _asDouble(row['final_amount']),
      ),
      'transactions': rows.length,
    };
  }

  Future<List<Map<String, dynamic>>> _transactionsBetween(
    DateTime start,
    DateTime end,
  ) async {
    final client = await _client();
    return _rows(
      await client
          .from('transactions')
          .select()
          .gte('created_at', start.toIso8601String())
          .lt('created_at', end.toIso8601String()),
    );
  }

  Future<List<Map<String, dynamic>>> _sessionsBetween(
    DateTime start,
    DateTime end,
  ) async {
    final client = await _client();
    return _rows(
      await client
          .from('sessions')
          .select()
          .gte('check_in', start.toIso8601String())
          .lt('check_in', end.toIso8601String()),
    );
  }

  Future<List<Map<String, dynamic>>> _schedulePayloads(
    List<Map<String, dynamic>> rows,
  ) async {
    final staff = _byIntKey(await _tableRows('staff_accounts'), 'staff_id');
    return rows.map((row) => _schedulePayloadSync(row, staff)).toList();
  }

  Future<Map<String, dynamic>> _schedulePayload(
    Map<String, dynamic> row,
  ) async {
    final staff = _byIntKey(await _tableRows('staff_accounts'), 'staff_id');
    return _schedulePayloadSync(row, staff);
  }

  Map<String, dynamic> _schedulePayloadSync(
    Map<String, dynamic> row,
    Map<int, Map<String, dynamic>> staff,
  ) {
    final creator = staff[_asInt(row['created_by_staff_id'])];
    return <String, dynamic>{
      'scheduleId': _asInt(row['schedule_id']),
      'title': _asString(row['title']),
      'notes': _asString(row['notes']),
      'startAt': _asString(row['start_at']),
      'endAt': _asString(row['end_at']),
      'createdAt': _asString(row['created_at']),
      'updatedAt': _asString(row['updated_at']),
      'createdByStaffId': _asInt(row['created_by_staff_id']),
      'createdByEmployeeId': _asString(creator?['employee_id']),
      'createdByName': _asString(creator?['full_name']),
    };
  }

  int get _currentStaffId => _asInt(AppSession.user?['staff_id']);

  String _requiredString(Map<String, dynamic> body, String field) {
    final value = _asString(body[field]);
    if (value.isEmpty) {
      throw AimsApiException('Missing required field: $field.');
    }
    return value;
  }

  int _clampInt(int value, int min, int max) {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }

  String _normalizeLoginRole(String value) {
    final normalized = value.trim().toLowerCase();
    if (['admin', 'manager', 'staff'].contains(normalized)) {
      return normalized;
    }
    throw const AimsApiException('Role must be admin, manager, or staff.');
  }

  String _normalizeStaffRole(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'admin') {
      return 'Admin';
    }
    if (normalized == 'manager') {
      return 'Manager';
    }
    if (normalized == 'staff') {
      return 'Staff';
    }
    throw const AimsApiException('Role must be Admin, Manager, or Staff.');
  }

  String _normalizeStaffStatus(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty ||
        normalized == 'active' ||
        normalized == 'on duty') {
      return 'Active';
    }
    if (normalized == 'inactive' || normalized == 'off duty') {
      return 'Inactive';
    }
    throw const AimsApiException('Status must be Active or Inactive.');
  }

  String _normalizeUserType(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'student') {
      return 'Student';
    }
    if (normalized == 'professional') {
      return 'Professional';
    }
    throw const AimsApiException('userType must be Student or Professional.');
  }

  String _normalizeMembershipType(String value) {
    final allowed = <String>[
      'Annual',
      'Loyalty Rewards',
      'Monthly Membership',
      'Open Time',
    ];
    for (final item in allowed) {
      if (value.trim().toLowerCase() == item.toLowerCase()) {
        return item;
      }
    }
    return 'Open Time';
  }

  String _bookingStatusFromFilter(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'reserved' || normalized == 'pending') {
      return 'Pending';
    }
    if (normalized == 'checkedin' ||
        normalized == 'checked-in' ||
        normalized == 'confirmed') {
      return 'Confirmed';
    }
    if (normalized == 'cancelled' || normalized == 'canceled') {
      return 'Cancelled';
    }
    throw const AimsApiException('Invalid status filter.');
  }

  String _spaceLabel(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'board room' || normalized == 'boardroom') {
      return 'Board Room';
    }
    if (normalized == 'open space' ||
        normalized == 'ordinary space' ||
        normalized == 'open') {
      return 'Open Space';
    }
    throw const AimsApiException(
      'Space type must be Board Room or Open Space.',
    );
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String _dateSql(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  String _timeSql(DateTime value) {
    return '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}:'
        '${value.second.toString().padLeft(2, '0')}';
  }

  ({String first, String last}) _splitName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return (first: 'User', last: '');
    }
    return (
      first: parts.first,
      last: parts.length > 1 ? parts.sublist(1).join(' ') : '',
    );
  }

  List<String> _decodeHistory(dynamic value) {
    if (value is List) {
      return value.map(_asString).toList();
    }
    final raw = _asString(value);
    if (raw.isEmpty) {
      return <String>[];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map(_asString).toList();
      }
    } catch (_) {
      return <String>[];
    }
    return <String>[];
  }

  String _historyLabel(String label) {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$label on ${_dateSql(now)} $hour:$minute $period';
  }

  String _formatHourLabel(int hour) {
    if (hour == 0) {
      return '12AM';
    }
    if (hour < 12) {
      return '${hour}AM';
    }
    if (hour == 12) {
      return '12PM';
    }
    return '${hour - 12}PM';
  }

  String _monthShort(int month) {
    return const <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][month - 1];
  }

  String _monthName(int month) {
    return const <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ][month - 1];
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
