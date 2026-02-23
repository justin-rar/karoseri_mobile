import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_page.dart';

void main() {
  runApp(const KaroseriApp());
}

class KaroseriApp extends StatelessWidget {
  const KaroseriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Manajemen Karoseri',
      home: const DashboardPage(),
    );
  }
}
