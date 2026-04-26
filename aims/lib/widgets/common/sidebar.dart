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

  static const Color _sidebarBlue = Color(0xFF9AA9BD);
  static const Color _selectedBlue = Color(0xFFDDECEF);
  static const Color _textPrimary = Color(0xFF23323A);

  static const List<_SidebarItemData> _adminItems = [
    _SidebarItemData(
      icon: Icons.home_outlined,
      title: 'Dashboard',
    ),
    _SidebarItemData(
      icon: Icons.person_outline,
      title: 'Manage Staff',
    ),
  ];

  static const List<_SidebarItemData> _managerItems = [
    _SidebarItemData(
      icon: Icons.home_outlined,
      title: 'Dashboard',
    ),
    _SidebarItemData(
      icon: Icons.calendar_today_outlined,
      title: 'Calendar',
    ),
    _SidebarItemData(
      icon: Icons.list_alt_outlined,
      title: 'List of Users',
    ),
    _SidebarItemData(
      icon: Icons.card_membership_outlined,
      title: 'Membership and Loyalty Program',
    ),
  ];

  static const List<_SidebarItemData> _staffItems = [
    _SidebarItemData(
      icon: Icons.home_outlined,
      title: 'Dashboard',
    ),
    _SidebarItemData(
      icon: Icons.calendar_today_outlined,
      title: 'Calendar',
    ),
    _SidebarItemData(
      icon: Icons.list_alt_outlined,
      title: 'List of Users',
    ),
    _SidebarItemData(
      icon: Icons.card_membership_outlined,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 188,
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
          const SizedBox(height: 26),
          ..._items.map(_buildSidebarItem),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(_SidebarItemData item) {
    final isSelected = selectedTitle == item.title;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: InkWell(
        onTap: () => onItemSelected(item.title),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _selectedBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 17,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                item.icon,
                size: 20,
                color: _textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItemData {
  const _SidebarItemData({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;
}
