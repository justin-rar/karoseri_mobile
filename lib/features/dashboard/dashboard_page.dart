import 'package:flutter/material.dart';

// Import halaman tujuan sesuai struktur foldermu
import '../project/add_project_page.dart';
import '../inventory/inventory_page.dart';
import '../progress/update_progress_page.dart';
import '../payment/payment_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "HELLO, user",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 30),

                // --- MENU 1: TAMBAH PROYEK ---
                _tombolMenu(context, "Tambah Proyek", const AddProjectPage()),

                // --- MENU 2: UPDATE PROGRESS ---
                _tombolMenu(
                  context,
                  "Update Progress",
                  const UpdateProgressPage(),
                ),

                // --- MENU 3: KELOLA STOCK ---
                _tombolMenu(context, "Kelola Stock", const InventoryPage()),

                // --- MENU 4: KELOLA PEMBAYARAN ---
                _tombolMenu(context, "Kelola Pembayaran", const PaymentPage()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi bantuan supaya kode tidak berulang-ulang (DRY - Don't Repeat Yourself)
  Widget _tombolMenu(BuildContext context, String judul, Widget halamanTujuan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(judul, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => halamanTujuan),
            );
          },
          child: Container(
            height: 100,
            width: double.infinity,
            color: const Color(0xFFD4B07E),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
