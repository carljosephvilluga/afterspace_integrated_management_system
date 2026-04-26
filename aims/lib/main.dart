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
      title: 'AfterSpace',
      debugShowCheckedModeBanner: false,
      home: const RoleSelectionScreen(),
      routes: {
        '/admin-login': (context) => const AdminLoginScreen(),
        '/manager-login': (context) => const ManagerLoginScreen(),
        '/staff-login': (context) => const StaffLoginScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
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
