import 'dart:math' as math;

import 'package:aims/widgets/common/custom_button.dart';
import 'package:aims/widgets/common/custom_text_field.dart';
import 'package:aims/widgets/common/header.dart';
import 'package:aims/widgets/common/sidebar.dart';
import 'package:aims/widgets/common/top_notification.dart';
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
    this.activeSessionCheckInAt,
    this.activeSessionSpaceUsed,
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
  final DateTime? activeSessionCheckInAt;
  final String? activeSessionSpaceUsed;

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
    DateTime? activeSessionCheckInAt,
    String? activeSessionSpaceUsed,
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
      activeSessionCheckInAt:
          activeSessionCheckInAt ?? this.activeSessionCheckInAt,
      activeSessionSpaceUsed:
          activeSessionSpaceUsed ?? this.activeSessionSpaceUsed,
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
  static const double _desktopFrameWidth = 1720;
  static const int _usersPerPage = 4;
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
  int? _allUsersPage = 0;
  int? _activeUsersPage = 0;
  int? _inactiveUsersPage = 0;

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
      setState(_resetUserPages);
    }
  }

  void _resetUserPages() {
    _allUsersPage = 0;
    _activeUsersPage = 0;
    _inactiveUsersPage = 0;
  }

  _ActiveVisit _defaultActiveVisitFor(_StaffUser user) {
    final activeSpaceUsed = user.activeSessionSpaceUsed?.trim();
    return _ActiveVisit(
      spaceUsed: activeSpaceUsed != null && activeSpaceUsed.isNotEmpty
          ? activeSpaceUsed
          : user.membershipType == 'Annual'
          ? 'Board Room'
          : 'Open Space',
      timeIn: user.activeSessionCheckInAt ?? DateTime.now(),
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
        _resetUserPages();
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
      activeSessionCheckInAt: record.activeSessionCheckInAt,
      activeSessionSpaceUsed: record.activeSessionSpaceUsed,
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
                            padding: const EdgeInsets.all(16),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    _buildPageHero(context),
                                    const SizedBox(height: 8),
                                    _buildOverviewAndSearchSection(
                                      resultCount: filteredUsers.length,
                                    ),
                                    if (_isLoadingUsers)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 10),
                                        child: LinearProgressIndicator(
                                          minHeight: 3,
                                        ),
                                      ),
                                    const SizedBox(height: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final titleBlock = Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _panelBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.groups_outlined,
                  color: _headerBlue,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Management',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _darkText,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Add users, review visits, and manage check-in or checkout activity.',
                      style: TextStyle(
                        fontSize: 12,
                        color: _mutedText,
                        height: 1.25,
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
                const SizedBox(height: 10),
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
      width: fullWidth ? double.infinity : 170,
      height: 44,
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
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        icon: const Icon(Icons.person_add_alt_1_rounded, size: 17),
        label: const Text('Add User'),
      ),
    );
  }

  Widget _buildOverviewAndSearchSection({required int resultCount}) {
    final statChips = Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildInfoChip(label: 'Total Users', value: '${_users.length}'),
        _buildInfoChip(
          label: 'Active Users',
          value: '${_users.where((user) => user.isActive).length}',
        ),
        _buildInfoChip(label: 'Filtered Results', value: '$resultCount'),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1140) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              statChips,
              const SizedBox(height: 8),
              _buildSearchSection(resultCount),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 500, child: statChips),
            const SizedBox(width: 12),
            Expanded(child: _buildSearchSection(resultCount)),
          ],
        );
      },
    );
  }

  Widget _buildInfoChip({required String label, required String value}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 142),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _headerBlue,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchHeading(resultCount),
                const SizedBox(height: 6),
                _buildSearchControls(),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 112, child: _buildSearchHeading(resultCount)),
              const SizedBox(width: 10),
              Expanded(child: _buildSearchControls()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchHeading(int resultCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Search Users',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: _darkText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$resultCount found',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchControls() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: double.infinity, child: _buildFilterByDropdown()),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: _buildSelectedFilterInput(),
              ),
              const SizedBox(height: 6),
              _buildClearSearchButton(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(width: 170, child: _buildFilterByDropdown()),
            const SizedBox(width: 8),
            Expanded(child: _buildSelectedFilterInput()),
            const SizedBox(width: 8),
            _buildClearSearchButton(),
          ],
        );
      },
    );
  }

  Widget _buildFilterByDropdown() {
    return _buildDropdown(
      value: _selectedFilter,
      label: 'Filter By',
      items: _filterOptions,
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _selectedFilter = value;
          _searchController.clear();
          _selectedDropdownValue = 'All';
          _resetUserPages();
        });
      },
    );
  }

  Widget _buildClearSearchButton() {
    return OutlinedButton.icon(
      onPressed: () {
        _searchController.clear();
        setState(() {
          _selectedFilter = 'Last Name';
          _selectedDropdownValue = 'All';
          _resetUserPages();
        });
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkText,
        side: const BorderSide(color: Color(0x2A23323A)),
        backgroundColor: Colors.white.withValues(alpha: 0.64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      ),
      icon: const Icon(Icons.clear_rounded, size: 18),
      label: const Text('Clear', style: TextStyle(fontWeight: FontWeight.w700)),
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
          setState(() {
            _selectedDropdownValue = value;
            _resetUserPages();
          });
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
          setState(() {
            _selectedDropdownValue = value;
            _resetUserPages();
          });
        },
      );
    }

    return TextFormField(
      controller: _searchController,
      style: const TextStyle(fontSize: 15, color: _darkText),
      decoration: InputDecoration(
        hintText: 'Search ${_selectedFilter.toLowerCase()}',
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.76),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: _mutedText,
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
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
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 3),
          child: Text(
            label,
            style: const TextStyle(
              color: _mutedText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.76),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _headerBlue),
            ),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
        ),
      ],
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
                        _buildUserList(
                          filteredUsers,
                          'No users found.',
                          currentPage: _allUsersPage,
                          onPageChanged: (page) {
                            setState(() => _allUsersPage = page);
                          },
                        ),
                        _buildUserList(
                          activeUsers,
                          'No active users found.',
                          currentPage: _activeUsersPage,
                          onPageChanged: (page) {
                            setState(() => _activeUsersPage = page);
                          },
                        ),
                        _buildUserList(
                          inactiveUsers,
                          'No inactive users found.',
                          currentPage: _inactiveUsersPage,
                          onPageChanged: (page) {
                            setState(() => _inactiveUsersPage = page);
                          },
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

  Widget _buildUserList(
    List<_StaffUser> users,
    String emptyMessage, {
    required int? currentPage,
    required ValueChanged<int> onPageChanged,
  }) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(fontSize: 16, color: _mutedText),
        ),
      );
    }

    final totalPages = (users.length / _usersPerPage).ceil();
    final requestedPage = currentPage ?? 0;
    final lastPageIndex = totalPages - 1;
    final pageIndex = requestedPage < 0
        ? 0
        : requestedPage > lastPageIndex
        ? lastPageIndex
        : requestedPage;
    final startIndex = pageIndex * _usersPerPage;
    final endIndex = math.min(startIndex + _usersPerPage, users.length);
    final visibleUsers = users.sublist(startIndex, endIndex);

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            itemCount: visibleUsers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = visibleUsers[index];

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
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
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
                                      final checkOutAt = DateTime.now();
                                      final subtotalAmount =
                                          SpacePricingStore.totalForVisit(
                                            spaceUsed: visit.spaceUsed,
                                            timeIn: visit.timeIn,
                                            timeOut: checkOutAt,
                                          );
                                      late final CheckoutDiscountQuote
                                      discountQuote;
                                      try {
                                        discountQuote = await AimsApiClient
                                            .instance
                                            .quoteCheckoutDiscount(
                                              userId: user.backendId,
                                              subtotalAmount: subtotalAmount,
                                              checkoutAt: checkOutAt,
                                            );
                                      } on AimsApiException catch (error) {
                                        _showMessage(error.message);
                                        return;
                                      } catch (_) {
                                        _showMessage(
                                          'Unable to calculate checkout discounts right now.',
                                        );
                                        return;
                                      }
                                      if (!context.mounted) return;
                                      final totalAmount =
                                          discountQuote.finalAmount;

                                      showDialog(
                                        context: context,
                                        builder: (_) => CheckOut(
                                          bookingId: 'BK-${user.id}',
                                          customerName: user.fullName,
                                          spaceUsed: visit.spaceUsed,
                                          timeIn: visit.timeIn,
                                          timeOut: checkOutAt,
                                          subtotalAmount:
                                              discountQuote.subtotalAmount,
                                          membershipDiscount:
                                              discountQuote.membershipDiscount,
                                          membershipDiscountLabel:
                                              discountQuote.membershipLabel,
                                          promoDiscount:
                                              discountQuote.promoDiscount,
                                          promoDiscountLabel:
                                              discountQuote.promoLabel,
                                          totalAmount: totalAmount,
                                          onConfirm: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => PaymentDialog(
                                                subtotalAmount: discountQuote
                                                    .subtotalAmount,
                                                discountApplied:
                                                    discountQuote.totalDiscount,
                                                totalAmount: totalAmount,
                                                onConfirm: (paymentMethod) {
                                                  _completeCheckout(
                                                    user: user,
                                                    visit: visit,
                                                    checkOutAt: checkOutAt,
                                                    discountQuote:
                                                        discountQuote,
                                                    paymentMethod:
                                                        paymentMethod,
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
                                      final result =
                                          await showDialog<CheckInData>(
                                            context: context,
                                            builder: (_) => CheckIn(
                                              userId: user.id,
                                              firstName: user.firstName,
                                              lastName: user.lastName,
                                              email: user.email,
                                              phoneNumber: user.phoneNumber,
                                              userType: user.userType,
                                              membershipType:
                                                  user.membershipType,
                                              timeIn: DateTime.now(),
                                              lastVisit: user.lastVisit,
                                              onConfirm: () {},

                                              onEditUser: () {
                                                _openEditUserForm(
                                                  context,
                                                  user,
                                                );
                                              },

                                              onViewHistory: () {
                                                Navigator.pop(context);
                                                _openHistoryScreen(
                                                  context,
                                                  user,
                                                );
                                              },
                                            ),
                                          );

                                      if (result == null) {
                                        return;
                                      }

                                      try {
                                        await AimsApiClient.instance
                                            .checkInUser(
                                              userId: user.backendId,
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
                                            activeSessionCheckInAt:
                                                result.timeIn,
                                            activeSessionSpaceUsed:
                                                result.spaceUsed,
                                            history: [
                                              ...user.history,
                                              _historyLabel("User checked in"),
                                            ],
                                          );
                                          _activeVisits[user.id] = _ActiveVisit(
                                            spaceUsed: result.spaceUsed,
                                            timeIn: result.timeIn,
                                          );
                                          _resetUserPages();
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
                                  color: user.isActive
                                      ? _successColor
                                      : _dangerColor,
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
                              onPressed: () =>
                                  _openHistoryScreen(context, user),
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
                              style: _userActionButtonStyle(
                                color: _dangerColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        _buildPaginationControls(
          currentPage: pageIndex,
          totalPages: totalPages,
          totalUsers: users.length,
          startIndex: startIndex,
          endIndex: endIndex,
          onPageChanged: onPageChanged,
        ),
      ],
    );
  }

  Widget _buildPaginationControls({
    required int currentPage,
    required int totalPages,
    required int totalUsers,
    required int startIndex,
    required int endIndex,
    required ValueChanged<int> onPageChanged,
  }) {
    final firstVisible = startIndex + 1;
    final pageNumbers = _visiblePageNumbers(currentPage, totalPages);
    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _paginationIconButton(
          icon: Icons.chevron_left_rounded,
          tooltip: 'Previous page',
          enabled: currentPage > 0,
          onPressed: () => onPageChanged(currentPage - 1),
        ),
        const SizedBox(width: 6),
        ...pageNumbers.map(
          (page) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _paginationNumberButton(
              page: page,
              selected: page == currentPage,
              onPressed: () => onPageChanged(page),
            ),
          ),
        ),
        const SizedBox(width: 6),
        _paginationIconButton(
          icon: Icons.chevron_right_rounded,
          tooltip: 'Next page',
          enabled: currentPage < totalPages - 1,
          onPressed: () => onPageChanged(currentPage + 1),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.26),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rangeText = Text(
            'Showing $firstVisible-$endIndex of $totalUsers users',
            style: const TextStyle(
              color: _mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          );

          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                rangeText,
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: controls,
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: rangeText),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: controls,
              ),
            ],
          );
        },
      ),
    );
  }

  List<int> _visiblePageNumbers(int currentPage, int totalPages) {
    const visibleCount = 5;
    final firstPage = math.max(
      0,
      math.min(currentPage - 2, math.max(totalPages - visibleCount, 0)),
    );
    final lastPage = math.min(totalPages, firstPage + visibleCount);
    return [for (var page = firstPage; page < lastPage; page++) page];
  }

  Widget _paginationIconButton({
    required IconData icon,
    required String tooltip,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: 36,
        child: IconButton(
          onPressed: enabled ? onPressed : null,
          icon: Icon(icon, size: 20),
          color: _darkText,
          disabledColor: _mutedText.withValues(alpha: 0.42),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.72),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
              side: const BorderSide(color: Color(0x1F23323A)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _paginationNumberButton({
    required int page,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: OutlinedButton(
        onPressed: selected ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: selected ? Colors.white : _darkText,
          disabledForegroundColor: Colors.white,
          backgroundColor: selected
              ? _headerBlue
              : Colors.white.withValues(alpha: 0.72),
          side: BorderSide(
            color: selected ? _headerBlue : const Color(0x1F23323A),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
        child: Text('${page + 1}'),
      ),
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
        _resetUserPages();
      });
      _showMessage('${newUser.fullName} added to All Users.');
    } on AimsApiException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Unable to add user right now. Please try again.');
    }
  }

  Future<void> _openEditUserForm(BuildContext context, _StaffUser user) async {
    final result = await showDialog<UserFormData>(
      context: context,
      builder: (_) => _UserFormDialog(user: user),
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
        _resetUserPages();
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
        _resetUserPages();
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

  Future<void> _openHistoryScreen(BuildContext context, _StaffUser user) {
    return showDialog<void>(
      context: context,
      builder: (_) =>
          _UserHistoryDialog(userName: user.fullName, history: user.history),
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
    showTopNotification(context, message: message);
  }

  Future<void> _completeCheckout({
    required _StaffUser user,
    required _ActiveVisit visit,
    required DateTime checkOutAt,
    required CheckoutDiscountQuote discountQuote,
    required String paymentMethod,
  }) async {
    try {
      await AimsApiClient.instance.checkOutUser(
        userId: user.backendId,
        userEmail: user.email,
        amount: discountQuote.subtotalAmount,
        discountApplied: discountQuote.totalDiscount,
        checkOutAt: checkOutAt,
        paymentMethod: paymentMethod,
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
        _resetUserPages();
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
              subtotalAmount: discountQuote.subtotalAmount,
              discountApplied: discountQuote.totalDiscount,
              totalAmount: discountQuote.finalAmount,
            ),
          );
        },
      ),
    );
  }
}

