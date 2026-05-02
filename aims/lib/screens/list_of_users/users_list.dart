import 'package:aims/widgets/common/custom_button.dart';
import 'package:aims/widgets/common/custom_text_field.dart';
import 'package:aims/widgets/common/header.dart';
import 'package:aims/widgets/common/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:aims/services/aims_api_client.dart';
import 'package:aims/screens/list_of_users/user_form.dart';
import 'package:aims/screens/list_of_users/checkIn.dart';
import 'package:aims/screens/list_of_users/checkOut.dart';
import 'package:aims/screens/list_of_users/payment.dart';
import 'package:aims/screens/list_of_users/payment_success.dart';
import 'package:aims/widgets/utils/space_pricing.dart';
import 'package:aims/screens/list_of_users/receipt.dart';

class StaffUsersListScreen extends StatefulWidget {
  const StaffUsersListScreen({super.key, this.role = UserRole.staff});

  final UserRole role;

  @override
  State<StaffUsersListScreen> createState() => _StaffUsersListScreenState();
}

class _StaffUser {
  const _StaffUser({
    required this.backendId,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    required this.membershipType,
    required this.isActive,
    required this.history,
  });

  final int backendId;
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String userType;
  final String membershipType;
  final bool isActive;
  final List<String> history;

  String get fullName => '$firstName $lastName';
  String get statusLabel => isActive ? 'Active' : 'Inactive';

  String get lastVisit {
    if (history.isEmpty) return 'No Visits yet';

    final lastAction = history.lastWhere(
      (entry) => entry.contains('checked in') || entry.contains('checked out'),
      orElse: () => history.last,
    );

    if (lastAction.contains(' on ')) {
      return lastAction.split(' on ').last;
    }
    return lastAction;
  }

  _StaffUser copyWith({
    int? backendId,
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? userType,
    String? membershipType,
    bool? isActive,
    List<String>? history,
  }) {
    return _StaffUser(
      backendId: backendId ?? this.backendId,
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      membershipType: membershipType ?? this.membershipType,
      isActive: isActive ?? this.isActive,
      history: history ?? this.history,
    );
  }
}

class UserFormData {
  const UserFormData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    required this.membershipType,
    required this.isActive,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String userType;
  final String membershipType;
  final bool isActive;
}

class _ActiveVisit {
  const _ActiveVisit({required this.spaceUsed, required this.timeIn});

  final String spaceUsed;
  final DateTime timeIn;
}

class _StaffUsersListScreenState extends State<StaffUsersListScreen> {
  static const double _desktopFrameWidth = 1560;
  static const Color _pageBackground = Color(0xFFDDECEF);
  static const Color _panelBlue = Color(0xFFCDECF3);
  static const Color _headerBlue = Color(0xFF80AEC1);
  static const Color _tanSoft = Color(0xFFEBD9CA);
  static const Color _cardWhite = Color(0xF7FFFFFF);
  static const Color _darkText = Color(0xFF23323A);
  static const Color _mutedText = Color(0xFF6F7E87);
  static const Color _successColor = Color(0xFF2E8B57);
  static const Color _dangerColor = Color(0xFFC95656);
  static const List<String> _filterOptions = [
    'Last Name',
    'First Name',
    'User ID',
    'Membership Type',
    'User Type',
  ];
  static const List<String> _membershipOptions = [
    'All',
    'Annual',
    'Loyalty Rewards',
    'Monthly Membership',
    'Open Time',
  ];
  static const List<String> _userTypeOptions = [
    'All',
    'Student',
    'Professional',
  ];

  final TextEditingController _searchController = TextEditingController();
  final Map<String, _ActiveVisit> _activeVisits = {};

