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
            colors: [
              Color(0xFFF1F7F9),
              Color(0xFFD5EDF3),
              Color(0xFF78B3C0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _BackgroundPattern()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 760;

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                                    fontSize: isMobile ? 28 : 32,
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
                                      builder: (hovering) => const _AdminGraphic(),
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
                                      builder: (hovering) => const _ManagerGraphic(),
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
                                      builder: (hovering) => const _StaffGraphic(),
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
                                    color: Colors.white.withOpacity(0.96),
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
                                      fontSize: 12,
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
                      )
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
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F1320),
            letterSpacing: -1.4,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'by hereafter',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF3F4452),
            fontWeight: FontWeight.w500,
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.identity()
            ..translate(0.0, _hovering ? -4.0 : 0.0)
            ..scale(_hovering ? 1.03 : 1.0),
          width: 170,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 170,
                height: 178,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_hovering ? 0.22 : 0.16),
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
                          border: Border.all(
                            color: const Color(0xFFD5D8DF),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(child: widget.builder(_hovering)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF151722),
                  letterSpacing: -0.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminGraphic extends StatelessWidget {
  const _AdminGraphic();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: Center(
            child: Icon(
              Icons.settings,
              size: 180,
              color: Color(0xFF171311),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Container(
              width: 104,
              height: 104,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  const Align(
                    alignment: Alignment(0, -0.25),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFF2B2724),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0, 0.58),
                    child: Container(
                      width: 70,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2724),
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ManagerGraphic extends StatelessWidget {
  const _ManagerGraphic();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 18,
          child: Container(
            width: 54,
            height: 74,
            decoration: BoxDecoration(
              color: const Color(0xFF44505F),
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
        Positioned(
          bottom: 18,
          child: Container(
            width: 112,
            height: 84,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF444E5B),
                  Color(0xFF21252C),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const Positioned(
          bottom: 66,
          child: Icon(
            Icons.air,
            size: 86,
            color: Colors.white,
          ),
        ),
        Positioned(
          bottom: 50,
          right: 54,
          child: Container(
            width: 18,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ],
    );
  }
}

class _StaffGraphic extends StatelessWidget {
  const _StaffGraphic();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Positioned(
          top: 8,
          child: CircleAvatar(
            radius: 52,
            backgroundColor: Colors.black,
          ),
        ),
        Positioned(
          top: 18,
          child: Container(
            width: 108,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(38),
            ),
          ),
        ),
        Positioned(
          bottom: 2,
          child: Row(
            children: [
              Container(
                width: 42,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 64,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Container(
                    width: 38,
                    height: 62,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEFEF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 42,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 50,
          child: Container(
            width: 92,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}

class _BackgroundPattern extends StatelessWidget {
  const _BackgroundPattern();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RibbonPainter(),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final darkPaint = Paint()
      ..color = Colors.black.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final lightPaint = Paint()
      ..color = Colors.white.withOpacity(0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    _drawField(
      canvas,
      size,
      origin: Offset(size.width * 0.64, size.height * 0.64),
      horizontalRadius: size.width * 0.44,
      verticalRadius: size.height * 0.34,
      lineCount: 22,
      paint: darkPaint,
    );

    _drawField(
      canvas,
      size,
      origin: Offset(size.width * 0.12, size.height * 0.66),
      horizontalRadius: size.width * 0.28,
      verticalRadius: size.height * 0.22,
      lineCount: 14,
      paint: darkPaint,
    );

    _drawField(
      canvas,
      size,
      origin: Offset(size.width * 0.76, size.height * 0.80),
      horizontalRadius: size.width * 0.36,
      verticalRadius: size.height * 0.28,
      lineCount: 12,
      paint: lightPaint,
    );
  }

  void _drawField(
    Canvas canvas,
    Size size, {
    required Offset origin,
    required double horizontalRadius,
    required double verticalRadius,
    required int lineCount,
    required Paint paint,
  }) {
    for (var i = 0; i < lineCount; i++) {
      final t = i / (lineCount - 1);
      final lift = (t - 0.5) * 2;

      final path = Path();
      path.moveTo(-horizontalRadius * 0.7, origin.dy + lift * verticalRadius);

      for (double x = -horizontalRadius; x <= horizontalRadius; x += 14) {
        final normalized = x / horizontalRadius;
        final wave = (normalized * normalized) * verticalRadius * 0.78;
        final twist = normalized * lift * verticalRadius * 1.15;
        final pointX = origin.dx + x + twist;
        final pointY = origin.dy + (lift * verticalRadius) - wave;
        path.lineTo(pointX, pointY);
      }

      canvas.drawPath(path, paint);
    }

    for (var i = 0; i < lineCount; i++) {
      final t = i / (lineCount - 1);
      final lift = (t - 0.5) * 2;

      final path = Path();
      path.moveTo(origin.dx + lift * horizontalRadius, size.height + 40);

      for (double y = size.height; y >= -40; y -= 14) {
        final normalized = (y - origin.dy) / verticalRadius;
        final bend = normalized * normalized * horizontalRadius * 0.46;
        final twist = normalized * lift * horizontalRadius * 0.72;
        final pointX = origin.dx + (lift * horizontalRadius) + bend - twist;
        path.lineTo(pointX, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
