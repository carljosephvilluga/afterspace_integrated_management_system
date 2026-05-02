import 'package:aims/widgets/common/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:aims/widgets/dialogs/confirm_deletion.dart';
import 'package:aims/widgets/common/custom_text_field.dart';
import 'package:aims/widgets/membership_loyalty_widgets/membership_program_action_button.dart';
import 'package:aims/widgets/membership_loyalty_widgets/membership_program_section.dart';
import 'package:aims/widgets/membership_loyalty_widgets/membership_program_table.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  static const Color _pageBackground = Color(0xFFDDECEF);
  static const Color _panelBlue = Color(0xFFCDECF3);
  static const Color _headerBlue = Color(0xFF80AEC1);
  static const Color _tan = Color(0xFFD7B59E);
  static const Color _tanSoft = Color(0xFFEBD9CA);
  static const Color _cardWhite = Color(0xF7FFFFFF);
  static const Color _danger = Color(0xFFC95656);
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF6F7E87);

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
      'workSchedule': 'Mon-Fri',
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
  final TextEditingController _middleInitialController =
      TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _userTypeController = TextEditingController();
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
          .map(
            (staff) =>
                int.tryParse((staff['id'] as String).split('-').last) ?? 0,
          )
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackedControls = constraints.maxWidth < 820;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildPageHero(),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildInfoChip(
                      label: 'Total Staff',
                      value: '${staffList.length}',
                    ),
                    _buildInfoChip(
                      label: 'On Duty',
                      value: '${_countByStatus('On Duty')}',
                    ),
                    _buildInfoChip(
                      label: 'Off Duty',
                      value: '${_countByStatus('Off Duty')}',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (stackedControls)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSearchField(),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildFilterDropdown(),
                          MembershipProgramActionButton(
                            label: 'Add Staff',
                            backgroundColor: _tanSoft,
                            textColor: _textPrimary,
                            icon: Icons.person_add_alt_1_rounded,
                            onPressed: _showAddForm,
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(child: _buildSearchField()),
                      const SizedBox(width: 12),
                      _buildFilterDropdown(),
                      const SizedBox(width: 16),
                      MembershipProgramActionButton(
                        label: 'Add Staff',
                        backgroundColor: _tanSoft,
                        textColor: _textPrimary,
                        icon: Icons.person_add_alt_1_rounded,
                        onPressed: _showAddForm,
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                _buildStaffDirectorySection(filteredStaff),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _filteredStaff() {
    final normalizedSearch = searchQuery.trim().toLowerCase();

    return staffList.where((staff) {
      final fullName =
          "${staff['firstName'] ?? ''} ${staff['middleInitial'] ?? ''} ${staff['lastName'] ?? ''}"
              .toLowerCase();

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

  Widget _buildPageHero() {
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
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _panelBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.manage_accounts_outlined,
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
                  'Manage Staff',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Track staff profiles, schedules, roles, and duty status for admin operations.',
                  style: TextStyle(
                    fontSize: 14,
                    color: _textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
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
                color: _textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _countByStatus(String status) {
    return staffList.where((staff) => staff['status'] == status).length;
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        style: const TextStyle(
          color: _textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Search staff by name, ID, role, phone, or email',
          hintStyle: const TextStyle(
            color: _textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.search, color: _headerBlue),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.72),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.85)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.85)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _headerBlue),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _tanSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x2A23323A)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFilter,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          items: const [
            DropdownMenuItem(value: 'All', child: Text('All Staff')),
            DropdownMenuItem(value: 'On Duty', child: Text('On Duty')),
            DropdownMenuItem(value: 'Off Duty', child: Text('Off Duty')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              selectedFilter = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildStaffDirectorySection(List<Map<String, dynamic>> filteredStaff) {
    return MembershipProgramSection(
      title: 'Staff Directory',
      subtitle:
          'Review assigned roles, schedules, contact details, and duty status.',
      backgroundColor: _panelBlue,
      textColor: _textPrimary,
      child: filteredStaff.isEmpty
          ? _buildEmptyState()
          : MembershipProgramTable(
              headers: const [
                'Staff',
                'Role',
                'Contact',
                'Schedule',
                'Status',
                '',
              ],
              flexes: const [3, 2, 3, 3, 2, 3],
              rows: filteredStaff.map((staff) {
                return [
                  '${staff['firstName'] ?? ''} ${staff['middleInitial'] ?? ''} ${staff['lastName'] ?? ''}\n${staff['id'] ?? ''}',
                  '${staff['userType'] ?? ''}',
                  '${staff['email'] ?? ''}\n${staff['phone'] ?? ''}',
                  '${staff['workSchedule'] ?? ''}\n${staff['timeFrom'] ?? ''} - ${staff['timeTo'] ?? ''}',
                  '${staff['status'] ?? ''}',
                  'View    Edit    Delete',
                ];
              }).toList(),
              headerColor: _tan,
              primaryTextColor: _textPrimary,
              actionTextColor: _headerBlue,
              actionColumnIndex: 5,
              actionBuilder: (rowIndex) =>
                  _buildStaffTableActions(filteredStaff[rowIndex]),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 42),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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

  Widget _buildStaffTableActions(Map<String, dynamic> staff) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 8,
      runSpacing: 6,
      children: [
        _buildStaffActionPill(
          label: 'View',
          color: _headerBlue,
          onTap: () => _showStaffDetails(staff),
        ),
        _buildStaffActionPill(
          label: 'Edit',
          color: _headerBlue,
          onTap: () => _showEditForm(staff),
        ),
        _buildStaffActionPill(
          label: 'Delete',
          color: _danger,
          backgroundColor: const Color(0xFFFBEAEA),
          borderColor: const Color(0xFFF3C7C7),
          onTap: () => _confirmDeleteStaff(staff),
        ),
      ],
    );
  }

  Widget _buildStaffActionPill({
    required String label,
    required Color color,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: borderColor ?? Colors.white.withValues(alpha: 0.95),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }

  void _confirmDeleteStaff(Map<String, dynamic> staff) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (_) => ConfirmDeleteDialog(
        staff: staff,
        onDelete: () {
          setState(() {
            staffList.remove(staff);
          });
        },
      ),
    );
  }

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
      barrierColor: Colors.black.withValues(alpha: 0.18),
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
                          const Text(
                            "Name",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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
                          const Text(
                            "Email",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            hint: "staff@gmail.com",
                            controller: _emailController,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Phone Number",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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
                          const Text(
                            "Staff ID",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 120,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
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
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Role",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _userTypeController.text.isEmpty
                                ? null
                                : _userTypeController.text,
                            hint: const Text("Select role"),
                            items: const [
                              DropdownMenuItem(
                                value: 'Staff',
                                child: Text('Staff'),
                              ),
                              DropdownMenuItem(
                                value: 'Manager',
                                child: Text('Manager'),
                              ),
                              DropdownMenuItem(
                                value: 'Admin',
                                child: Text('Admin'),
                              ),
                            ],
                            onChanged: (value) =>
                                _userTypeController.text = value ?? '',
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Work Schedule",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            hint: const Text("Select schedule"),
                            items: const [
                              DropdownMenuItem(
                                value: 'Mon-Fri',
                                child: Text('Mon-Fri'),
                              ),
                              DropdownMenuItem(
                                value: 'Weekends',
                                child: Text('Weekends'),
                              ),
                              DropdownMenuItem(
                                value: 'Whole Week',
                                child: Text('Whole Week'),
                              ),
                              DropdownMenuItem(
                                value: 'Flexible',
                                child: Text('Flexible'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _scheduleController.text = value ?? '';
                              });
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Time Section (full width, below both columns)
                const Text(
                  "Time",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
                            if (!mounted) return;
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
                            if (!mounted) return;
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
                          final newId =
                              'STF-${_staffCounter.toString().padLeft(3, '0')}';

                          staffList.add({
                            'id': newId,
                            'firstName': _firstNameController.text.trim(),
                            'middleInitial': _middleInitialController.text
                                .trim(),
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
      barrierColor: Colors.black.withValues(alpha: 0.18),
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
                const Text(
                  "Staff ID",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  initialValue: staff['id'],
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Name fields row
                const Text(
                  "Name",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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

                const Text(
                  "Email",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                CustomTextField(
                  hint: "staff@gmail.com",
                  controller: _emailController,
                ),
                const SizedBox(height: 20),

                const Text(
                  "Phone Number",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                CustomTextField(
                  hint: "09xxxxxxxxx",
                  controller: _phoneController,
                ),
                const SizedBox(height: 24),

                const Text(
                  "Role",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _userTypeController.text.isEmpty
                      ? null
                      : _userTypeController.text,
                  items: const [
                    DropdownMenuItem(value: 'Staff', child: Text('Staff')),
                    DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                    DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  ],
                  onChanged: (value) => _userTypeController.text = value ?? '',
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "Work Schedule",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _scheduleController.text.isEmpty
                      ? null
                      : _scheduleController.text,
                  items: const [
                    DropdownMenuItem(value: 'Mon-Fri', child: Text('Mon-Fri')),
                    DropdownMenuItem(
                      value: 'Weekends',
                      child: Text('Weekends'),
                    ),
                    DropdownMenuItem(
                      value: 'Whole Week',
                      child: Text('Whole Week'),
                    ),
                    DropdownMenuItem(
                      value: 'Flexible',
                      child: Text('Flexible'),
                    ),
                  ],
                  onChanged: (value) => _scheduleController.text = value ?? '',
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Time Section
                const Text(
                  "Time",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
                            if (!mounted) return;
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
                            if (!mounted) return;
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
                          staff['middleInitial'] = _middleInitialController.text
                              .trim();
                          staff['email'] = _emailController.text.trim();
                          staff['phone'] = _phoneController.text.trim();
                          staff['userType'] = _userTypeController.text.trim();
                          staff['workSchedule'] = _scheduleController.text
                              .trim();
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
      barrierColor: Colors.black.withValues(alpha: 0.18),
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
                padding: const EdgeInsets.only(
                  left: 40,
                  right: 40,
                ), // move inward
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow("Staff ID:", staff['id']),
                    _buildDetailRow(
                      "Full Name:",
                      "${staff['lastName']} ${staff['firstName']} ${staff['middleInitial']}",
                    ),
                    _buildDetailRow("Email:", staff['email']),
                    _buildDetailRow("Phone Number:", staff['phone']),
                    _buildDetailRow("Role:", staff['userType']),
                    _buildDetailRow("Status:", staff['status']),
                    _buildDetailRow("Work Schedule:", staff['workSchedule']),
                    _buildDetailRow(
                      "Time:",
                      "${staff['timeFrom']} - ${staff['timeTo']}",
                    ),
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
