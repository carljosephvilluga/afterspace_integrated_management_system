import 'package:aims/widgets/common/custom_button.dart';
import 'package:aims/widgets/common/custom_text_field.dart';
import 'package:aims/widgets/utils/validators.dart';
import 'package:flutter/material.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _Reservation {
  const _Reservation({
    required this.name,
    required this.email,
    required this.time,
    required this.duration,
  });

  final String name;
  final String email;
  final String time;
  final String duration;
}

class _AppUser {
  const _AppUser({
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

  _AppUser copyWith({
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
    return _AppUser(
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

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  static const Color _pageBackground = Color(0xFFDDECEF);
  static const Color _surfaceBlue = Color(0xFFC7E8EE);
  static const Color _sidebarBlue = Color(0xFF9AA9BD);
  static const Color _headerBlue = Color(0xFF80AEC1);
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF7D8A93);
  static const Color _successGreen = Color(0xFF2D8C63);
  static const Color _dangerRed = Color(0xFFD85C5C);

  static final List<_Reservation> _reservations = [
    const _Reservation(
      name: 'Jenny Wilson',
      email: 'j.wilson@example.com',
      time: '12:30pm',
      duration: '2 hours',
    ),
    const _Reservation(
      name: 'Devon Lane',
      email: 'd.roberts@example.com',
      time: '1:00pm',
      duration: '3 hours',
    ),
    const _Reservation(
      name: 'Jane Cooper',
      email: 'jgraham@example.com',
      time: '3:00pm',
      duration: '4 hours',
    ),
    const _Reservation(
      name: 'Dianne Russell',
      email: 'curtis.d@example.com',
      time: '4:00pm',
      duration: '1 hour',
    ),
  ];

  final List<_AppUser> _users = [
    _AppUser(
      id: 'USR-0001',
      firstName: 'Mika',
      lastName: 'Santos',
      email: 'mika.santos@example.com',
      phoneNumber: '09171234567',
      userType: 'Student',
      membershipType: 'Annual',
      isActive: true,
      history: [
        'User added on 2026-04-15 09:00 AM',
        'User edited on 2026-04-16 02:15 PM',
      ],
    ),
    _AppUser(
      id: 'USR-0002',
      firstName: 'Paolo',
      lastName: 'Reyes',
      email: 'paolo.reyes@example.com',
      phoneNumber: '09987654321',
      userType: 'Professional',
      membershipType: 'Monthly Membership',
      isActive: true,
      history: ['User added on 2026-04-14 11:20 AM'],
    ),
    _AppUser(
      id: 'USR-0003',
      firstName: 'Andrea',
      lastName: 'Lim',
      email: 'andrea.lim@example.com',
      phoneNumber: '09175557777',
      userType: 'Student',
      membershipType: 'Open Time',
      isActive: false,
      history: [
        'User added on 2026-04-10 10:45 AM',
        'User edited on 2026-04-18 04:30 PM',
      ],
    ),
  ];

  final Map<String, List<String>> _deletedUserHistory = {};

  bool isSidebarOpen = true;
  String selectedMenu = 'List of Users';
  int _nextUserNumber = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: _buildSelectedContent(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedContent() {
    if (selectedMenu == 'Dashboard') {
      return _buildDashboardContent();
    }

    if (selectedMenu == 'List of Users') {
      return _buildUserManagementContent();
    }

    return _buildPlaceholder(selectedMenu);
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
            child: const Icon(
              Icons.badge_outlined,
              size: 20,
              color: _headerBlue,
            ),
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
          _buildSidebarItem(Icons.inventory_2_outlined, 'Inventory'),
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
          setState(() {
            selectedMenu = title;
          });
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
                    color: isSelected ? _textPrimary : Colors.white,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                icon,
                size: 18,
                color: isSelected ? _textPrimary : Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 1060;

        if (isCompact) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMetricRow(),
                const SizedBox(height: 12),
                SizedBox(height: 320, child: _buildCalendarPanel()),
                const SizedBox(height: 12),
                SizedBox(height: 320, child: _buildReservationsPanel()),
                const SizedBox(height: 12),
                SizedBox(height: 280, child: _buildActiveCustomersPanel()),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 360,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        _buildMetricRow(),
                        const SizedBox(height: 12),
                        Expanded(child: _buildCalendarPanel()),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(flex: 4, child: _buildReservationsPanel()),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildActiveCustomersPanel()),
          ],
        );
      },
    );
  }

