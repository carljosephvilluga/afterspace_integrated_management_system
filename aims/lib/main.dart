import 'package:flutter/material.dart';

import 'screens/dashboard/admin_dashboard_screen.dart';
import 'screens/dashboard/booking_management/availability.dart';
import 'screens/dashboard/manager_dashboard_screen.dart';
import 'screens/membership_loyalty/membership_loyalty_program_screen.dart';
import 'screens/dashboard/staff_dashboard_screen.dart';
import 'screens/login/admin_login_screen.dart';
import 'screens/login/manager_login_screen.dart';
import 'screens/login/role_selection_screen.dart';
import 'screens/login/staff_login_screen.dart';
import 'screens/staff_management/staff_management_screen.dart';
import '/screens/list_of_users/users_list.dart';
import 'widgets/common/header.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AfterSpace Integrated Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _AfterspaceMorphPageTransitionsBuilder(),
            TargetPlatform.fuchsia: _AfterspaceMorphPageTransitionsBuilder(),
            TargetPlatform.iOS: _AfterspaceMorphPageTransitionsBuilder(),
            TargetPlatform.linux: _AfterspaceMorphPageTransitionsBuilder(),
            TargetPlatform.macOS: _AfterspaceMorphPageTransitionsBuilder(),
            TargetPlatform.windows: _AfterspaceMorphPageTransitionsBuilder(),
          },
        ),
      ),
      home: const RoleSelectionScreen(),
      routes: {
        '/admin-login': (context) => const AdminLoginScreen(),
        '/manager-login': (context) => const ManagerLoginScreen(),
        '/staff-login': (context) => const StaffLoginScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/staff-management': (context) => const StaffManagementScreen(),
        '/manager-dashboard': (context) => const ManagerDashboardScreen(),
        '/staff-dashboard': (context) => const StaffDashboardScreen(),
        '/membership-loyalty-program': (context) =>
            const MembershipLoyaltyProgramScreen(),
        '/manager-membership': (context) =>
            MembershipLoyaltyProgramScreen(role: UserRole.manager),
        '/staff-users': (context) => const StaffUsersListScreen(),
        '/manager-users': (context) =>
            StaffUsersListScreen(role: UserRole.manager),
        '/calendar': (context) => const StaffBookingManagementScreen(),
        '/manager-calendar': (context) =>
            StaffBookingManagementScreen(role: UserRole.manager),
        '/login': (context) => const RoleSelectionScreen(),
      },
    );
  }
}

class _AfterspaceMorphPageTransitionsBuilder extends PageTransitionsBuilder {
  const _AfterspaceMorphPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final morphAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutExpo,
      reverseCurve: Curves.easeInExpo,
    );
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.05, 0.85, curve: Curves.easeOut),
      reverseCurve: Curves.easeIn,
    );
    final scaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1,
    ).animate(morphAnimation);
    final radiusAnimation = Tween<double>(
      begin: 28,
      end: 0,
    ).animate(morphAnimation);

    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: AnimatedBuilder(
          animation: radiusAnimation,
          child: child,
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(radiusAnimation.value),
              child: child,
            );
          },
        ),
      ),
    );
  }
}
