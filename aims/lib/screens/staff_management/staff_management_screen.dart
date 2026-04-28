import 'package:aims/widgets/common/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:aims/widgets/dialogs/confirm_deletion.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  static const Color _pageBackground = Color(0xFFF4F8FA);
  static const Color _surfaceBlue = Color(0xFFC6E8EE);
  static const Color _accent = Color(0xFF80AEC1);
  static const Color _success = Color(0xFF2E8B57);
  static const Color _danger = Color(0xFFC95656);
  static const Color _textPrimary = Color(0xFF22313A);
  static const Color _textMuted = Color(0xFF6C7B84);

  final List<Map<String, dynamic>> staffList = [
    {
      'id': 'STF-001',
      'firstName': 'Juan',
      'middleInitial': 'A',
      'lastName': 'Dela Cruz',
      'userType': 'Manager',
      'status': 'On Duty',
      'activity': 'Checked in',
      'hours': '8',
      'email': 'juan@example.com',
      'phone': '09123456789',
      'workSchedule': 'Mon-Fri',   // dropdown choice
      'timeFrom': '08:00',
      'timeTo': '17:00',
    },
    {
      'id': 'STF-002',
      'firstName': 'Maria',
      'middleInitial': 'B',
      'lastName': 'Santos',
      'userType': 'Staff',
      'status': 'Off Duty',
      'activity': 'Break',
      'hours': '6',
      'email': 'maria@example.com',
      'phone': '09987654321',
      'workSchedule': 'Weekends',
      'timeFrom': '09:00',
      'timeTo': '15:00',
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleInitialController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _userTypeController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _scheduleController = TextEditingController();
  final TextEditingController _timeFromController = TextEditingController();
  final TextEditingController _timeToController = TextEditingController();

  String searchQuery = '';
  String selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    _idController.dispose();
    _firstNameController.dispose();
    _middleInitialController.dispose();
    _userTypeController.dispose();
    _activityController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _scheduleController.dispose();
    _lastNameController.dispose();
    _statusController.dispose();
    _hoursController.dispose();
    _timeFromController.dispose();
    _timeToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.all(widget.embedded ? 0 : 16),
      child: _buildContent(),
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(child: content),
    );
  }

  Widget _buildContent() {
    final filteredStaff = _filteredStaff();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'List of Staff',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _success,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'Add Staff',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: _showAddForm,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search staff by name, ID, or email',
                  prefixIcon: const Icon(Icons.search, color: _textMuted),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5E6CC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2D4C4)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedFilter,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Staff')),
                    DropdownMenuItem(value: 'On Duty', child: Text('On Duty')),
                    DropdownMenuItem(
                      value: 'Off Duty',
                      child: Text('Off Duty'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedFilter = value;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: filteredStaff.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  itemCount: filteredStaff.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _buildStaffCard(filteredStaff[index]);
                  },
                ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _filteredStaff() {
    final normalizedSearch = searchQuery.trim().toLowerCase();

    return staffList.where((staff) {

      final fullName =
        "${staff['firstName'] ?? ''} ${staff['middleInitial'] ?? ''} ${staff['lastName'] ?? ''}".toLowerCase();

      final id = staff['id'].toString().toLowerCase();
      final email = staff['email'].toString().toLowerCase();
      final userType = staff['userType'].toString().toLowerCase();
      final status = staff['status'].toString().toLowerCase();
      final activity = staff['activity'].toString().toLowerCase();
      final hours = staff['hours'].toString().toLowerCase();
      final phone = staff['phone'].toString().toLowerCase();
      final schedule = staff['schedule'].toString().toLowerCase();
      final matchesSearch =
          normalizedSearch.isEmpty ||
          fullName.contains(normalizedSearch) ||
          id.contains(normalizedSearch) ||
          email.contains(normalizedSearch) ||
          userType.contains(normalizedSearch) ||
          status.contains(normalizedSearch) ||
          activity.contains(normalizedSearch) ||
          hours.contains(normalizedSearch) ||
          phone.contains(normalizedSearch) ||
          schedule.contains(normalizedSearch);
      final matchesFilter =
          selectedFilter == 'All' || staff['status'] == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Widget _buildStaffCard(Map<String, dynamic> staff) {
    final isOnDuty = staff['status'] == 'On Duty';
    final statusColor = isOnDuty ? _success : _danger;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EEF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _surfaceBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.badge_outlined, color: _textPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${staff['firstName'] ?? ''} ${staff['middleInitial'] ?? ''} ${staff['lastName'] ?? ''}",
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${staff['id']} - ${staff['email']}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusPill(staff['status'], statusColor),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoTag('Type: ${staff['userType']}'),
              _buildInfoTag('Phone: ${staff['phone']}'),
              _buildInfoTag('Recent Activity: ${staff['activity']}'),
              _buildInfoTag('Total Woking Hours: ${staff['hours']}'),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionButton(
                label: 'History',
                icon: Icons.history_rounded,
                onPressed: () => _showStaffDetails(staff),
              ),
              _buildActionButton(
                label: 'Edit',
                icon: Icons.edit_outlined,
                onPressed: () => _showEditForm(staff),
              ),
              _buildActionButton(
                label: 'Delete',
                icon: Icons.delete_outline,
                textColor: _danger,
                borderColor: const Color(0xFFF1C9C9),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ConfirmDeleteDialog(
                      staff: staff,
                      onDelete: () {
                        setState(() {
                          staffList.remove(staff);
                        });
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.search_off_rounded, size: 42, color: _textMuted),
          SizedBox(height: 10),
          Text(
            'No staff found',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try another search or filter.',
            style: TextStyle(color: _textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    Color? textColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    final foreground = textColor ?? _accent;

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground,
        side: BorderSide(color: borderColor ?? const Color(0xFFC9DDE5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      onPressed: onPressed,
    );
  }

  Widget _buildStatusPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildInfoTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FA),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2ECEF)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: _textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _compactTextField({
    required String hint,
    required TextEditingController controller,
    IconData? suffixIcon,
  }) {
    return SizedBox(
      height: 40, // compact height
      child: TextField(
        controller: controller,
        readOnly: suffixIcon != null, // for calendar/time pickers
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        ),
      ),
    );
  }

  final List<String> daysOfWeek = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  final Map<String, bool> selectedDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  void _showAddForm() {
    _idController.clear();
    _lastNameController.clear();
    _firstNameController.clear();
    _middleInitialController.clear();
    _userTypeController.clear();
    _emailController.clear();
    _phoneController.clear();
    _scheduleController.clear();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.grey, width: 1.5),
            ),
            titlePadding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Expanded(
                  child: Center(
                    child: Text(
                      'Staff Details',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            content: SizedBox(
              width: 700,
              height: 300,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Staff ID",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                              _compactTextField(hint: '0001', controller: _idController),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Last Name",
                              style: TextStyle(fontWeight: FontWeight.bold),),
                              _compactTextField(hint: 'Last Name', controller: _lastNameController),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("First Name",
                              style: TextStyle(fontWeight: FontWeight.bold),),
                              _compactTextField(hint: 'First Name', controller: _firstNameController),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 70,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("M.I.",
                              style: TextStyle(fontWeight: FontWeight.bold),),
                              _compactTextField(hint: 'M.I.', controller: _middleInitialController),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Email",
                              style: TextStyle(fontWeight: FontWeight.bold),),
                              _compactTextField(hint: 'Enter email', controller: _emailController),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Phone Number",
                              style: TextStyle(fontWeight: FontWeight.bold),),
                              _compactTextField(hint: 'Enter phone number', controller: _phoneController),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                      // Row: Role + Work Days + Time
                    // Row: Role + Schedule Staff + Time
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Role
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Role",
                              style: TextStyle(fontWeight: FontWeight.bold),),
                              DropdownButtonFormField<String>(
                                value: _userTypeController.text.isEmpty ? null : _userTypeController.text,
                                items: const [
                                  DropdownMenuItem(value: 'Staff', child: Text('Staff')),
                                  DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                                ],
                                onChanged: (value) => _userTypeController.text = value ?? '',
                                decoration: InputDecoration(
                                  hintText: 'Select Role',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Schedule Staff dropdown
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Work Schedule",
                              style: TextStyle(fontWeight: FontWeight.bold),),
                              DropdownButtonFormField<String>(
                                value: _scheduleController.text.isEmpty ? null : _scheduleController.text,
                                items: const [
                                  DropdownMenuItem(value: 'Mon-Fri', child: Text('Mon–Fri')),
                                  DropdownMenuItem(value: 'Weekends', child: Text('Weekends')),
                                  DropdownMenuItem(value: 'Whole Week', child: Text('Whole Week')),
                                  DropdownMenuItem(value: 'Custom', child: Text('Custom')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _scheduleController.text = value ?? '';

                                    if (value == 'Mon-Fri') {
                                      selectedDays.updateAll((day, _) =>
                                        ['Monday','Tuesday','Wednesday','Thursday','Friday'].contains(day));
                                    } else if (value == 'Weekends') {
                                      selectedDays.updateAll((day, _) =>
                                        ['Saturday','Sunday'].contains(day));
                                    } else if (value == 'Whole Week') {
                                      selectedDays.updateAll((day, _) => true);
                                    } else if (value == 'Custom') {
                                      selectedDays.updateAll((day, _) => false);
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Select Schedule',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Time From / To
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Time",
                              style: TextStyle(fontWeight: FontWeight.bold),),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _timeFromController,
                                      readOnly: true,
                                      decoration: const InputDecoration(hintText: 'From'),
                                      onTap: () async {
                                        final picked = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if (picked != null) {
                                          _timeFromController.text = picked.format(context);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _timeToController,
                                      readOnly: true,
                                      decoration: const InputDecoration(hintText: 'To'),
                                      onTap: () async {
                                        final picked = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if (picked != null) {
                                          _timeToController.text = picked.format(context);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (_scheduleController.text == 'Custom') ...[
                      const SizedBox(height: 20),
                      const Text("Work Days"),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: daysOfWeek.map((day) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: selectedDays[day],
                                onChanged: (bool? value) {
                                  setState(() {
                                    selectedDays[day] = value ?? false;
                                  });
                                },
                              ),
                              Text(day.substring(0, 3)), // Mon, Tue, Wed...
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                    ],
                  ),
                ),
              ),
            ),
              
            actionsAlignment: MainAxisAlignment.center, 
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    label: 'Cancel',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    width: 150,
                    height: 45,
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 20), // spacing between buttons
                  CustomButton(
                    label: 'Add Staff',
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    borderColor: Colors.green,
                    width: 150,
                    height: 45,
                    onPressed: () async {
                      setState(() {
                        staffList.add({
                          'id': 'STF-${(staffList.length + 1).toString().padLeft(3, '0')}',
                          'firstName': _firstNameController.text.trim(),
                          'middleInitial': _middleInitialController.text.trim(),
                          'lastName': _lastNameController.text.trim(),
                          'email': _emailController.text.trim().isEmpty
                              ? 'no-email@example.com'
                              : _emailController.text.trim(),
                          'phone': _phoneController.text.trim().isEmpty
                              ? 'N/A'
                              : _phoneController.text.trim(),
                          'userType': _userTypeController.text.trim().isEmpty
                              ? 'Staff'
                              : _userTypeController.text.trim(),
                          'workSchedule': _scheduleController.text.trim(),
                          'timeFrom': _timeFromController.text.trim(),
                          'timeTo': _timeToController.text.trim(),
                        });
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditForm(Map<String, dynamic> staff) {
  // Pre-fill controllers
  _idController.text = staff['id'] ?? '';
  _lastNameController.text = staff['lastName'] ?? '';
  _firstNameController.text = staff['firstName'] ?? '';
  _middleInitialController.text = staff['middleInitial'] ?? '';
  _emailController.text = staff['email'] ?? '';
  _phoneController.text = staff['phone'] ?? '';
  _userTypeController.text = staff['userType'] ?? '';
  _scheduleController.text = staff['workSchedule'] ?? '';
  _timeFromController.text = staff['timeFrom'] ?? '';
  _timeToController.text = staff['timeTo'] ?? '';

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.grey, width: 1.5),
          ),
          titlePadding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                child: Center(
                  child: Text(
                    'Edit Staff',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: SizedBox(
            width: 700,
            height: 300,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row: Staff ID + Last + First + MI
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Staff ID", style: TextStyle(fontWeight: FontWeight.bold)),
                              _compactTextField(hint: '0001', controller: _idController),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Last Name", style: TextStyle(fontWeight: FontWeight.bold)),
                              _compactTextField(hint: 'Last Name', controller: _lastNameController),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("First Name", style: TextStyle(fontWeight: FontWeight.bold)),
                              _compactTextField(hint: 'First Name', controller: _firstNameController),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 70,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("M.I.", style: TextStyle(fontWeight: FontWeight.bold)),
                              _compactTextField(hint: 'M.I.', controller: _middleInitialController),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Row: Email + Phone
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                              _compactTextField(hint: 'Enter email', controller: _emailController),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Phone Number", style: TextStyle(fontWeight: FontWeight.bold)),
                              _compactTextField(hint: 'Enter phone number', controller: _phoneController),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Row: Role + Schedule + Time
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Role
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Role", style: TextStyle(fontWeight: FontWeight.bold)),
                              DropdownButtonFormField<String>(
                                value: _userTypeController.text.isEmpty ? null : _userTypeController.text,
                                items: const [
                                  DropdownMenuItem(value: 'Staff', child: Text('Staff')),
                                  DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                                ],
                                onChanged: (value) => _userTypeController.text = value ?? '',
                                decoration: InputDecoration(
                                  hintText: 'Select Role',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Schedule Staff dropdown
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Schedule Staff", style: TextStyle(fontWeight: FontWeight.bold)),
                              DropdownButtonFormField<String>(
                                value: _scheduleController.text.isEmpty ? null : _scheduleController.text,
                                items: const [
                                  DropdownMenuItem(value: 'Mon-Fri', child: Text('Mon–Fri')),
                                  DropdownMenuItem(value: 'Weekends', child: Text('Weekends')),
                                  DropdownMenuItem(value: 'Whole Week', child: Text('Whole Week')),
                                  DropdownMenuItem(value: 'Custom', child: Text('Custom')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _scheduleController.text = value ?? '';
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Select Schedule',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Time From / To
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Time", style: TextStyle(fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _timeFromController,
                                      readOnly: true,
                                      decoration: const InputDecoration(hintText: 'From'),
                                      onTap: () async {
                                        final picked = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if (picked != null) {
                                          _timeFromController.text = picked.format(context);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _timeToController,
                                      readOnly: true,
                                      decoration: const InputDecoration(hintText: 'To'),
                                      onTap: () async {
                                        final picked = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if (picked != null) {
                                          _timeToController.text = picked.format(context);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  label: 'Cancel',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  borderColor: Colors.black,
                  width: 150,
                  height: 45,
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 20), // spacing between buttons
                CustomButton(
                  label: 'Save',
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  borderColor: Colors.green,
                  width: 150,
                  height: 45,
                  onPressed: () async {
                    setState(() {
                      staff['id'] = _idController.text.trim();
                      staff['firstName'] = _firstNameController.text.trim();
                      staff['middleInitial'] = _middleInitialController.text.trim();
                      staff['lastName'] = _lastNameController.text.trim();
                      staff['email'] = _emailController.text.trim();
                      staff['phone'] = _phoneController.text.trim();
                      staff['userType'] = _userTypeController.text.trim();

                      // ✅ schedule fields
                      staff['workSchedule'] = _scheduleController.text.trim();
                      staff['timeFrom'] = _timeFromController.text.trim();
                      staff['timeTo'] = _timeToController.text.trim();
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}

  void _showStaffDetails(Map<String, dynamic> staff) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.grey, width: 1.2),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Staff Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16), 
          ],
        ),
        content: SizedBox(
          width: 500,   // wider
          height: 400,  // shorter
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow("ID", staff['id'] ?? 'N/A'),
                _buildDetailRow("Name",
                    "${staff['lastName'] ?? ''}, ${staff['firstName'] ?? ''} ${staff['middleInitial'] ?? ''}"),
                _buildDetailRow("Email", staff['email'] ?? 'No email'),
                _buildDetailRow("Phone", staff['phone'] ?? 'N/A'),
                _buildDetailRow("Role", staff['userType'] ?? 'Staff'),
                _buildDetailRow("Status", staff['status'] ?? 'Unknown'),
                _buildDetailRow("Recent Activity", staff['activity'] ?? 'None'),
                _buildDetailRow("Total Hours", staff['hours']?.toString() ?? '0'),

                // ✅ Work Schedule
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12), 
                        child: const SizedBox(
                          width: 130,
                          child: Text(
                            "Work Schedule:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 100, maxWidth: 250),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(staff['workSchedule'] ?? 'Not set'),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text("From: ${staff['timeFrom'] ?? '--:--'}"),
                                  const SizedBox(width: 10),
                                  Text("To: ${staff['timeTo'] ?? '--:--'}"),
                                ],
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
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          CustomButton(
            label: 'Close',
            backgroundColor: Colors.black,
            textColor: Colors.white,
            borderColor: Colors.black,
            width: 100,
            height: 38,
            onPressed: () async {
              Navigator.pop(dialogContext);
            },
          ),
        ],
      );
    },
  );
}

// Helper widget for clean label-value rows
  Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12), 
          child: SizedBox(
            width: 130,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 6), // closer spacing to box
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 80, maxWidth: 250),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400, width: 1),
            ),
            child: Text(value),
          ),
        ),
      ],
    ),
  );
}
}