class _UserFormDialog extends StatefulWidget {
  const _UserFormDialog({required this.user});

  final _StaffUser user;

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  static const Color _panelBlue = Color(0xFFCDECF3);
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
    _lastNameController = TextEditingController(text: user.lastName);
    _firstNameController = TextEditingController(text: user.firstName);
    _emailController = TextEditingController(text: user.email);
    _phoneNumberController = TextEditingController(text: user.phoneNumber);
    _selectedUserType = user.userType;
    _selectedMembershipType = user.membershipType;
    _isActive = user.isActive;
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
    final user = widget.user;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xF7FFFFFF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 28,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 18, 14, 18),
                  color: _panelBlue.withValues(alpha: 0.68),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: _headerBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Edit User',
                              style: TextStyle(
                                color: _textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${user.id} - ${user.email}',
                              style: const TextStyle(
                                color: _textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(22),
                    child: Form(
                      key: _formKey,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final stackFields = constraints.maxWidth < 560;
                          final emailField = CustomTextField(
                            hint: 'Email',
                            controller: _emailController,
                            validator: _emailValidator,
                          );
                          final userTypeField = DropdownButtonFormField<String>(
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
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Update the selected user information.',
                                style: TextStyle(
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
                              if (stackFields) ...[
                                emailField,
                                const SizedBox(height: 14),
                                userTypeField,
                              ] else
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: emailField),
                                    const SizedBox(width: 14),
                                    Expanded(child: userTypeField),
                                  ],
                                ),
                              const SizedBox(height: 14),
                              CustomTextField(
                                hint: 'Phone Number',
                                controller: _phoneNumberController,
                                validator: _requiredField,
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: stackFields ? double.infinity : 320,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedMembershipType,
                                  decoration: _inputDecoration(
                                    'Membership Type',
                                  ),
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
                                    setState(
                                      () => _selectedMembershipType = value,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 18),
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
                                      label: 'Save Changes',
                                      backgroundColor: _textPrimary,
                                      borderColor: _textPrimary,
                                      onPressed: () async {
                                        if (!_formKey.currentState!
                                            .validate()) {
                                          return;
                                        }
                                        Navigator.pop(
                                          context,
                                          UserFormData(
                                            firstName: _firstNameController.text
                                                .trim(),
                                            lastName: _lastNameController.text
                                                .trim(),
                                            email: _emailController.text.trim(),
                                            phoneNumber: _phoneNumberController
                                                .text
                                                .trim(),
                                            userType: _selectedUserType,
                                            membershipType:
                                                _selectedMembershipType,
                                            isActive: _isActive,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
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

class _UserHistoryDialog extends StatelessWidget {
  const _UserHistoryDialog({required this.userName, required this.history});

  static const Color _panelBlue = Color(0xFFCDECF3);
  static const Color _headerBlue = Color(0xFF80AEC1);
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF6F7E87);

  final String userName;
  final List<String> history;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 560),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xF7FFFFFF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 28,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 18, 14, 18),
                  color: _panelBlue.withValues(alpha: 0.72),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          color: _headerBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'User History',
                              style: TextStyle(
                                color: _textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userName,
                              style: const TextStyle(
                                color: _textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(18),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _panelBlue.withValues(alpha: 0.62),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
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
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFEBD9CA),
                                  child: Icon(
                                    Icons.history_toggle_off_rounded,
                                    color: _textPrimary,
                                  ),
                                ),
                                title: Text(
                                  entry,
                                  style: const TextStyle(
                                    color: _textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
    );
  }
}
