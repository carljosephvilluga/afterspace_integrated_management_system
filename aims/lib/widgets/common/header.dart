// Purpose: Shared top navigation bar with logout, account, and meeting notification actions.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:aims/services/aims_api_client.dart';
import 'package:aims/services/app_session.dart';
import 'package:aims/widgets/dialogs/confirm_logout_dialog.dart'; // import the reusable logout dialog

enum UserRole { admin, manager, staff }

enum _AccountAction { changeName, changePassword }

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.role,
    required this.onMenuTap,
    required this.maxWidth,
  });

  final UserRole role;
  final VoidCallback onMenuTap;
  final double maxWidth;

  static const Color _headerBlue = Color(0xFF80AEC1);
  static const Color _sidebarBlue = Color(0xFF9AA9BD);
  static const double _navigationRailWidth = 88;

  String getRoleText() {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.staff:
        return 'Staff';
    }
  }

  IconData getAvatarIcon() {
    switch (role) {
      case UserRole.admin:
        return Icons.person;
      case UserRole.manager:
      case UserRole.staff:
        return Icons.badge_outlined;
    }
  }

  String _currentFullName() {
    final user = AppSession.user;
    return '${user?['full_name'] ?? user?['fullName'] ?? ''}'.trim();
  }

  String _currentFirstName() {
    final fullName = _currentFullName();
    if (fullName.isEmpty) {
      return getRoleText();
    }
    return fullName.split(RegExp(r'\s+')).first;
  }

  Future<void> _showChangeNameDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: _currentFullName());
    var isSaving = false;

    try {
      await showDialog<void>(
        context: context,
        builder: (modalContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              Future<void> submit() async {
                if (isSaving || !(formKey.currentState?.validate() ?? false)) {
                  return;
                }

                setDialogState(() => isSaving = true);
                try {
                  final updatedAccount = await AimsApiClient.instance
                      .updateCurrentStaffName(
                        fullName: nameController.text.trim(),
                      );
                  if (!dialogContext.mounted) {
                    return;
                  }
                  Navigator.of(dialogContext).pop();
                  if (context.mounted) {
                    _showMessage(
                      context,
                      'Name updated to ${updatedAccount.fullName}.',
                    );
                  }
                } catch (error) {
                  if (!dialogContext.mounted) {
                    return;
                  }
                  setDialogState(() => isSaving = false);
                  _showMessage(
                    dialogContext,
                    'Unable to update name: $error',
                    isError: true,
                  );
                }
              }

              return AlertDialog(
                backgroundColor: const Color(0xFFF4F8FA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                title: const Text(
                  'Change name',
                  style: TextStyle(
                    color: Color(0xFF22313A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                content: Form(
                  key: formKey,
                  child: SizedBox(
                    width: 360,
                    child: TextFormField(
                      controller: nameController,
                      textInputAction: TextInputAction.done,
                      decoration: _dialogFieldDecoration(
                        'Full name',
                        Icons.person_outline_rounded,
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Enter your name.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => submit(),
                    ),
                  ),
                ),
                actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
                actions: [
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton.icon(
                    onPressed: isSaving ? null : submit,
                    icon: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: Text(isSaving ? 'Saving' : 'Save'),
                    style: _dialogPrimaryButtonStyle(),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    var isSaving = false;
    var obscurePassword = true;
    var obscureConfirmation = true;

    try {
      await showDialog<void>(
        context: context,
        builder: (modalContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              Future<void> submit() async {
                if (isSaving || !(formKey.currentState?.validate() ?? false)) {
                  return;
                }

                setDialogState(() => isSaving = true);
                try {
                  await AimsApiClient.instance.updateCurrentStaffPassword(
                    password: passwordController.text.trim(),
                  );
                  if (!dialogContext.mounted) {
                    return;
                  }
                  Navigator.of(dialogContext).pop();
                  if (context.mounted) {
                    _showMessage(context, 'Password updated.');
                  }
                } catch (error) {
                  if (!dialogContext.mounted) {
                    return;
                  }
                  setDialogState(() => isSaving = false);
                  _showMessage(
                    dialogContext,
                    'Unable to update password: $error',
                    isError: true,
                  );
                }
              }

              return AlertDialog(
                backgroundColor: const Color(0xFFF4F8FA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                title: const Text(
                  'Change password',
                  style: TextStyle(
                    color: Color(0xFF22313A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                content: Form(
                  key: formKey,
                  child: SizedBox(
                    width: 360,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          textInputAction: TextInputAction.next,
                          decoration: _dialogFieldDecoration(
                            'New password',
                            Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              tooltip: obscurePassword
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: () {
                                setDialogState(
                                  () => obscurePassword = !obscurePassword,
                                );
                              },
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if ((value ?? '').trim().length < 6) {
                              return 'Use at least 6 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: obscureConfirmation,
                          textInputAction: TextInputAction.done,
                          decoration: _dialogFieldDecoration(
                            'Confirm password',
                            Icons.lock_reset_rounded,
                            suffixIcon: IconButton(
                              tooltip: obscureConfirmation
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: () {
                                setDialogState(
                                  () => obscureConfirmation =
                                      !obscureConfirmation,
                                );
                              },
                              icon: Icon(
                                obscureConfirmation
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if ((value ?? '').trim() !=
                                passwordController.text.trim()) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => submit(),
                        ),
                      ],
                    ),
                  ),
                ),
                actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
                actions: [
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton.icon(
                    onPressed: isSaving ? null : submit,
                    icon: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: Text(isSaving ? 'Saving' : 'Save'),
                    style: _dialogPrimaryButtonStyle(),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      passwordController.dispose();
      confirmPasswordController.dispose();
    }
  }

  InputDecoration _dialogFieldDecoration(
    String label,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _headerBlue),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD3DEE3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _headerBlue, width: 1.4),
      ),
    );
  }

  ButtonStyle _dialogPrimaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _headerBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
    );
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? const Color(0xFFB84E4E)
              : const Color(0xFF4D7F90),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _headerBlue,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SizedBox(
            height: 74,
            child: Row(
              children: [
                Container(
                  width: _navigationRailWidth,
                  color: _sidebarBlue,
                  child: InkWell(
                    onTap: onMenuTap,
                    child: const Center(child: _HeaderMenuIcon()),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            final shouldLogout =
                                await showDialog<bool>(
                                  context: context,
                                  builder: (_) => const ConfirmLogoutDialog(),
                                ) ??
                                false;

                            if (shouldLogout && context.mounted) {
                              await AimsApiClient.instance.logout();
                              if (!context.mounted) return;
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                          child: Row(
                            children: const [
                              Icon(
                                Icons.logout_rounded,
                                size: 22,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _MeetingNotificationButton(),
                            const SizedBox(width: 10),
                            StatefulBuilder(
                              builder: (accountContext, setAccountState) {
                                return PopupMenuButton<_AccountAction>(
                                  tooltip: 'Account options',
                                  offset: const Offset(0, 44),
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  onSelected: (action) async {
                                    switch (action) {
                                      case _AccountAction.changeName:
                                        await _showChangeNameDialog(context);
                                      case _AccountAction.changePassword:
                                        await _showChangePasswordDialog(
                                          context,
                                        );
                                    }
                                    if (accountContext.mounted) {
                                      setAccountState(() {});
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: _AccountAction.changeName,
                                      child: _AccountMenuItem(
                                        icon: Icons.person_outline_rounded,
                                        label: 'Change name',
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: _AccountAction.changePassword,
                                      child: _AccountMenuItem(
                                        icon: Icons.lock_outline_rounded,
                                        label: 'Change password',
                                      ),
                                    ),
                                  ],
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 120,
                                        ),
                                        child: Text(
                                          _currentFirstName(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.95),
                                        child: Icon(
                                          getAvatarIcon(),
                                          size: 20,
                                          color: _headerBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
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

class _MeetingNotificationButton extends StatefulWidget {
  const _MeetingNotificationButton();

  @override
  State<_MeetingNotificationButton> createState() =>
      _MeetingNotificationButtonState();
}

class _MeetingNotificationButtonState
    extends State<_MeetingNotificationButton> {
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF6F7E87);
  static const Color _badgeColor = Color(0xFFD7B59E);
  static const Duration _refreshInterval = Duration(seconds: 20);

  Timer? _refreshTimer;
  bool _isLoading = true;
  String? _error;
  List<MeetingScheduleRecord> _upcomingMeetings = const [];

  int get _notificationCount => _upcomingMeetings.length;

  @override
  void initState() {
    super.initState();
    _loadUpcomingMeetings();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (!mounted) {
        return;
      }
      _loadUpcomingMeetings(showLoader: false);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUpcomingMeetings({bool showLoader = true}) async {
    if (showLoader && mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    final today = DateTime.now();
    final from = DateTime(today.year, today.month, today.day);
    final to = from.add(const Duration(days: 30));

    try {
      // Reuse the admin calendar schedule API so the bell always reflects the
      // same meeting records shown in the dashboard calendar.
      final schedules = await AimsApiClient.instance.fetchMeetingSchedules(
        from: from,
        to: to,
      );
      final now = DateTime.now();
      final upcoming =
          schedules.where((schedule) => schedule.endAt.isAfter(now)).toList()
            ..sort((a, b) => a.startAt.compareTo(b.startAt));

      if (!mounted) {
        return;
      }
      setState(() {
        _upcomingMeetings = upcoming;
        _isLoading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _showNotificationsPanel() async {
    await _loadUpcomingMeetings(showLoader: false);
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.12),
      builder: (dialogContext) {
        final screenSize = MediaQuery.sizeOf(dialogContext);

        return Dialog(
          elevation: 0,
          insetPadding: const EdgeInsets.fromLTRB(16, 82, 22, 16),
          alignment: Alignment.topRight,
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 390,
              maxHeight: screenSize.height * 0.68,
            ),
            child: Material(
              color: const Color(0xFFF4F8FA),
              borderRadius: BorderRadius.circular(8),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPanelHeader(dialogContext),
                    const SizedBox(height: 12),
                    Flexible(child: _buildPanelBody()),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPanelHeader(BuildContext dialogContext) {
    final count = _notificationCount;
    final title = count == 0
        ? 'Meeting Notifications'
        : count == 1
        ? '1 Upcoming Meeting'
        : '$count Upcoming Meetings';

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: () {
            Navigator.of(dialogContext).pop();
            _loadUpcomingMeetings();
          },
          icon: const Icon(Icons.refresh_rounded, size: 20),
          color: Header._headerBlue,
        ),
        IconButton(
          tooltip: 'Close',
          onPressed: () => Navigator.of(dialogContext).pop(),
          icon: const Icon(Icons.close_rounded, size: 20),
          color: _textMuted,
        ),
      ],
    );
  }

  Widget _buildPanelBody() {
    if (_isLoading && _upcomingMeetings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 22),
        child: Center(
          child: Text(
            'Checking meeting schedules...',
            style: TextStyle(color: _textMuted, fontSize: 12),
          ),
        ),
      );
    }

    if (_error != null && _upcomingMeetings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Text(
          'Unable to load meeting notifications.',
          style: TextStyle(
            color: Colors.red.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (_upcomingMeetings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 22),
        child: Center(
          child: Text(
            'No upcoming meetings yet.',
            style: TextStyle(color: _textMuted, fontSize: 12),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: _upcomingMeetings.length,
      separatorBuilder: (context, index) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final meeting = _upcomingMeetings[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Header._headerBlue.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.event_available_outlined,
                color: Header._headerBlue,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meeting.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatScheduleDate(meeting.startAt)}  ${_formatTime(meeting.startAt)} - ${_formatTime(meeting.endAt)}',
                    style: const TextStyle(
                      color: _textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (meeting.notes.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      meeting.notes,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _textMuted, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = _notificationCount;

    return Tooltip(
      message: 'Meeting notifications',
      child: InkWell(
        onTap: _showNotificationsPanel,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(
                count > 0
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_none_rounded,
                size: 22,
                color: Colors.white,
              ),
              if (count > 0)
                Positioned(
                  top: 4,
                  right: 3,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 15),
                    height: 15,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _badgeColor,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Header._headerBlue, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      count > 9 ? '9+' : count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
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

  String _formatScheduleDate(DateTime value) {
    final today = DateTime.now();
    final currentDay = DateTime(today.year, today.month, today.day);
    final meetingDay = DateTime(value.year, value.month, value.day);

    if (meetingDay == currentDay) {
      return 'Today';
    }
    if (meetingDay == currentDay.add(const Duration(days: 1))) {
      return 'Tomorrow';
    }

    return '${_monthShort(value.month)} ${value.day}';
  }

  String _formatTime(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  String _monthShort(int month) {
    return const [
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
    ][month - 1];
  }
}

class _AccountMenuItem extends StatelessWidget {
  const _AccountMenuItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Header._headerBlue, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF22313A),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HeaderMenuIcon extends StatelessWidget {
  const _HeaderMenuIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [_MenuLine(), _MenuLine(), _MenuLine()],
      ),
    );
  }
}

class _MenuLine extends StatelessWidget {
  const _MenuLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 3,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
