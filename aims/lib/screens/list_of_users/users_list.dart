import 'package:aims/widgets/common/custom_button.dart';
import 'package:aims/widgets/common/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:aims/widgets/forms/user_form.dart';
import 'package:aims/screens/list_of_users/checkIn.dart';
import 'package:aims/screens/list_of_users/checkOut.dart';
import 'package:aims/screens/list_of_users/payment.dart';
import 'package:aims/screens/list_of_users/payment_success.dart';

class StaffUsersListScreen extends StatefulWidget {
  const StaffUsersListScreen({super.key});

  @override
  State<StaffUsersListScreen> createState() => _StaffUsersListScreenState();
}

class _StaffUser {
  const _StaffUser({
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

  _StaffUser copyWith({
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

class _StaffUsersListScreenState extends State<StaffUsersListScreen> {
  static const Color _pageBackground = Color(0xFFF4F8FA);
  static const Color _panelColor = Colors.white;
  static const Color _accentColor = Color(0xFF76ACBD);
  static const Color _darkText = Color(0xFF22313A);
  static const Color _mutedText = Color(0xFF71808A);
  static const Color _successColor = Color(0xFF2E8B57);
  static const Color _dangerColor = Color(0xFFC95656);
  static const Color _sidebarBlue = Color(0xFF9AA9BD);
  static const Color _headerBlue = Color(0xFF80AEC1);
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

  bool isSidebarOpen = true;
  String selectedMenu = 'List of Users';
  String _selectedFilter = 'Last Name';
  String _selectedDropdownValue = 'All';
  int _nextUserNumber = 4;

  final List<_StaffUser> _users = [
    _StaffUser(
      id: 'USR-0001',
      firstName: 'Mika',
      lastName: 'Santos',
      email: 'mika.santos@example.com',
      phoneNumber: '09171234567',
      userType: 'Student',
      membershipType: 'Annual',
      isActive: true,
      history: ['User added on 2026-04-15 09:00 AM'],
    ),
    _StaffUser(
      id: 'USR-0002',
      firstName: 'Paolo',
      lastName: 'Reyes',
      email: 'paolo.reyes@example.com',
      phoneNumber: '09987654321',
      userType: 'Professional',
      membershipType: 'Monthly Membership',
      isActive: true,
      history: [
        'User added on 2026-04-14 10:20 AM',
        'User edited on 2026-04-16 04:05 PM',
      ],
    ),
    _StaffUser(
      id: 'USR-0003',
      firstName: 'Andrea',
      lastName: 'Lim',
      email: 'andrea.lim@example.com',
      phoneNumber: '09175557777',
      userType: 'Student',
      membershipType: 'Open Time',
      isActive: false,
      history: ['User added on 2026-04-11 11:40 AM'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refresh);
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
              _buildTopBar(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isSidebarOpen) _buildSidebar(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPageHeader(context),
                            const SizedBox(height: 16),
                            _buildSearchSection(filteredUsers.length),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _panelColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x12000000),
                                      blurRadius: 20,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F1F4),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: const TabBar(
                                          indicatorSize:
                                              TabBarIndicatorSize.tab,

                                          indicator: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(16),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0x11000000),
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          labelColor: _darkText,
                                          unselectedLabelColor: _mutedText,

                                          dividerColor: Colors.transparent,
                                          tabs: [
                                            Tab(text: 'All Users'),
                                            Tab(text: 'Active User'),
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
                                          ),
                                          _buildUserList(
                                            activeUsers,
                                            'No active users found.',
                                          ),
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
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _headerBlue,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                isSidebarOpen = !isSidebarOpen;
              });
            },
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.logout_rounded, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Text(
            'afterspace',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const Spacer(),
          const Text(
            'Staff',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withOpacity(0.95),
            child: const Icon(Icons.badge_outlined, size: 20, color: _headerBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 146,
      margin: const EdgeInsets.only(top: 2),
      decoration: const BoxDecoration(
        color: _sidebarBlue,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          _buildSidebarItem(Icons.home_outlined, 'Dashboard'),
          _buildSidebarItem(Icons.calendar_today_outlined, 'Calendar'),
          _buildSidebarItem(Icons.list_alt_outlined, 'List of Users'),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title) {
    final isSelected = selectedMenu == title;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () {
          if (title == 'Calendar') {
            Navigator.pushReplacementNamed(context, '/calendar');
            return;
          }

          if (title == 'List of Users') {
            setState(() {
              selectedMenu = title;
            });
            return;
          }

          Navigator.pushNamed(context, '/staff-dashboard');
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? _darkText : Colors.white,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                icon,
                size: 18,
                color: isSelected ? _darkText : Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;

        return isCompact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Management',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _darkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Staff can add, edit, delete, search, and review user history.',
                    style: TextStyle(fontSize: 14, color: _mutedText),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      label: 'Add User',
                      backgroundColor: _accentColor,
                      borderColor: _accentColor,
                      onPressed: () async {
                        await _openAddUserForm(context);
                      },
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Management',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _darkText,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Staff can add, edit, delete, search, and review user history.',
                          style: TextStyle(fontSize: 14, color: _mutedText),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 160,
                    child: CustomButton(
                      label: 'Add User',
                      backgroundColor: _accentColor,
                      borderColor: _accentColor,
                      onPressed: () async {
                        await _openAddUserForm(context);
                      },
                    ),
                  ),
                ],
              );
      },
    );
  }

  Widget _buildSearchSection(int resultCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
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
                    fontWeight: FontWeight.w700,
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
                  : constraints.maxWidth - 220 - 164 - 24;

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
              SizedBox(
                width: 130,
                child: CustomButton(
                  label: 'Clear',
                  backgroundColor: Colors.white,
                  textColor: _darkText,
                  borderColor: _darkText,
                  onPressed: () async {
                    _searchController.clear();
                    setState(() {
                      _selectedFilter = 'Last Name';
                      _selectedDropdownValue = 'All';
                    });
                  },
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
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(),
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          child: InkWell(
            onTap: () => _openEditUserForm(context, user),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD8E4E8)),
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
                              '${user.id} • ${user.email}',
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
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => CheckOut(
                                    bookingId: 'BK-${user.id}',
                                    customerName: user.fullName,
                                    spaceUsed: 'Regular Seat',
                                    timeIn: DateTime.now().subtract(
                                      const Duration(hours: 3),
                                    ),
                                    onConfirm: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => PaymentDialog(
                                          totalAmount: 235.00,
                                          onConfirm: () {
                                            setState(() {
                                              final index = _users.indexWhere(
                                                (u) => u.id == user.id,
                                              );
                                              if (index != -1) {
                                                _users[index] = user.copyWith(
                                                  isActive: false,
                                                  history: [
                                                    ...user.history,
                                                    _historyLabel(
                                                      "User checked out & paid",
                                                    ),
                                                  ],
                                                );
                                              }
                                            });

                                            showDialog(
                                              context: context,
                                              builder: (_) =>
                                                  PaymentSuccessDialog(
                                                    onGenerateReceipt: () {},
                                                  ),
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
                              ),
                            )
                          // Inactive users can check back in.
                          : ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
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

                                    onConfirm: () {
                                      setState(() {
                                        final index = _users.indexWhere(
                                          (u) => u.id == user.id,
                                        );
                                        if (index != -1) {
                                          _users[index] = user.copyWith(
                                            isActive: true,
                                            history: [
                                              ...user.history,
                                              _historyLabel("User checked in"),
                                            ],
                                          );
                                        }
                                      });
                                      _showMessage(
                                        "${user.fullName} checked in sucessfully",
                                      );
                                    },

                                    onEditUser: () {
                                      _openEditUserForm(context, user);
                                    },
                                  ),
                                );
                              },
                              icon: const Icon(Icons.login),
                              label: const Text("Check-In"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _successColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                            ),

                      const SizedBox(width: 100),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: user.isActive
                              ? _successColor.withOpacity(0.12)
                              : _dangerColor.withOpacity(0.12),
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
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _openEditUserForm(context, user),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit User'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await _confirmDeleteUser(context, user);
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete User'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _dangerColor,
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
    );
  }

  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3F6),
        borderRadius: BorderRadius.circular(999),
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
    final result = await Navigator.of(
      context,
    ).push<UserFormData>(MaterialPageRoute(builder: (_) => const AddUser()));

