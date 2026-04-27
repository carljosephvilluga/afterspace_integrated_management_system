import 'package:aims/widgets/common/custom_button.dart';
import 'package:aims/widgets/common/custom_text_field.dart';
import 'package:flutter/material.dart';

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
      'schedule': '2026-04-27 08:00 - 17:00',
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
      'schedule': '2026-04-27 09:00 - 15:00',
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
                onPressed: () => setState(() => staffList.remove(staff)),
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
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: const EdgeInsets.only(top: 12, left: 16, right: 8),
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
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Staff ID"),
                        const SizedBox(height: 4),
                        CustomTextField(hint: '0001', controller: _idController),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Name"),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(child: CustomTextField(hint: 'First', controller: _firstNameController)),
                            const SizedBox(width: 8),
                            SizedBox(width: 60, child: CustomTextField(hint: 'M.I.', controller: _middleInitialController)),
                            const SizedBox(width: 8),
                            Expanded(child: CustomTextField(hint: 'Last', controller: _lastNameController)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row 2: Email + Phone
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Email"),
                        const SizedBox(height: 4),
                        CustomTextField(hint: 'Enter email', controller: _emailController),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Phone Number"),
                        const SizedBox(height: 4),
                        CustomTextField(hint: 'Enter phone number', controller: _phoneController),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row 3: Role + Schedule + Time
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Role"),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: 'Staff',
                          items: const [
                            DropdownMenuItem(value: 'Staff', child: Text('Staff')),
                            DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                            DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                          ],
                          onChanged: (value) {
                            _userTypeController.text = value ?? '';
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Schedule Staff"),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _scheduleController,
                          decoration: InputDecoration(
                            hintText: 'Select date',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Time"),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(child: CustomTextField(hint: 'From', controller: _statusController)),
                            const SizedBox(width: 8),
                            Expanded(child: CustomTextField(hint: 'To', controller: _activityController)),
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
      actionsAlignment: MainAxisAlignment.center,
                
        actions: [
          CustomButton(
            label: 'Add Staff',
            backgroundColor: Colors.green,
            textColor: Colors.white,
            borderColor: Colors.green,
            width: 160,
            height: 50,
            onPressed: () async {
              setState(() {
                staffList.add({
                  'id':
                      'STF-${(staffList.length + 1).toString().padLeft(3, '0')}',
                  'firstName': _firstNameController.text.trim(),
                  'middleInitial': _middleInitialController.text.trim(),
                  'lastName': _lastNameController.text.trim(),
                  'email': 'no-email@example.com',
                  'phone': 'N/A',
                  'userType': 'Staff',
                  'schedule': _scheduleController.text.trim(),
                });
              });
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showEditForm(Map<String, dynamic> staff) {
    _idController.text = staff['id'];
    _lastNameController.text = staff['lastName'];
    _firstNameController.text = staff['firstName'];
    _middleInitialController.text = staff['middleInitial'];
    _userTypeController.text = staff['role'];
    _statusController.text = staff['status'];
    _activityController.text = staff['activity'];
    _hoursController.text = staff['hours'];
    _emailController.text = staff['email'];
    _phoneController.text = staff['phone'];
    _scheduleController.text = staff['schedule'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Staff'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(hint: 'Staff ID', controller: _idController),
                CustomTextField(hint: 'Last Name', controller: _lastNameController),
                CustomTextField(hint: 'First Name', controller: _firstNameController),
                CustomTextField(hint: 'Middle Initial', controller: _middleInitialController),
                CustomTextField(hint: 'Email', controller: _emailController),
                CustomTextField(hint: 'Phone Number', controller: _phoneController),
                CustomTextField(hint: 'Type', controller: _userTypeController),
                CustomTextField(hint: 'Status', controller: _statusController),
                CustomTextField(hint: 'Recent Activity', controller: _activityController),
                CustomTextField(hint: 'Total Hours', controller: _hoursController),
                CustomTextField(hint: 'Work Schedule', controller: _scheduleController),
            ],
          ),
        ),
        actions: [
          CustomButton(
            label: 'Cancel',
            backgroundColor: Colors.white,
            textColor: Colors.black,
            borderColor: Colors.black,
            width: 100,
            height: 40,
            onPressed: () async => Navigator.pop(context),
          ),
          CustomButton(
            label: 'Update',
            backgroundColor: Colors.black,
            textColor: Colors.white,
            borderColor: Colors.black,
            width: 100,
            height: 40,
            onPressed: () async {
              setState(() {
                staff['id'] = _idController.text;
                staff['lastName'] = _lastNameController.text;
                staff['firstName'] = _firstNameController.text;
                staff['middleInitial'] = _middleInitialController.text;
                staff['role'] = _userTypeController.text;
                staff['status'] = _statusController.text;
                staff['activity'] = _activityController.text;
                staff['hours'] = _hoursController.text;
                staff['email'] = _emailController.text;
                staff['phone'] = _phoneController.text;
                staff['schedule'] = _scheduleController.text;
              });
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showStaffDetails(Map<String, dynamic> staff) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Staff Details - ${staff['lastName']}, ${staff['firstName']} ${staff['middleInitial']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${staff['id']}'),
              Text('Name: ${staff['lastName']}, ${staff['firstName']} ${staff['middleInitial']}'),
              Text('Email: ${staff['email']}'),
              Text('Phone: ${staff['phone']}'),
              Text('Role: ${staff['role']}'),
              Text('Status: ${staff['status']}'),
              Text('Recent Activity: ${staff['activity']}'),
              Text('Total Hours: ${staff['hours']}'),
              Text('Work Schedule: ${staff['schedule']}'),
          ],
        ),
        actions: [
          CustomButton(
            label: 'Close',
            backgroundColor: Colors.black,
            textColor: Colors.white,
            borderColor: Colors.black,
            width: 100,
            height: 40,
            onPressed: () async => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
