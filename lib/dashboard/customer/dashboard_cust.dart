import 'package:flutter/material.dart';

// Import halaman tujuan sesuai struktur foldermu
import '../manager/features/project/add_project_page.dart';
import '../manager/features/inventory/inventory_page.dart';
import '../manager/features/progress/update_progress_page.dart';
import '../manager/features/payment/payment_page.dart';

class DashboardCustomer extends StatelessWidget {
  const DashboardCustomer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard Customer")),
      body: const Center(child: Text("Selamat Datang, Pak Customer!")),
    );
  }
}