  bool isSidebarOpen = true;
  String selectedMenu = 'List of Users';
  String _selectedFilter = 'Last Name';
  String _selectedDropdownValue = 'All';
  bool _isLoadingUsers = false;
  List<_StaffUser> _users = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refresh);
    _syncSpacePricing();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  _ActiveVisit _defaultActiveVisitFor(_StaffUser user) {
    return _ActiveVisit(
      spaceUsed: user.membershipType == 'Annual'
          ? 'Board Room'
          : 'Ordinary Space',
      timeIn: DateTime.now().subtract(const Duration(hours: 3)),
    );
  }

  _ActiveVisit _activeVisitFor(_StaffUser user) {
    return _activeVisits[user.id] ?? _defaultActiveVisitFor(user);
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final records = await AimsApiClient.instance.fetchUsers();
      final users = records.map(_fromUserRecord).toList();

      if (!mounted) return;
      setState(() {
        _users = users;
        _activeVisits
          ..clear()
          ..addEntries(
            users
                .where((user) => user.isActive)
                .map((user) => MapEntry(user.id, _defaultActiveVisitFor(user))),
          );
      });
    } on AimsApiException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Unable to load users from backend right now.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUsers = false;
        });
      }
    }
  }

  Future<void> _syncSpacePricing({bool notifyOnError = false}) async {
    try {
      await SpacePricingStore.syncFromBackend();
    } on AimsApiException catch (error) {
      if (notifyOnError) {
        _showMessage(error.message);
      }
    } catch (_) {
      if (notifyOnError) {
        _showMessage('Unable to load hourly pricing from backend.');
      }
    }
  }

  _StaffUser _fromUserRecord(UserRecord record) {
    return _StaffUser(
      backendId: record.userId,
      id: record.userCode,
      firstName: record.firstName,
      lastName: record.lastName,
      email: record.email,
      phoneNumber: record.phoneNumber,
      userType: record.userType,
      membershipType: record.membershipType,
      isActive: record.isActive,
      history: record.history,
    );
  }

  String _suggestNextUserCode() {
    var maxCode = 0;
    for (final user in _users) {
      final value =
          int.tryParse(user.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (value > maxCode) {
        maxCode = value;
      }
    }
    final nextCode = maxCode + 1;
    return 'USR-${nextCode.toString().padLeft(4, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _filteredUsers();
    final activeUsers = filteredUsers.where((user) => user.isActive).toList();
    final inactiveUsers = filteredUsers
        .where((user) => !user.isActive)
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _pageBackground,
        body: SafeArea(
          child: Column(
            children: [
              Header(
                role: widget.role,
                onMenuTap: () {
                  setState(() {
                    isSidebarOpen = !isSidebarOpen;
                  });
                },
                maxWidth: _desktopFrameWidth,
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _desktopFrameWidth,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isSidebarOpen)
                          Sidebar(
                            role: widget.role,
                            selectedTitle: selectedMenu,
                            onItemSelected: _handleSidebarTap,
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),
                                    _buildPageHero(context),
                                    const SizedBox(height: 18),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: [
                                        _buildInfoChip(
                                          label: 'Total Users',
                                          value: '${_users.length}',
                                        ),
                                        _buildInfoChip(
                                          label: 'Active Users',
                                          value:
                                              '${_users.where((user) => user.isActive).length}',
                                        ),
                                        _buildInfoChip(
                                          label: 'Filtered Results',
                                          value: '${filteredUsers.length}',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    _buildSearchSection(filteredUsers.length),
                                    if (_isLoadingUsers)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 12),
                                        child: LinearProgressIndicator(
                                          minHeight: 3,
                                        ),
                                      ),
                                    const SizedBox(height: 18),
                                    Expanded(
                                      child: _buildUserDirectorySection(
                                        filteredUsers: filteredUsers,
                                        activeUsers: activeUsers,
                                        inactiveUsers: inactiveUsers,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSidebarTap(String title) {
    if (title == 'Calendar') {
      Navigator.pushReplacementNamed(
        context,
        widget.role == UserRole.manager ? '/manager-calendar' : '/calendar',
      );
      return;
    }

    if (title == 'List of Users') {
      setState(() {
        selectedMenu = title;
      });
      return;
    }

    if (title == 'Pricing and Promo Management') {
      Navigator.pushReplacementNamed(
        context,
        widget.role == UserRole.manager
            ? '/manager-membership'
            : '/membership-loyalty-program',
      );
      return;
    }

    Navigator.pushNamed(
      context,
      widget.role == UserRole.manager
          ? '/manager-dashboard'
          : '/staff-dashboard',
    );
  }

  Widget _buildPageHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final titleBlock = Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _panelBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.groups_outlined,
                  color: _headerBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Management',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: _darkText,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Add users, review visits, and manage check-in or checkout activity.',
                      style: TextStyle(
                        fontSize: 14,
                        color: _mutedText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                titleBlock,
                const SizedBox(height: 14),
                _buildAddUserButton(context, fullWidth: true),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: titleBlock),
              const SizedBox(width: 16),
              _buildAddUserButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddUserButton(BuildContext context, {bool fullWidth = false}) {
    return SizedBox(
      width: fullWidth ? double.infinity : 190,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () async {
          await _openAddUserForm(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _tanSoft,
          foregroundColor: _darkText,
          elevation: 0,
          side: const BorderSide(color: Color(0x2A23323A)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
        label: const Text('Add User'),
      ),
    );
  }

  Widget _buildInfoChip({required String label, required String value}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _headerBlue,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(int resultCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Search Users',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _darkText,
                  ),
                ),
              ),
              Text(
                '$resultCount found',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 760;
              final filterWidth = isCompact ? double.infinity : 220.0;
              final inputWidth = isCompact
                  ? double.infinity
                  : constraints.maxWidth - 220 - 12;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: filterWidth,
                    child: _buildDropdown(
                      value: _selectedFilter,
                      label: 'Filter By',
                      items: _filterOptions,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedFilter = value;
                          _searchController.clear();
                          _selectedDropdownValue = 'All';
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: inputWidth < 180 ? double.infinity : inputWidth,
                    child: _buildSelectedFilterInput(),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _selectedFilter = 'Last Name';
                    _selectedDropdownValue = 'All';
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _darkText,
                  side: const BorderSide(color: Color(0x2A23323A)),
                  backgroundColor: Colors.white.withValues(alpha: 0.64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                ),
                icon: const Icon(Icons.clear_rounded, size: 18),
                label: const Text(
                  'Clear',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFilterInput() {
    if (_selectedFilter == 'Membership Type') {
      return _buildDropdown(
        value: _selectedDropdownValue,
        label: 'Membership Type',
        items: _membershipOptions,
        onChanged: (value) {
          if (value == null) return;
          setState(() => _selectedDropdownValue = value);
        },
      );
    }

    if (_selectedFilter == 'User Type') {
      return _buildDropdown(
        value: _selectedDropdownValue,
        label: 'User Type',
        items: _userTypeOptions,
        onChanged: (value) {
          if (value == null) return;
          setState(() => _selectedDropdownValue = value);
        },
      );
    }

    return CustomTextField(
      hint: 'Search ${_selectedFilter.toLowerCase()}',
      controller: _searchController,
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.76),
        labelStyle: const TextStyle(
          color: _mutedText,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.85)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.85)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _headerBlue),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(),
    );
  }

  Widget _buildUserDirectorySection({
    required List<_StaffUser> filteredUsers,
    required List<_StaffUser> activeUsers,
    required List<_StaffUser> inactiveUsers,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panelBlue,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 28,
                decoration: BoxDecoration(
                  color: _headerBlue,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Directory',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _darkText,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Review membership details, activity state, and visit history.',
                      style: TextStyle(fontSize: 12, color: _mutedText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _tanSoft,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0x2A23323A)),
                      ),
                      child: const TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        labelColor: _darkText,
                        unselectedLabelColor: _mutedText,
                        dividerColor: Colors.transparent,
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                        tabs: [
                          Tab(text: 'All Users'),
                          Tab(text: 'Active Users'),
                          Tab(text: 'Inactive Users'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildUserList(filteredUsers, 'No users found.'),
                        _buildUserList(activeUsers, 'No active users found.'),
                        _buildUserList(
                          inactiveUsers,
                          'No inactive users found.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<_StaffUser> users, String emptyMessage) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(fontSize: 16, color: _mutedText),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = users[index];

        return Dismissible(
          key: ValueKey(user.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDeleteUser(context, user),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: _dangerColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          child: InkWell(
            onTap: () => _openEditUserForm(context, user),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _darkText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${user.id} - ${user.email}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: _mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Active users can check out; inactive users can check in.
                      user.isActive
                          ? ElevatedButton.icon(
                              onPressed: () async {
                                await _syncSpacePricing();
                                if (!context.mounted) return;
                                final visit = _activeVisitFor(user);
                                final totalAmount =
                                    SpacePricingStore.totalForVisit(
                                      spaceUsed: visit.spaceUsed,
                                      timeIn: visit.timeIn,
                                    );

                                showDialog(
                                  context: context,
                                  builder: (_) => CheckOut(
                                    bookingId: 'BK-${user.id}',
                                    customerName: user.fullName,
                                    spaceUsed: visit.spaceUsed,
                                    timeIn: visit.timeIn,
                                    totalAmount: totalAmount,
                                    onConfirm: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => PaymentDialog(
                                          totalAmount: totalAmount,
                                          onConfirm: () {
                                            _completeCheckout(
                                              user: user,
                                              visit: visit,
                                              totalAmount: totalAmount,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text("Check-out"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _dangerColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            )
                          // Inactive users can check back in.
                          : ElevatedButton.icon(
                              onPressed: () async {
                                final result = await showDialog<CheckInData>(
                                  context: context,
                                  builder: (_) => CheckIn(
                                    userId: user.id,
                                    firstName: user.firstName,
                                    lastName: user.lastName,
                                    email: user.email,
                                    phoneNumber: user.phoneNumber,
                                    userType: user.userType,
                                    membershipType: user.membershipType,
                                    timeIn: DateTime.now(),
                                    lastVisit: user.lastVisit,
                                    onConfirm: () {},

                                    onEditUser: () {
                                      _openEditUserForm(context, user);
                                    },

                                    onViewHistory: () {
                                      Navigator.pop(context);
                                      _openHistoryScreen(context, user);
                                    },
                                  ),
                                );

                                if (result == null) {
                                  return;
                                }

                                try {
                                  await AimsApiClient.instance.checkInUser(
                                    userEmail: user.email,
                                    spaceUsed: result.spaceUsed,
                                    checkInAt: result.timeIn,
                                  );
                                } on AimsApiException catch (error) {
                                  _showMessage(error.message);
                                  return;
                                } catch (_) {
                                  _showMessage(
                                    'Unable to check in right now. Please try again.',
                                  );
                                  return;
                                }

                                if (!mounted) return;
                                setState(() {
                                  final index = _users.indexWhere(
                                    (u) => u.backendId == user.backendId,
                                  );
                                  if (index != -1) {
                                    _users[index] = user.copyWith(
                                      isActive: true,
                                      history: [
                                        ...user.history,
                                        _historyLabel("User checked in"),
                                      ],
                                    );
                                    _activeVisits[user.id] = _ActiveVisit(
                                      spaceUsed: result.spaceUsed,
                                      timeIn: result.timeIn,
                                    );
                                  }
                                });
                                _showMessage(
                                  "${user.fullName} checked in sucessfully",
                                );
                              },
                              icon: const Icon(Icons.login),
                              label: const Text("Check-In"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _headerBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),

                      const SizedBox(width: 14),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: user.isActive
                              ? _successColor.withValues(alpha: 0.12)
                              : _dangerColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          user.statusLabel,
                          style: TextStyle(
                            color: user.isActive ? _successColor : _dangerColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _infoChip('User Type: ${user.userType}'),
                      _infoChip('Membership: ${user.membershipType}'),
                      _infoChip('Phone: ${user.phoneNumber}'),

                      _infoChip('Last Visit: ${user.lastVisit}'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _openHistoryScreen(context, user),
                        icon: const Icon(Icons.history_rounded),
                        label: const Text('User History'),
                        style: _userActionButtonStyle(),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _openEditUserForm(context, user),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit User'),
                        style: _userActionButtonStyle(),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await _confirmDeleteUser(context, user);
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete User'),
                        style: _userActionButtonStyle(color: _dangerColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _tanSoft.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _darkText,
        ),
      ),
    );
  }

  ButtonStyle _userActionButtonStyle({Color color = _headerBlue}) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(
        color: color == _dangerColor
            ? const Color(0xFFF3C7C7)
            : Colors.white.withValues(alpha: 0.95),
      ),
      backgroundColor: color == _dangerColor
          ? const Color(0xFFFBEAEA)
          : Colors.white.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    );
  }

  List<_StaffUser> _filteredUsers() {
    final searchValue = _searchController.text.trim().toLowerCase();

    return _users.where((user) {
      switch (_selectedFilter) {
        case 'Last Name':
          return searchValue.isEmpty ||
              user.lastName.toLowerCase().contains(searchValue);
        case 'First Name':
          return searchValue.isEmpty ||
              user.firstName.toLowerCase().contains(searchValue);
        case 'User ID':
          return searchValue.isEmpty ||
              user.id.toLowerCase().contains(searchValue);
        case 'Membership Type':
          return _selectedDropdownValue == 'All' ||
              user.membershipType == _selectedDropdownValue;
        case 'User Type':
          return _selectedDropdownValue == 'All' ||
              user.userType == _selectedDropdownValue;
        default:
          return true;
      }
    }).toList();
  }

  Future<void> _openAddUserForm(BuildContext context) async {
    final generatedId = _suggestNextUserCode();

    final result = await Navigator.of(context).push<UserFormData>(
      MaterialPageRoute(builder: (_) => AddUser(userId: generatedId)),
    );

    if (result == null) return;
    try {
      final created = await AimsApiClient.instance.createUser(
        firstName: result.firstName,
        lastName: result.lastName,
        email: result.email,
        phoneNumber: result.phoneNumber,
        userType: result.userType,
        membershipType: result.membershipType,
        isActive: false,
      );
      final newUser = _fromUserRecord(created);
      if (!mounted) return;
      setState(() {
        _users.insert(0, newUser);
      });
      _showMessage('${newUser.fullName} added to All Users.');
    } on AimsApiException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Unable to add user right now. Please try again.');
    }
  }

  Future<void> _openEditUserForm(BuildContext context, _StaffUser user) async {
    final result = await Navigator.of(context).push<UserFormData>(
      MaterialPageRoute(builder: (_) => _UserFormScreen(user: user)),
    );

    if (result == null) return;
    try {
      final updated = await AimsApiClient.instance.updateUser(
        userId: user.backendId,
        firstName: result.firstName,
        lastName: result.lastName,
        email: result.email,
        phoneNumber: result.phoneNumber,
        userType: result.userType,
        membershipType: result.membershipType,
        isActive: result.isActive,
      );
      final updatedUser = _fromUserRecord(updated);
      if (!mounted) return;
      setState(() {
        final index = _users.indexWhere(
          (item) => item.backendId == user.backendId,
        );
        if (index == -1) return;
        _users[index] = updatedUser;
      });
      _showMessage('${updatedUser.id} updated successfully.');
    } on AimsApiException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Unable to update user right now. Please try again.');
    }
  }

  Future<bool> _confirmDeleteUser(BuildContext context, _StaffUser user) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Delete user?'),
              content: Text(
                'Are you sure you want to delete ${user.fullName}?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: _dangerColor),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete) {
      return false;
    }
    try {
      await AimsApiClient.instance.deleteUser(user.backendId);
      if (!mounted) return false;
      setState(() {
        _users.removeWhere((item) => item.backendId == user.backendId);
        _activeVisits.remove(user.id);
      });
      _showMessage('${user.fullName} deleted.');
      return true;
    } on AimsApiException catch (error) {
      _showMessage(error.message);
      return false;
    } catch (_) {
      _showMessage('Unable to delete user right now. Please try again.');
      return false;
    }
  }

  void _openHistoryScreen(BuildContext context, _StaffUser user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _UserHistoryScreen(userName: user.fullName, history: user.history),
      ),
    );
  }

  String _historyLabel(String label) {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final suffix = now.hour >= 12 ? 'PM' : 'AM';
    return '$label on ${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')} $hour:$minute $suffix';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _completeCheckout({
    required _StaffUser user,
    required _ActiveVisit visit,
    required double totalAmount,
  }) async {
    try {
      await AimsApiClient.instance.checkOutUser(
        userEmail: user.email,
        amount: totalAmount,
        paymentMethod: 'cash',
        paymentStatus: 'paid',
      );
    } on AimsApiException catch (error) {
      _showMessage(error.message);
      return;
    } catch (_) {
      _showMessage('Unable to check out right now. Please try again.');
      return;
    }

    if (!mounted) return;
    setState(() {
      final index = _users.indexWhere((u) => u.backendId == user.backendId);
      if (index != -1) {
        _users[index] = user.copyWith(
          isActive: false,
          history: [...user.history, _historyLabel("User checked out & paid")],
        );
        _activeVisits.remove(user.id);
      }
    });

    showDialog(
      context: context,
      builder: (_) => PaymentSuccessDialog(
        onGenerateReceipt: () {
          showDialog(
            context: context,
            builder: (_) => ReceiptDialog(
              bookingId: 'BK-${user.id}',
              customerName: user.fullName,
              spaceUsed: visit.spaceUsed,
              totalAmount: totalAmount,
            ),
          );
        },
      ),
    );
  }
}

class _UserFormScreen extends StatefulWidget {
  const _UserFormScreen({this.user});

  final _StaffUser? user;

  bool get isEdit => user != null;

  @override
  State<_UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<_UserFormScreen> {
  static const Color _pageBackground = Color(0xFFDDECEF);
  static const Color _headerBlue = Color(0xFF80AEC1);
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF6F7E87);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _lastNameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneNumberController;
  String _selectedUserType = 'Student';
  String _selectedMembershipType = 'Annual';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneNumberController = TextEditingController(
      text: user?.phoneNumber ?? '',
    );
    _selectedUserType = user?.userType ?? 'Student';
    _selectedMembershipType = user?.membershipType ?? 'Annual';
    _isActive = user?.isActive ?? true;
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit User' : 'Add User'),
        backgroundColor: _headerBlue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: _pageBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xF7FFFFFF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isEdit
                          ? 'Update the selected user information.'
                          : 'Enter the new staff-accessible user details.',
                      style: const TextStyle(
                        color: _textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      hint: 'Last Name',
                      controller: _lastNameController,
                      validator: _requiredField,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      hint: 'First Name',
                      controller: _firstNameController,
                      validator: _requiredField,
                    ),
                    const SizedBox(height: 14),

                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            hint: 'Email',
                            controller: _emailController,
                            validator: _emailValidator,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedUserType,
                            decoration: _inputDecoration('User Type'),
                            items: const [
                              DropdownMenuItem(
                                value: 'Student',
                                child: Text('Student'),
                              ),
                              DropdownMenuItem(
                                value: 'Professional',
                                child: Text('Professional'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _selectedUserType = value);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    CustomTextField(
                      hint: 'Phone Number',
                      controller: _phoneNumberController,
                      validator: _requiredField,
                    ),

                    const SizedBox(height: 14),

                    Center(
                      child: SizedBox(
                        width: 300,

                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedMembershipType,
                          decoration: _inputDecoration('Membership Type'),
                          items: const [
                            DropdownMenuItem(
                              value: 'Annual',
                              child: Text('Annual'),
                            ),
                            DropdownMenuItem(
                              value: 'Loyalty Rewards',
                              child: Text('Loyalty Rewards'),
                            ),
                            DropdownMenuItem(
                              value: 'Monthly Membership',
                              child: Text('Monthly Membership'),
                            ),
                            DropdownMenuItem(
                              value: 'Open Time',
                              child: Text('Open Time'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _selectedMembershipType = value);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            label: 'Cancel',
                            backgroundColor: Colors.white,
                            textColor: _textPrimary,
                            borderColor: const Color(0xFFB7C4CB),
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            label: widget.isEdit
                                ? 'Save Changes'
                                : 'Create User',
                            backgroundColor: _textPrimary,
                            borderColor: _textPrimary,
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;
                              Navigator.pop(
                                context,
                                UserFormData(
                                  firstName: _firstNameController.text.trim(),
                                  lastName: _lastNameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  phoneNumber: _phoneNumberController.text
                                      .trim(),
                                  userType: _selectedUserType,
                                  membershipType: _selectedMembershipType,
                                  isActive: _isActive,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.78),
      labelStyle: const TextStyle(
        color: _textMuted,
        fontWeight: FontWeight.w600,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.85)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.85)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _headerBlue),
      ),
    );
  }

  String? _requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@')) {
      return 'Enter a valid email';
    }
    return null;
  }
}

class _UserHistoryScreen extends StatelessWidget {
  const _UserHistoryScreen({required this.userName, required this.history});

  static const Color _pageBackground = Color(0xFFDDECEF);
  static const Color _panelBlue = Color(0xFFCDECF3);
  static const Color _headerBlue = Color(0xFF80AEC1);
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF6F7E87);

  final String userName;
  final List<String> history;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$userName History'),
        backgroundColor: _headerBlue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: _pageBackground,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _panelBlue,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          ),
          child: history.isEmpty
              ? const Center(
                  child: Text(
                    'No history available for this user.',
                    style: TextStyle(color: _textMuted),
                  ),
                )
              : ListView.separated(
                  itemCount: history.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 18),
                  itemBuilder: (context, index) {
                    final entry = history[history.length - index - 1];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFEBD9CA),
                        child: Icon(
                          Icons.history_toggle_off_rounded,
                          color: _textPrimary,
                        ),
                      ),
                      title: Text(entry),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
