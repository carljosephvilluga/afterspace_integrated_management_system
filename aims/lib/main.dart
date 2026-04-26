import 'package:flutter/material.dart';

import 'screens/dashboard/admin_dashboard_screen.dart';
import 'screens/dashboard/booking_management/availability.dart';
import 'screens/dashboard/manager_dashboard_screen.dart';
import 'screens/dashboard/staff_dashboard_screen.dart';
import 'screens/login/admin_login_screen.dart';
import 'screens/login/manager_login_screen.dart';
import 'screens/login/role_selection_screen.dart';
import 'screens/login/staff_login_screen.dart';
import '/screens/list_of_users/users_list.dart';

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
        '/staff-users': (context) => const StaffUsersListScreen(),
        '/calendar': (context) => const StaffBookingManagementScreen(),
        '/login': (context) => const RoleSelectionScreen(),
      },
    );
  }
}