    if (result == null) return;

    final timestamp = _historyLabel('User added');
    final newUser = _StaffUser(
      id: 'USR-${_nextUserNumber.toString().padLeft(4, '0')}',
      firstName: result.firstName,
      lastName: result.lastName,
      email: result.email,
      phoneNumber: result.phoneNumber,
      userType: result.userType,
      membershipType: result.membershipType,
      isActive: true,
      history: [timestamp],
    );

    setState(() {
      _nextUserNumber += 1;
      _users.insert(0, newUser);
    });

    _showMessage('${newUser.fullName} added to Active Users.');
  }

  Future<void> _openEditUserForm(BuildContext context, _StaffUser user) async {
    final result = await Navigator.of(context).push<UserFormData>(
      MaterialPageRoute(builder: (_) => _UserFormScreen(user: user)),
    );

    if (result == null) return;

    setState(() {
      final index = _users.indexWhere((item) => item.id == user.id);
      if (index == -1) return;
      _users[index] = user.copyWith(
        firstName: result.firstName,
        lastName: result.lastName,
        email: result.email,
        phoneNumber: result.phoneNumber,
        userType: result.userType,
        membershipType: result.membershipType,
        isActive: result.isActive,
        history: [...user.history, _historyLabel('User edited')],
      );
    });

    _showMessage('${user.id} updated successfully.');
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

    setState(() {
      _users.removeWhere((item) => item.id == user.id);
    });

    _showMessage('${user.fullName} deleted. ${_historyLabel('User deleted')}');
    return true;
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
}

class _UserFormScreen extends StatefulWidget {
  const _UserFormScreen({this.user});

  final _StaffUser? user;

  bool get isEdit => user != null;

  @override
  State<_UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<_UserFormScreen> {
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
        backgroundColor: const Color(0xFF76ACBD),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF4F8FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 20,
                    offset: Offset(0, 10),
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
                      style: const TextStyle(color: Color(0xFF71808A)),
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
                            value: _selectedUserType,
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
                          value: _selectedMembershipType,
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

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE8F1F4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'User is Active',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF22313A),
                            ),
                          ),
                          Switch(
                            value: _isActive,
                            activeColor: const Color(0xFF2E8B57),
                            onChanged: (bool value) {
                              setState(() {
                                _isActive = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            label: 'Cancel',
                            backgroundColor: Colors.white,
                            textColor: const Color(0xFF22313A),
                            borderColor: const Color(0xFF22313A),
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
                            backgroundColor: const Color(0xFF76ACBD),
                            borderColor: const Color(0xFF76ACBD),
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
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
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

  final String userName;
  final List<String> history;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$userName History'),
        backgroundColor: const Color(0xFF76ACBD),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF4F8FA),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: history.isEmpty
              ? const Center(
                  child: Text(
                    'No history available for this user.',
                    style: TextStyle(color: Color(0xFF71808A)),
                  ),
                )
              : ListView.separated(
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const Divider(height: 18),
                  itemBuilder: (context, index) {
                    final entry = history[history.length - index - 1];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE8F1F4),
                        child: Icon(
                          Icons.history_toggle_off_rounded,
                          color: Color(0xFF22313A),
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
