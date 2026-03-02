import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import halaman tujuan
import 'features/project/add_project_page.dart';
import 'features/inventory/inventory_page.dart';
import 'features/progress/update_progress_page.dart';
import 'features/payment/payment_page.dart';
import 'features/finished_project/finished_project_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String userName = "Admin";

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        userName =
            user.userMetadata?['full_name'] ??
            user.email?.split('@')[0] ??
            "Admin";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // Diaktifkan kembali karena menu bertambah
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER SECTION ---
                Text(
                  "HELLO, ${userName.toUpperCase()}",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Selamat datang kembali! Kelola antrean karoseri dan stok barang Anda hari ini.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),

                const Text(
                  "MENU UTAMA",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 15),

                // --- MENU SECTION (RESPONSIVE GRID) ---
                // Baris 1
                Row(
                  children: [
                    Expanded(
                      child: _itemMenu(
                        context,
                        "Tambah\nProyek",
                        Icons.add_task_rounded,
                        const AddProjectPage(),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _itemMenu(
                        context,
                        "Update\nProgress",
                        Icons.published_with_changes_rounded,
                        const UpdateProgressPage(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Baris 2
                Row(
                  children: [
                    Expanded(
                      child: _itemMenu(
                        context,
                        "Kelola\nStok",
                        Icons.inventory_2_outlined,
                        const InventoryPage(),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _itemMenu(
                        context,
                        "Kelola\nPayment",
                        Icons.payments_outlined,
                        const PaymentPage(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Baris 3: Menu Project Selesai (Dibuat lebar/Full Width agar simetris)
                _itemMenu(
                  context,
                  "Project Selesai",
                  Icons.assignment_turned_in_rounded,
                  const FinishedProjectPage(),
                  isFullWidth: true,
                ),

                const SizedBox(height: 40),

                // Tombol Logout
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                    },
                    icon: const Icon(Icons.logout, color: Colors.red, size: 20),
                    label: const Text(
                      "Logout Akun",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemMenu(
    BuildContext context,
    String judul,
    IconData icon,
    Widget tujuan, {
    bool isFullWidth = false,
  }) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => tujuan),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: isFullWidth ? 100 : 160, // Sesuaikan tinggi jika full width
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFD4B07E),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4B07E).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                icon,
                size: isFullWidth ? 100 : 80,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: isFullWidth
                  ? Row(
                      // Layout khusus jika menu lebar (Full Width)
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: const Color(0xFFD4B07E),
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          judul,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      // Layout standar kotak
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: const Color(0xFFD4B07E),
                            size: 24,
                          ),
                        ),
                        Text(
                          judul,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
