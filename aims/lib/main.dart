import 'package:flutter/material.dart';
import 'package:aims/screens/dashboard/staff_dashboard_screen.dart';
import 'package:aims/screens/login/staff_login_screen.dart';
import 'package:aims/screens/list_of_users/users_list.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF80AEC1)),
        useMaterial3: true,
      ),
      initialRoute: '/staff-login',
      routes: {
        '/staff-login': (context) => const StaffLoginScreen(),
        '/staff-dashboard': (context) => const StaffDashboardScreen(),
        '/staff-users': (context) => const StaffUsersListScreen(),
      },
    );
  }
}
