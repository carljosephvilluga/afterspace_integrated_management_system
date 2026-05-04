import 'package:aims/services/aims_api_client.dart';
import 'package:flutter/material.dart';
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

  final List<Map<String, dynamic>> staffList = [];

  bool _isLoadingStaff = false;
  String? _staffLoadError;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleInitialController =
      TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _userTypeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  String searchQuery = '';
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _statusController.text = 'Active';
    _loadStaffAccounts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _firstNameController.dispose();
    _middleInitialController.dispose();
    _userTypeController.dispose();
    _emailController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _statusController.dispose();
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
                      label: 'Active',
                      value: '${_countByStatus('Active')}',
                    ),
                    _buildInfoChip(
                      label: 'Inactive',
                      value: '${_countByStatus('Inactive')}',
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

  Future<void> _loadStaffAccounts() async {
    setState(() {
      _isLoadingStaff = true;
      _staffLoadError = null;
    });

    try {
      final accounts = await AimsApiClient.instance.fetchStaffAccounts();
      if (!mounted) return;
      setState(() {
        staffList
          ..clear()
          ..addAll(accounts.map(_staffAccountToMap));
        _isLoadingStaff = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _staffLoadError = error.toString();
        _isLoadingStaff = false;
      });
    }
  }

  Map<String, dynamic> _staffAccountToMap(StaffAccountRecord account) {
    final nameParts = _splitFullName(account.fullName);
    return {
      'staffId': account.staffId,
      'id': account.employeeId,
      'fullName': account.fullName,
      'firstName': nameParts.$1,
      'middleInitial': '',
      'lastName': nameParts.$2,
      'userType': account.role,
      'status': account.status,
      'email': account.email,
      'createdAt': _formatDate(account.createdAt),
    };
  }

  (String, String) _splitFullName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) {
      return (fullName.trim(), '');
    }
    return (parts.first, parts.skip(1).join(' '));
  }

  List<Map<String, dynamic>> _filteredStaff() {
    final normalizedSearch = searchQuery.trim().toLowerCase();

    return staffList.where((staff) {
      final fullName = _displayName(staff).toLowerCase();

      final id = staff['id'].toString().toLowerCase();
      final email = staff['email'].toString().toLowerCase();
      final userType = staff['userType'].toString().toLowerCase();
      final status = staff['status'].toString().toLowerCase();
      final matchesSearch =
          normalizedSearch.isEmpty ||
          fullName.contains(normalizedSearch) ||
          id.contains(normalizedSearch) ||
          email.contains(normalizedSearch) ||
          userType.contains(normalizedSearch) ||
          status.contains(normalizedSearch);
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
                  'Manage staff login accounts, roles, and active access for admin operations.',
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
          hintText: 'Search staff by name, employee ID, role, status, or email',
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
            DropdownMenuItem(value: 'Active', child: Text('Active')),
            DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
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
      subtitle: 'Review login accounts, roles, status, and contact details.',
      backgroundColor: _panelBlue,
      textColor: _textPrimary,
      child: _isLoadingStaff
          ? _buildLoadingState()
          : _staffLoadError != null
          ? _buildLoadError()
          : filteredStaff.isEmpty
          ? _buildEmptyState()
          : LayoutBuilder(
              builder: (context, constraints) {
                final tableWidth = constraints.maxWidth < 960
                    ? 960.0
                    : constraints.maxWidth;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: MembershipProgramTable(
                      headers: const [
                        'Staff Account',
                        'Role',
                        'Email',
                        'Status',
                        'Created',
                        '',
                      ],
                      flexes: const [3, 2, 3, 2, 2, 3],
                      rows: filteredStaff.map((staff) {
                        return [
                          '${_displayName(staff)}\n${staff['id'] ?? ''}',
                          '${staff['userType'] ?? ''}',
                          '${staff['email'] ?? ''}',
                          '${staff['status'] ?? ''}',
                          '${staff['createdAt'] ?? ''}',
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
                  ),
                );
              },
            ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 44),
      child: Center(child: CircularProgressIndicator(color: _headerBlue)),
    );
  }

  Widget _buildLoadError() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 42, color: _textMuted),
          const SizedBox(height: 10),
          const Text(
            'Unable to load staff accounts',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _staffLoadError ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _textMuted),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _loadStaffAccounts,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
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

  Future<void> _confirmDeleteStaff(Map<String, dynamic> staff) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('Delete Staff Account'),
          content: Text(
            'Delete ${_displayName(staff)} (${staff['id']})? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _danger,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final staffId = staff['staffId'] is int ? staff['staffId'] as int : 0;
    if (staffId <= 0) {
      _showSnackBar('Missing staff account ID.', isError: true);
      return;
    }

    try {
      await AimsApiClient.instance.deleteStaffAccount(staffId);
      if (!mounted) return;
      setState(() {
        staffList.removeWhere((item) => item['staffId'] == staffId);
      });
      _showSnackBar('Staff account deleted.');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('Failed to delete staff account: $error', isError: true);
    }
  }

  Future<void> _showAddForm() async {
    if (!_isLoadingStaff) {
      await _loadStaffAccounts();
    }
    _clearStaffForm();
    await _showStaffAccountForm();
  }

  void _showEditForm(Map<String, dynamic> staff) {
    _setFormFromStaff(staff);
    _showStaffAccountForm(staff: staff);
  }

  Future<void> _showStaffAccountForm({Map<String, dynamic>? staff}) async {
    final isEditing = staff != null;
    final formKey = GlobalKey<FormState>();
    var selectedRole = _userTypeController.text.isEmpty
        ? 'Staff'
        : _userTypeController.text;
    var selectedStatus = _statusController.text.isEmpty
        ? 'Active'
        : _statusController.text;
    var employeeId = isEditing
        ? '${staff['id'] ?? ''}'
        : _buildNextEmployeeId(selectedRole);
    var obscurePassword = true;
    var isSaving = false;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> saveAccount() async {
              if (isSaving || !(formKey.currentState?.validate() ?? false)) {
                return;
              }

              setDialogState(() {
                isSaving = true;
              });

              try {
                final navigator = Navigator.of(dialogContext);
                final fullName = _buildFullNameFromForm();
                final account = isEditing
                    ? await AimsApiClient.instance.updateStaffAccount(
                        staffId: staff['staffId'] as int,
                        employeeId: employeeId,
                        fullName: fullName,
                        email: _emailController.text.trim(),
                        role: selectedRole,
                        status: selectedStatus,
                        password: _passwordController.text.trim(),
                      )
                    : await AimsApiClient.instance.createStaffAccount(
                        employeeId: employeeId,
                        fullName: fullName,
                        email: _emailController.text.trim(),
                        role: selectedRole,
                        status: selectedStatus,
                        password: _passwordController.text.trim(),
                      );

                if (!mounted) return;
                setState(() {
                  final mapped = _staffAccountToMap(account);
                  if (isEditing) {
                    final index = staffList.indexWhere(
                      (item) => item['staffId'] == account.staffId,
                    );
                    if (index >= 0) {
                      staffList[index] = mapped;
                    }
                  } else {
                    staffList.insert(0, mapped);
                  }
                });
                navigator.pop();
                _showSnackBar(
                  isEditing
                      ? 'Staff account updated.'
                      : 'Staff account created.',
                );
              } catch (error) {
                if (!mounted) return;
                setDialogState(() {
                  isSaving = false;
                });
                _showSnackBar(
                  'Failed to save staff account: $error',
                  isError: true,
                );
              }
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                  decoration: BoxDecoration(
                    color: _cardWhite,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 28,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: _panelBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.manage_accounts_outlined,
                                  color: _headerBlue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isEditing
                                      ? 'Edit Staff Account'
                                      : 'Add Staff Account',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: _textPrimary,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Close',
                                onPressed: isSaving
                                    ? null
                                    : () => Navigator.of(dialogContext).pop(),
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final stacked = constraints.maxWidth < 620;
                              final fieldWidth = stacked
                                  ? constraints.maxWidth
                                  : (constraints.maxWidth - 12) / 2;

                              return Wrap(
                                spacing: 12,
                                runSpacing: 14,
                                children: [
                                  SizedBox(
                                    width: fieldWidth,
                                    child: _buildReadOnlyField(
                                      label: 'Employee ID',
                                      value: employeeId,
                                    ),
                                  ),
                                  SizedBox(
                                    width: fieldWidth,
                                    child: _buildDropdownField(
                                      label: 'Role',
                                      value: selectedRole,
                                      items: const [
                                        'Staff',
                                        'Manager',
                                        'Admin',
                                      ],
                                      onChanged: (value) {
                                        if (value == null) return;
                                        setDialogState(() {
                                          selectedRole = value;
                                          _userTypeController.text = value;
                                          if (!isEditing) {
                                            employeeId = _buildNextEmployeeId(
                                              value,
                                            );
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: fieldWidth,
                                    child: _buildDialogTextField(
                                      label: 'First Name',
                                      controller: _firstNameController,
                                      validator: _requiredValidator,
                                    ),
                                  ),
                                  SizedBox(
                                    width: fieldWidth,
                                    child: _buildDialogTextField(
                                      label: 'Last Name',
                                      controller: _lastNameController,
                                      validator: _requiredValidator,
                                    ),
                                  ),
                                  SizedBox(
                                    width: fieldWidth,
                                    child: _buildDialogTextField(
                                      label: 'Middle Initial',
                                      controller: _middleInitialController,
                                    ),
                                  ),
                                  SizedBox(
                                    width: fieldWidth,
                                    child: _buildDropdownField(
                                      label: 'Status',
                                      value: selectedStatus,
                                      items: const ['Active', 'Inactive'],
                                      onChanged: (value) {
                                        if (value == null) return;
                                        setDialogState(() {
                                          selectedStatus = value;
                                          _statusController.text = value;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: fieldWidth,
                                    child: _buildDialogTextField(
                                      label: 'Email',
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: _emailValidator,
                                    ),
                                  ),
                                  SizedBox(
                                    width: fieldWidth,
                                    child: _buildDialogTextField(
                                      label: isEditing
                                          ? 'New Password'
                                          : 'Password',
                                      hint: isEditing
                                          ? 'Leave blank to keep current'
                                          : 'Minimum 6 characters',
                                      controller: _passwordController,
                                      obscureText: obscurePassword,
                                      validator: (value) =>
                                          _passwordValidator(value, isEditing),
                                      suffixIcon: IconButton(
                                        tooltip: obscurePassword
                                            ? 'Show password'
                                            : 'Hide password',
                                        icon: Icon(
                                          obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                        onPressed: () {
                                          setDialogState(() {
                                            obscurePassword = !obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              OutlinedButton(
                                onPressed: isSaving
                                    ? null
                                    : () => Navigator.of(dialogContext).pop(),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: isSaving ? null : saveAccount,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _textPrimary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 16,
                                  ),
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        isEditing
                                            ? 'Save Changes'
                                            : 'Add Staff',
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
            );
          },
        );
      },
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
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Staff Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildDetailRow('Employee ID', staff['id']),
              _buildDetailRow('Full Name', _displayName(staff)),
              _buildDetailRow('Email', staff['email']),
              _buildDetailRow('Role', staff['userType']),
              _buildDetailRow('Status', staff['status']),
              _buildDetailRow('Created', staff['createdAt']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: _textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE0E6EB)),
              ),
              child: Text(
                value ?? '',
                style: const TextStyle(fontSize: 13, color: _textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
      decoration: _dialogInputDecoration(
        label: label,
        hint: hint,
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: _textPrimary,
      ),
      decoration: _dialogInputDecoration(label: label),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: items.contains(value) ? value : items.first,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      decoration: _dialogInputDecoration(label: label),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
      ),
    );
  }

  InputDecoration _dialogInputDecoration({
    required String label,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.78),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.95)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.95)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: _headerBlue, width: 1.2),
      ),
    );
  }

  void _clearStaffForm() {
    _lastNameController.clear();
    _firstNameController.clear();
    _middleInitialController.clear();
    _emailController.clear();
    _passwordController.clear();
    _userTypeController.text = 'Staff';
    _statusController.text = 'Active';
  }

  void _setFormFromStaff(Map<String, dynamic> staff) {
    _lastNameController.text = '${staff['lastName'] ?? ''}';
    _firstNameController.text = '${staff['firstName'] ?? ''}';
    _middleInitialController.text = '${staff['middleInitial'] ?? ''}';
    _emailController.text = '${staff['email'] ?? ''}';
    _passwordController.clear();
    _userTypeController.text = '${staff['userType'] ?? 'Staff'}';
    _statusController.text = '${staff['status'] ?? 'Active'}';
  }

  String _buildFullNameFromForm() {
    final first = _firstNameController.text.trim();
    final middle = _middleInitialController.text.trim();
    final last = _lastNameController.text.trim();
    return [first, middle, last].where((part) => part.isNotEmpty).join(' ');
  }

  String _displayName(Map<String, dynamic> staff) {
    final fullName = '${staff['fullName'] ?? ''}'.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }
    final first = '${staff['firstName'] ?? ''}'.trim();
    final middle = '${staff['middleInitial'] ?? ''}'.trim();
    final last = '${staff['lastName'] ?? ''}'.trim();
    return [first, middle, last].where((part) => part.isNotEmpty).join(' ');
  }

  String _buildNextEmployeeId(String role) {
    final prefix = _rolePrefix(role);
    var highest = 0;
    for (final staff in staffList) {
      final id = '${staff['id'] ?? ''}'.toUpperCase();
      final match = RegExp('^$prefix-(\\d+)\$').firstMatch(id);
      if (match == null) continue;
      final value = int.tryParse(match.group(1) ?? '') ?? 0;
      if (value > highest) {
        highest = value;
      }
    }
    return '$prefix-${(highest + 1).toString().padLeft(3, '0')}';
  }

  String _rolePrefix(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'ADMIN';
      case 'manager':
        return 'MGR';
      default:
        return 'STF';
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Required';
    }
    if (!trimmed.contains('@') || !trimmed.contains('.')) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _passwordValidator(String? value, bool isEditing) {
    final trimmed = value?.trim() ?? '';
    if (!isEditing && trimmed.isEmpty) {
      return 'Required';
    }
    if (trimmed.isNotEmpty && trimmed.length < 6) {
      return 'At least 6 characters';
    }
    return null;
  }

  String _formatDate(DateTime value) {
    const months = [
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
    ];
    return '${months[value.month - 1]} ${value.day}, ${value.year}';
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? _danger : _headerBlue,
      ),
    );
  }
}
