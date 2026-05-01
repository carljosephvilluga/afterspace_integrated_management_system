import 'package:aims/widgets/common/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:aims/widgets/dialogs/confirm_deletion.dart';
import 'package:aims/widgets/common/custom_text_field.dart';

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
      'email': 'maria@example.com',
      'phone': '09987654321',
      'workSchedule': 'Weekends',
      'timeFrom': '09:00',
      'timeTo': '15:00',
    },
  ];

  int _staffCounter = 0;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleInitialController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _userTypeController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _scheduleController = TextEditingController();
  final TextEditingController _timeFromController = TextEditingController();
  final TextEditingController _timeToController = TextEditingController();

  String searchQuery = '';
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();

    // Initialize counter based on highest existing ID
    if (staffList.isNotEmpty) {
      // Find the highest numeric part among all IDs
      final highest = staffList
          .map((staff) => int.tryParse((staff['id'] as String).split('-').last) ?? 0)
          .reduce((a, b) => a > b ? a : b);

      _staffCounter = highest; // e.g. 2 if last ID is STF-002
    } else {
      _staffCounter = 0;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _firstNameController.dispose();
    _middleInitialController.dispose();
    _userTypeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _scheduleController.dispose();
    _lastNameController.dispose();
    _statusController.dispose();
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
      final phone = staff['phone'].toString().toLowerCase();
      final schedule = staff['workSchedule'].toString().toLowerCase();
      final matchesSearch =
          normalizedSearch.isEmpty ||
          fullName.contains(normalizedSearch) ||
          id.contains(normalizedSearch) ||
          email.contains(normalizedSearch) ||
          userType.contains(normalizedSearch) ||
          status.contains(normalizedSearch) ||
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
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionButton(
                label: 'View',
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

  String? selectedScheduleType; // nullable String

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

  Future<void> _showAddForm() async {
  _lastNameController.clear();
  _firstNameController.clear();
  _middleInitialController.clear();
  _emailController.clear();
  _phoneController.clear();
  _userTypeController.clear();
  _scheduleController.clear();
  _timeFromController.clear();
  _timeToController.clear();

  final newId = 'STF-${(_staffCounter + 1).toString().padLeft(3, '0')}';

  await showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.18),
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 900,
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: const Color(0xFFD1EEF2),
          borderRadius: BorderRadius.circular(9),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Staff Details",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text("Fill out the details to add a new staff member."),
              const SizedBox(height: 40),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: CustomTextField(
                                hint: "Last Name",
                                controller: _lastNameController,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 4,
                              child: CustomTextField(
                                hint: "First Name",
                                controller: _firstNameController,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 80,
                              child: CustomTextField(
                                hint: "M.I",
                                controller: _middleInitialController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hint: "staff@gmail.com",
                          controller: _emailController,
                        ),
                        const SizedBox(height: 20),
                        const Text("Phone Number", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hint: "09xxxxxxxxx",
                          controller: _phoneController,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 60),

                  // Right Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Staff ID", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 120,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  newId,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                "This is an Auto-generated Staff ID.",
                                style: TextStyle(color: Colors.grey, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const Text("Role", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _userTypeController.text.isEmpty ? null : _userTypeController.text,
                          hint: const Text("Select role"),
                          items: const [
                            DropdownMenuItem(value: 'Staff', child: Text('Staff')),
                            DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                            DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                          ],
                          onChanged: (value) => _userTypeController.text = value ?? '',
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 30),
                        const Text("Work Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          hint: const Text("Select schedule"),
                          items: const [
                            DropdownMenuItem(value: 'Mon-Fri', child: Text('Mon–Fri')),
                            DropdownMenuItem(value: 'Weekends', child: Text('Weekends')),
                            DropdownMenuItem(value: 'Whole Week', child: Text('Whole Week')),
                            DropdownMenuItem(value: 'Flexible', child: Text('Flexible')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedScheduleType = value;
                              _scheduleController.text = selectedScheduleType ?? '';
                            });
                          },
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Time Section (full width, below both columns)
              const Text("Time", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _timeFromController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "From",
                        border: OutlineInputBorder(),
                      ),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _timeToController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "To",
                        border: OutlineInputBorder(),
                      ),
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
              const SizedBox(height: 8),
              const Text(
                "Specify the working hours (From / To).",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    label: "Cancel",
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    borderColor: Colors.black,
                    width: 200,
                    height: 50,
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 20),
                  CustomButton(
                    label: "Add Staff",
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    width: 200,
                    height: 50,
                    onPressed: () async {
                      setState(() {
                        _staffCounter++; // increment only when saving
                        final newId = 'STF-${_staffCounter.toString().padLeft(3, '0')}';

                        staffList.add({
                          'id': newId,
                          'firstName': _firstNameController.text.trim(),
                          'middleInitial': _middleInitialController.text.trim(),
                          'lastName': _lastNameController.text.trim(),
                          'email': _emailController.text.trim(),
                          'phone': _phoneController.text.trim(),
                          'userType': _userTypeController.text.trim().isEmpty
                              ? 'Staff'
                              : _userTypeController.text.trim(),
                          'workSchedule': _scheduleController.text.trim(),
                          'timeFrom': _timeFromController.text.trim(),
                          'timeTo': _timeToController.text.trim(),
                          'status': 'On Duty',
                        });
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  void _showEditForm(Map<String, dynamic> staff) {
  // Pre-fill controllers
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
    barrierColor: Colors.black.withOpacity(0.18),
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 720,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Centered Header
              Center(
                child: Text(
                  "Edit Staff",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Staff ID (read-only)
              const Text("Staff ID", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: staff['id'],
                readOnly: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),

              // Name fields row
              const Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      hint: "Last Name",
                      controller: _lastNameController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      hint: "First Name",
                      controller: _firstNameController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 80,
                    child: CustomTextField(
                      hint: "M.I",
                      controller: _middleInitialController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              CustomTextField(hint: "staff@gmail.com", controller: _emailController),
              const SizedBox(height: 20),

              const Text("Phone Number", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              CustomTextField(hint: "09xxxxxxxxx", controller: _phoneController),
              const SizedBox(height: 24),

              const Text("Role", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _userTypeController.text.isEmpty ? null : _userTypeController.text,
                items: const [
                  DropdownMenuItem(value: 'Staff', child: Text('Staff')),
                  DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                ],
                onChanged: (value) => _userTypeController.text = value ?? '',
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),

              const Text("Work Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _scheduleController.text.isEmpty ? null : _scheduleController.text,
                items: const [
                  DropdownMenuItem(value: 'Mon-Fri', child: Text('Mon–Fri')),
                  DropdownMenuItem(value: 'Weekends', child: Text('Weekends')),
                  DropdownMenuItem(value: 'Whole Week', child: Text('Whole Week')),
                  DropdownMenuItem(value: 'Flexible', child: Text('Flexible')),
                ],
                onChanged: (value) => _scheduleController.text = value ?? '',
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),

              // Time Section
              const Text("Time", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _timeFromController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "From",
                        border: OutlineInputBorder(),
                      ),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _timeToController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "To",
                        border: OutlineInputBorder(),
                      ),
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
              const SizedBox(height: 8),
              const Text(
                "Specify the working hours (From / To).",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 32),

              // Centered Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    label: "Cancel",
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    borderColor: Colors.black,
                    width: 140,
                    height: 42,
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 20),
                  CustomButton(
                    label: "Save Changes",
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    width: 160,
                    height: 42,
                    onPressed: () async {
                      setState(() {
                        staff['lastName'] = _lastNameController.text.trim();
                        staff['firstName'] = _firstNameController.text.trim();
                        staff['middleInitial'] = _middleInitialController.text.trim();
                        staff['email'] = _emailController.text.trim();
                        staff['phone'] = _phoneController.text.trim();
                        staff['userType'] = _userTypeController.text.trim();
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
          ),
        ),
      ),
    ),
  );
}

  void _showStaffDetails(Map<String, dynamic> staff) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.18),
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Centered Title
            Center(
              child: Text(
                "Staff Details",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Indented details block
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40), // move inward
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Staff ID:", staff['id']),
                  _buildDetailRow("Full Name:",
                      "${staff['lastName']} ${staff['firstName']} ${staff['middleInitial']}"),
                  _buildDetailRow("Email:", staff['email']),
                  _buildDetailRow("Phone Number:", staff['phone']),
                  _buildDetailRow("Role:", staff['userType']),
                  _buildDetailRow("Status:", staff['status']),
                  _buildDetailRow("Work Schedule:", staff['workSchedule']),
                  _buildDetailRow("Time:",
                      "${staff['timeFrom']} - ${staff['timeTo']}"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Close button aligned bottom-right
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  label: "Close",
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  borderColor: Colors.black,
                  width: 120,
                  height: 42,
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// Helper widget for consistent detail rows
Widget _buildDetailRow(String label, String? value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Label
        SizedBox(
          width: 140, // consistent width for labels
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 12), // spacing between label and box
        // Value box
        Container(
          constraints: const BoxConstraints(maxWidth: 280), // shorter box
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FBFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E6EB)),
          ),
          child: Text(
            value ?? '',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
}
