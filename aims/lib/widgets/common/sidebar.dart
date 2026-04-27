import 'package:aims/widgets/common/header.dart';
import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.role,
    required this.selectedTitle,
    required this.onItemSelected,
  });

  final UserRole role;
  final String selectedTitle;
  final ValueChanged<String> onItemSelected;

  static const double width = 88;
  static const Color _sidebarBlue = Color(0xFF9AA9BD);
  static const Color _selectedBlue = Color(0xFFDDECEF);
  static const Color _textPrimary = Color(0xFF23323A);
  static const Color _textMuted = Color(0xFF40505A);
  static const Color _hoverBlue = Color(0x2FDDECEF);
  static const Color _splashBlue = Color(0x73DDECEF);
  static const Color _highlightBlue = Color(0x47DDECEF);

  static const List<_SidebarItemData> _adminItems = [
    _SidebarItemData(icon: Icons.space_dashboard_outlined, title: 'Dashboard'),
    _SidebarItemData(
      icon: Icons.manage_accounts_outlined,
      title: 'Manage Staff',
    ),
  ];

  static const List<_SidebarItemData> _managerItems = [
    _SidebarItemData(icon: Icons.space_dashboard_outlined, title: 'Dashboard'),
    _SidebarItemData(icon: Icons.calendar_today_outlined, title: 'Calendar'),
    _SidebarItemData(icon: Icons.groups_outlined, title: 'List of Users'),
    _SidebarItemData(
      icon: Icons.loyalty_outlined,
      title: 'Membership and Loyalty Program',
    ),
  ];

  static const List<_SidebarItemData> _staffItems = [
    _SidebarItemData(icon: Icons.space_dashboard_outlined, title: 'Dashboard'),
    _SidebarItemData(icon: Icons.calendar_today_outlined, title: 'Calendar'),
    _SidebarItemData(icon: Icons.groups_outlined, title: 'List of Users'),
    _SidebarItemData(
      icon: Icons.loyalty_outlined,
      title: 'Membership and Loyalty Program',
    ),
  ];

  List<_SidebarItemData> get _items {
    switch (role) {
      case UserRole.admin:
        return _adminItems;
      case UserRole.manager:
        return _managerItems;
      case UserRole.staff:
        return _staffItems;
    }
  }

  IconData get _roleIcon {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings_outlined;
      case UserRole.manager:
        return Icons.badge_outlined;
      case UserRole.staff:
        return Icons.support_agent_outlined;
    }
  }

  String get _roleLabel {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.staff:
        return 'Staff';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: _sidebarBlue,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          ..._items.map(_buildSidebarItem),
          const Spacer(),
          _buildRoleBadge(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(_SidebarItemData item) {
    final isSelected = selectedTitle == item.title;

    return Tooltip(
      message: item.title,
      waitDuration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 56,
          decoration: BoxDecoration(
            color: isSelected ? _selectedBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(isSelected ? 20 : 18),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x1A23323A),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => onItemSelected(item.title),
              borderRadius: BorderRadius.circular(20),
              hoverColor: _hoverBlue,
              splashColor: _splashBlue,
              highlightColor: _highlightBlue,
              child: AnimatedScale(
                scale: isSelected ? 1.08 : 1,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: Icon(
                  item.icon,
                  size: 24,
                  color: isSelected ? _textPrimary : _textMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge() {
    return Tooltip(
      message: _roleLabel,
      waitDuration: const Duration(milliseconds: 400),
      child: Center(
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0x33DDECEF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x4DDDECEF)),
          ),
          child: Icon(_roleIcon, color: _textPrimary, size: 24),
        ),
      ),
    );
  }
}

class _SidebarItemData {
  const _SidebarItemData({required this.icon, required this.title});

  final IconData icon;
  final String title;
}
