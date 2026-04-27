import 'package:flutter/material.dart';
import 'package:aims/widgets/dialogs/confirm_logout_dialog.dart'; // import the reusable logout dialog

enum UserRole { admin, manager, staff }

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
                        Text(
                          getRoleText(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white.withValues(alpha: 0.95),
                          child: Icon(
                            getAvatarIcon(),
                            size: 20,
                            color: _headerBlue,
                          ),
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