  Widget _buildMetricRow() {
    return Row(
      children: const [
        Expanded(
          child: StaffMetricCard(
            title: 'TOTAL SALES',
            value: '\$2,38,485',
            change: '+14%',
            surfaceColor: _surfaceBlue,
            textColor: _textPrimary,
            mutedColor: _textMuted,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: StaffMetricCard(
            title: 'ACTIVE CUSTOMERS',
            value: '143',
            change: '+36%',
            surfaceColor: _surfaceBlue,
            textColor: _textPrimary,
            mutedColor: _textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarPanel() {
    return _buildPanel(title: '', child: const CalendarChart());
  }

  Widget _buildReservationsPanel() {
    return _buildPanel(
      title: 'Pending Reservations',
      subtitle: 'Lorem ipsum dolor sit ametis.',
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reservations.length,
              separatorBuilder: (context, index) => const Divider(
                height: 18,
                thickness: 1,
                color: Color(0x1A6C7B84),
              ),
              itemBuilder: (context, index) {
                final item = _reservations[index];
                return StaffReservationListItem(
                  name: item.name,
                  email: item.email,
                  time: item.time,
                  duration: item.duration,
                  textColor: _textPrimary,
                  mutedColor: _textMuted,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Text(
                'SEE ALL CUSTOMERS',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: _textMuted,
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10,
                color: _textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCustomersPanel() {
    return _buildPanel(
      title: 'Active Customers',
      child: ActiveCustomersTable(
        textColor: _textPrimary,
        mutedColor: _textMuted,
      ),
    );
  }

  Widget _buildUserManagementContent() {
    final activeUsers = _users.where((user) => user.isActive).toList();
    final inactiveUsers = _users.where((user) => !user.isActive).toList();

    return DefaultTabController(
      length: 3,
      child: _buildPanel(
        title: 'User Management',
        subtitle: 'Staff can add, edit, review history, and delete users.',
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      labelColor: _textPrimary,
                      unselectedLabelColor: _textMuted,
                      tabs: [
                        Tab(text: 'All Users'),
                        Tab(text: 'Active Users'),
                        Tab(text: 'Inactive Users'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 150,
                  child: CustomButton(
                    label: 'Add User',
                    onPressed: _openAddUserScreen,
                    backgroundColor: _textPrimary,
                    textColor: Colors.white,
                    height: 48,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  _buildUserList(
                    users: _users,
                    emptyMessage: 'No users yet. Create your first user.',
                  ),
                  _buildUserList(
                    users: activeUsers,
                    emptyMessage: 'No active users found.',
                  ),
                  _buildUserList(
                    users: inactiveUsers,
                    emptyMessage: 'No inactive users found.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList({
    required List<_AppUser> users,
    required String emptyMessage,
  }) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _textMuted,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = users[index];

        return Dismissible(
          key: ValueKey(user.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) => _deleteUser(user),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: _dangerRed,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          child: Material(
            color: Colors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _openEditUserScreen(user),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 760;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isNarrow) ...[
                          _buildUserInfo(user),
                          const SizedBox(height: 14),
                          _buildUserActions(user, isNarrow: true),
                        ] else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: _buildUserInfo(user)),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: _buildUserActions(user, isNarrow: false),
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
        );
      },
    );
  }

  Widget _buildUserInfo(_AppUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: _surfaceBlue,
              child: Text(
                user.firstName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(fontSize: 14, color: _textMuted),
                  ),
                ],
              ),
            ),
            _buildStatusChip(user.isActive),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildDetailChip(Icons.badge_outlined, 'ID: ${user.id}'),
            _buildDetailChip(Icons.phone_outlined, user.phoneNumber),
            _buildDetailChip(Icons.school_outlined, user.userType),
            _buildDetailChip(
              Icons.workspace_premium_outlined,
              user.membershipType,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserActions(_AppUser user, {required bool isNarrow}) {
    final alignment = isNarrow
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.end;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          'Swipe left or use the buttons below.',
          style: const TextStyle(fontSize: 12, color: _textMuted),
          textAlign: isNarrow ? TextAlign.start : TextAlign.end,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: isNarrow ? WrapAlignment.start : WrapAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () => _openHistoryScreen(user),
              icon: const Icon(Icons.history_rounded),
              label: const Text('User History'),
            ),
            OutlinedButton.icon(
              onPressed: () => _openEditUserScreen(user),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit User'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _dangerRed),
              onPressed: () => _deleteUser(user),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete User'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(bool isActive) {
    final background = isActive
        ? _successGreen.withOpacity(0.12)
        : _dangerRed.withOpacity(0.12);
    final color = isActive ? _successGreen : _dangerRed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _textMuted),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddUserScreen() async {
    final newUser = await Navigator.of(context).push<_AppUser>(
      MaterialPageRoute(
        builder: (context) => _AddUserScreen(
          nextUserId: _generateUserId(_nextUserNumber),
          backgroundColor: _pageBackground,
          surfaceColor: _surfaceBlue,
          textColor: _textPrimary,
        ),
      ),
    );

    if (newUser == null) {
      return;
    }

    setState(() {
      _users.insert(0, newUser);
      _nextUserNumber += 1;
    });

    _showSnackBar('${newUser.fullName} added to Active Users.');
  }

  Future<void> _openEditUserScreen(_AppUser user) async {
    final updatedUser = await Navigator.of(context).push<_AppUser>(
      MaterialPageRoute(
        builder: (context) => _EditUserScreen(
          user: user,
          backgroundColor: _pageBackground,
          surfaceColor: _surfaceBlue,
          textColor: _textPrimary,
        ),
      ),
    );

    if (updatedUser == null) {
      return;
    }

    final index = _users.indexWhere((item) => item.id == user.id);
    if (index == -1) {
      return;
    }

    setState(() {
      _users[index] = updatedUser;
    });

    _showSnackBar('${updatedUser.fullName} updated successfully.');
  }

  Future<void> _openHistoryScreen(_AppUser user) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _UserHistoryScreen(
          userName: user.fullName,
          userId: user.id,
          history: user.history,
          backgroundColor: _pageBackground,
          surfaceColor: _surfaceBlue,
          textColor: _textPrimary,
        ),
      ),
    );
  }

  Future<bool> _deleteUser(_AppUser user) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text(
            'Are you sure you want to delete ${user.fullName}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _dangerRed),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return false;
    }

    final deleteEntry = _buildHistoryEntry('User deleted');

    setState(() {
      _deletedUserHistory[user.id] = [...user.history, deleteEntry];
      _users.removeWhere((item) => item.id == user.id);
    });

    _showSnackBar('${user.fullName} deleted.');
    return true;
  }

  String _generateUserId(int number) =>
      'USR-${number.toString().padLeft(4, '0')}';

  String _buildHistoryEntry(String action) {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour24 = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final hour12 = ((hour24 + 11) % 12 + 1).toString().padLeft(2, '0');
    final suffix = hour24 >= 12 ? 'PM' : 'AM';

    return '$action on ${now.year}-$month-$day $hour12:$minute $suffix';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildPanel({
    required String title,
    required Widget child,
    String? subtitle,
  }) {
    return StaffDashboardPanel(
      title: title,
      subtitle: subtitle,
      surfaceColor: _surfaceBlue,
      textColor: _textPrimary,
      child: child,
    );
  }

  Widget _buildPlaceholder(String title) {
    return _buildPanel(
      title: title,
      child: Center(
        child: Text(
          '$title section coming next',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
      ),
    );
  }
}

class _AddUserScreen extends StatefulWidget {
  const _AddUserScreen({
    required this.nextUserId,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
  });

  final String nextUserId;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;

  @override
  State<_AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<_AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedUserType = 'Student';
  String _selectedMembershipType = 'Annual';

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      appBar: AppBar(
        title: const Text('Add User'),
        backgroundColor: widget.surfaceColor,
        foregroundColor: widget.textColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.surfaceColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create a New User',
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'User ID: ${widget.nextUserId}',
                      style: const TextStyle(
                        color: _StaffDashboardScreenState._textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 620;

                        return Column(
                          children: [
                            if (isCompact) ...[
                              _buildFormColumn(),
                            ] else
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildFormColumn()),
                                  const SizedBox(width: 24),
                                  Expanded(child: _buildSelectionColumn()),
                                ],
                              ),
                            if (isCompact) ...[
                              const SizedBox(height: 24),
                              _buildSelectionColumn(),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 140,
                          child: CustomButton(
                            label: 'Cancel',
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                            backgroundColor: Colors.white,
                            textColor: widget.textColor,
                            borderColor: widget.textColor,
                            height: 48,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 160,
                          child: CustomButton(
                            label: 'Create User',
                            onPressed: _submitForm,
                            backgroundColor: widget.textColor,
                            textColor: Colors.white,
                            height: 48,
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

  Widget _buildFormColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Last Name', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        CustomTextField(
          hint: 'Enter last name',
          controller: _lastNameController,
          validator: Validators.name,
        ),
        const SizedBox(height: 18),
        const Text('First Name', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        CustomTextField(
          hint: 'Enter first name',
          controller: _firstNameController,
          validator: Validators.name,
        ),
        const SizedBox(height: 18),
        const Text('Email', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        CustomTextField(
          hint: 'user@email.com',
          controller: _emailController,
          validator: Validators.emailValidator,
        ),
        const SizedBox(height: 18),
        const Text(
          'Phone Number',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          hint: '09XXXXXXXXX',
          controller: _phoneController,
          validator: _validatePhoneNumber,
        ),
      ],
    );
  }

  Widget _buildSelectionColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('User Type', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildChoiceChip(
              label: 'Student',
              isSelected: _selectedUserType == 'Student',
              onTap: () => setState(() => _selectedUserType = 'Student'),
            ),
            _buildChoiceChip(
              label: 'Professional',
              isSelected: _selectedUserType == 'Professional',
              onTap: () => setState(() => _selectedUserType = 'Professional'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Membership Type',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildChoiceChip(
              label: 'Annual',
              isSelected: _selectedMembershipType == 'Annual',
              onTap: () => setState(() => _selectedMembershipType = 'Annual'),
            ),
            _buildChoiceChip(
              label: 'Loyalty Rewards',
              isSelected: _selectedMembershipType == 'Loyalty Rewards',
              onTap: () =>
                  setState(() => _selectedMembershipType = 'Loyalty Rewards'),
            ),
            _buildChoiceChip(
              label: 'Monthly Membership',
              isSelected: _selectedMembershipType == 'Monthly Membership',
              onTap: () => setState(
                () => _selectedMembershipType = 'Monthly Membership',
              ),
            ),
            _buildChoiceChip(
              label: 'Open Time',
              isSelected: _selectedMembershipType == 'Open Time',
              onTap: () =>
                  setState(() => _selectedMembershipType = 'Open Time'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: widget.textColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : widget.textColor,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nowEntry = _buildHistoryEntry('User added');

    Navigator.of(context).pop(
      _AppUser(
        id: widget.nextUserId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        userType: _selectedUserType,
        membershipType: _selectedMembershipType,
        isActive: true,
        history: [nowEntry],
      ),
    );
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  String _buildHistoryEntry(String action) {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour24 = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final hour12 = ((hour24 + 11) % 12 + 1).toString().padLeft(2, '0');
    final suffix = hour24 >= 12 ? 'PM' : 'AM';

    return '$action on ${now.year}-$month-$day $hour12:$minute $suffix';
  }
}

class _EditUserScreen extends StatefulWidget {
  const _EditUserScreen({
    required this.user,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
  });

  final _AppUser user;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;

  @override
  State<_EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<_EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _isActive = widget.user.isActive;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      appBar: AppBar(
        title: const Text('Edit User'),
        backgroundColor: widget.surfaceColor,
        foregroundColor: widget.textColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.surfaceColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update User Details',
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Editing ${widget.user.id}',
                      style: const TextStyle(
                        color: _StaffDashboardScreenState._textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'First Name',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hint: 'Enter first name',
                      controller: _firstNameController,
                      validator: Validators.name,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Last Name',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hint: 'Enter last name',
                      controller: _lastNameController,
                      validator: Validators.name,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hint: 'user@email.com',
                      controller: _emailController,
                      validator: Validators.emailValidator,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: true,
                          icon: Icon(Icons.check_circle_outline),
                          label: Text('Active'),
                        ),
                        ButtonSegment<bool>(
                          value: false,
                          icon: Icon(Icons.pause_circle_outline),
                          label: Text('Inactive'),
                        ),
                      ],
                      selected: {_isActive},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _isActive = selection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 140,
                          child: CustomButton(
                            label: 'Cancel',
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                            backgroundColor: Colors.white,
                            textColor: widget.textColor,
                            borderColor: widget.textColor,
                            height: 48,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 140,
                          child: CustomButton(
                            label: 'Save',
                            onPressed: _saveChanges,
                            backgroundColor: widget.textColor,
                            textColor: Colors.white,
                            height: 48,
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedUser = widget.user.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      isActive: _isActive,
      history: [...widget.user.history, _buildHistoryEntry('User edited')],
    );

    Navigator.of(context).pop(updatedUser);
  }

  String _buildHistoryEntry(String action) {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour24 = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final hour12 = ((hour24 + 11) % 12 + 1).toString().padLeft(2, '0');
    final suffix = hour24 >= 12 ? 'PM' : 'AM';

    return '$action on ${now.year}-$month-$day $hour12:$minute $suffix';
  }
}

class _UserHistoryScreen extends StatelessWidget {
  const _UserHistoryScreen({
    required this.userName,
    required this.userId,
    required this.history,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
  });

  final String userName;
  final String userId;
  final List<String> history;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('User History'),
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'History for $userId',
                    style: const TextStyle(
                      color: _StaffDashboardScreenState._textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: history.isEmpty
                        ? const Center(
                            child: Text(
                              'No history available for this user.',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _StaffDashboardScreenState._textMuted,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: history.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final entry = history[history.length - index - 1];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.history_toggle_off_rounded,
                                      color:
                                          _StaffDashboardScreenState._textMuted,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        entry,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: _StaffDashboardScreenState
                                              ._textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StaffDashboardPanel extends StatelessWidget {
  const StaffDashboardPanel({
    super.key,
    required this.title,
    required this.child,
    required this.surfaceColor,
    required this.textColor,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Color surfaceColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: const TextStyle(
                  color: _StaffDashboardScreenState._textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
          Expanded(child: child),
        ],
      ),
    );
  }
}

class StaffMetricCard extends StatelessWidget {
  const StaffMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.surfaceColor,
    required this.textColor,
    required this.mutedColor,
  });

  final String title;
  final String value;
  final String change;
  final Color surfaceColor;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: mutedColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              change,
              style: const TextStyle(
                color: _StaffDashboardScreenState._successGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarChart extends StatelessWidget {
  const CalendarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dates = [14, 15, 16, 17, 18, 19, 20];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'April 2026',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _StaffDashboardScreenState._textPrimary,
              ),
            ),
            Spacer(),
            Icon(Icons.calendar_month_outlined),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: List.generate(
            days.length,
            (index) => Expanded(
              child: Column(
                children: [
                  Text(
                    days[index],
                    style: const TextStyle(
                      color: _StaffDashboardScreenState._textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: dates[index] == 19
                          ? _StaffDashboardScreenState._headerBlue
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '${dates[index]}',
                        style: TextStyle(
                          color: dates[index] == 19
                              ? Colors.white
                              : _StaffDashboardScreenState._textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Upcoming Staff Tasks',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _StaffDashboardScreenState._textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        const _ScheduleTile(time: '09:00 AM', title: 'Desk opening'),
        const SizedBox(height: 10),
        const _ScheduleTile(time: '01:00 PM', title: 'Review reservations'),
        const SizedBox(height: 10),
        const _ScheduleTile(time: '04:00 PM', title: 'Membership follow-up'),
      ],
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
    required this.time,
    required this.title,
  });

  final String time;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.access_time_rounded,
            color: _StaffDashboardScreenState._textMuted,
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: _StaffDashboardScreenState._textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _StaffDashboardScreenState._textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StaffReservationListItem extends StatelessWidget {
  const StaffReservationListItem({
    super.key,
    required this.name,
    required this.email,
    required this.time,
    required this.duration,
    required this.textColor,
    required this.mutedColor,
  });

  final String name;
  final String email;
  final String time;
  final String duration;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          child: Text(
            name.substring(0, 1),
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(email, style: TextStyle(color: mutedColor, fontSize: 12)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(duration, style: TextStyle(color: mutedColor, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class ActiveCustomersTable extends StatelessWidget {
  const ActiveCustomersTable({
    super.key,
    required this.textColor,
    required this.mutedColor,
  });

  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('Aly Reyes', 'Student', 'Annual', 'Active'),
      ('Marco Dela Cruz', 'Professional', 'Monthly', 'Active'),
      ('Bea Gomez', 'Student', 'Open Time', 'Active'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
        dataTextStyle: TextStyle(color: textColor),
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Membership')),
          DataColumn(label: Text('Status')),
        ],
        rows: rows
            .map(
              (row) => DataRow(
                cells: [
                  DataCell(Text(row.$1)),
                  DataCell(Text(row.$2)),
                  DataCell(Text(row.$3)),
                  DataCell(
                    Text(
                      row.$4,
                      style: const TextStyle(
                        color: _StaffDashboardScreenState._successGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
