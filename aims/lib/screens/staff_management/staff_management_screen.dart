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
      'name': 'Juan Dela Cruz',
      'email': 'juan.delacruz@example.com',
      'phone': '09171234567',
      'userType': 'Staff',
      'membership': 'N/A',
      'activity': 'Checked in',
      'status': 'On Duty',
      'hours': '8',
    },
    {
      'id': 'STF-002',
      'name': 'Maria Santos',
      'email': 'maria.santos@example.com',
      'phone': '09987654321',
      'userType': 'Staff',
      'membership': 'N/A',
      'activity': 'Break',
      'status': 'Off Duty',
      'hours': '6',
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();

  String searchQuery = '';
  String selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
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
      final name = staff['name'].toString().toLowerCase();
      final id = staff['id'].toString().toLowerCase();
      final email = staff['email'].toString().toLowerCase();
      final matchesSearch =
          normalizedSearch.isEmpty ||
          name.contains(normalizedSearch) ||
          id.contains(normalizedSearch) ||
          email.contains(normalizedSearch);
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
                      staff['name'],
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
              _buildInfoTag('Activity: ${staff['activity']}'),
              _buildInfoTag('Hours: ${staff['hours']}'),
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
    _nameController.clear();
    _statusController.text = 'On Duty';
    _hoursController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Staff'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                hint: 'Enter full name',
                controller: _nameController,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'On Duty / Off Duty',
                controller: _statusController,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'Enter working hours',
                controller: _hoursController,
              ),
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
            label: 'Save',
            backgroundColor: Colors.black,
            textColor: Colors.white,
            borderColor: Colors.black,
            width: 100,
            height: 40,
            onPressed: () async {
              setState(() {
                staffList.add({
                  'id':
                      'STF-${(staffList.length + 1).toString().padLeft(3, '0')}',
                  'name': _nameController.text.trim(),
                  'email': 'no-email@example.com',
                  'phone': 'N/A',
                  'userType': 'Staff',
                  'membership': 'N/A',
                  'activity': 'New',
                  'status': _statusController.text.trim(),
                  'hours': _hoursController.text.trim(),
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
    _nameController.text = staff['name'];
    _statusController.text = staff['status'];
    _hoursController.text = staff['hours'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Staff'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                hint: 'Enter full name',
                controller: _nameController,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'On Duty / Off Duty',
                controller: _statusController,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                hint: 'Enter working hours',
                controller: _hoursController,
              ),
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
                staff['name'] = _nameController.text.trim();
                staff['status'] = _statusController.text.trim();
                staff['hours'] = _hoursController.text.trim();
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
        title: Text('Staff Details - ${staff['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${staff['id']}'),
            Text('Email: ${staff['email']}'),
            Text('Phone: ${staff['phone']}'),
            Text('Activity: ${staff['activity']}'),
            Text('Status: ${staff['status']}'),
            Text('Hours: ${staff['hours']}'),
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
