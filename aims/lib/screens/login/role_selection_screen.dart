import 'package:flutter/material.dart';

import 'admin_login_screen.dart';
import 'manager_login_screen.dart';
import 'staff_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1F7F9), Color(0xFFD5EDF3), Color(0xFF78B3C0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/role-pick-bg.png',
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 760;

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 18 : 38,
                            vertical: isMobile ? 22 : 34,
                          ),
                          child: SizedBox(
                            width: isMobile ? double.infinity : 860,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: isMobile ? 18 : 10),
                                const _BrandBlock(),
                                SizedBox(height: isMobile ? 34 : 42),
                                Text(
                                  'Sign in as',
                                  style: TextStyle(
                                    fontSize: isMobile ? 25 : 35,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF151722),
                                    letterSpacing: -1.1,
                                  ),
                                ),
                                SizedBox(height: isMobile ? 24 : 26),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  runAlignment: WrapAlignment.center,
                                  spacing: isMobile ? 16 : 28,
                                  runSpacing: isMobile ? 20 : 22,
                                  children: [
                                    _RoleCard(
                                      label: 'Administrator',
                                      builder: (hovering) =>
                                          const _AdminGraphic(),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const AdminLoginScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    _RoleCard(
                                      label: 'Manager',
                                      builder: (hovering) =>
                                          const _ManagerGraphic(),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const ManagerLoginScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    _RoleCard(
                                      label: 'Staff',
                                      builder: (hovering) =>
                                          const _StaffGraphic(),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const StaffLoginScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: isMobile ? 34 : 48),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 36,
                                    vertical: 13,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.96),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x29000000),
                                        blurRadius: 14,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'Select your appropriate Role',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF22252D),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'afterspace',
          style: TextStyle(
            fontSize: 70,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F1320),
            letterSpacing: -1.4,
            height: 1.05,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'by hereafter',
          style: TextStyle(
            fontSize: 30,
            color: Color(0xFF3F4452),
            fontWeight: FontWeight.w500,
            height: 1.05,
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatefulWidget {
  const _RoleCard({
    required this.label,
    required this.builder,
    required this.onTap,
  });

  final String label;
  final Widget Function(bool hovering) builder;
  final VoidCallback onTap;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          offset: Offset(0, _hovering ? -0.025 : 0),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            scale: _hovering ? 1.03 : 1.0,
            child: SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildGraphicCard(),
                  const SizedBox(height: 12),
                  Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF151722),
                      letterSpacing: -0.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGraphicCard() {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _hovering ? 0.22 : 0.16),
            blurRadius: _hovering ? 18 : 12,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFDFDFD),
                    Color(0xFFF8F8F8),
                    Color(0xFF4D5560),
                  ],
                  stops: [0.0, 0.68, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(color: const Color(0xFFD5D8DF)),
              ),
            ),
          ),
          Positioned.fill(child: widget.builder(_hovering)),
        ],
      ),
    );
  }
}

class _AdminGraphic extends StatelessWidget {
  const _AdminGraphic();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14), // match card corners
        child: Image.asset(
          'assets/images/admin_bg.png',
          fit: BoxFit.cover,   // fills and crops to cover
        ),
      ),
    );
  }
}

class _ManagerGraphic extends StatelessWidget {
  const _ManagerGraphic();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14), // match card corners
        child: Image.asset(
          'assets/images/manager_bg.png',
          fit: BoxFit.cover,   // fills and crops to cover
        ),
      ),
    );
  }
}

class _StaffGraphic extends StatelessWidget {
  const _StaffGraphic();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14), // match card corners
        child: Image.asset(
          'assets/images/staff_bg.png',
          fit: BoxFit.cover,   // fills and crops to cover
        ),
      ),
    );
  }
}
