import 'package:flutter/material.dart';

// Import halaman tujuan sesuai struktur foldermu
import '../project/add_project_page.dart';
import '../inventory/inventory_page.dart';
import '../progress/update_progress_page.dart';
import '../payment/payment_page.dart';

class DashboardDirektur extends StatelessWidget {
  const DashboardDirektur({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard Direktur")),
      body: const Center(child: Text("Selamat Datang, Pak Direktur!")),
    );
  }
}
