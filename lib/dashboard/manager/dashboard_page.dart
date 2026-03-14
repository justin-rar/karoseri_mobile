import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:karoseri_mobile/auth/login.dart'; // Import halaman login kamu

// Import halaman tujuan sesuai struktur folder
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
  final supabase = Supabase.instance.client;
  String userName = "Admin";

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        userName =
            user.userMetadata?['full_name'] ??
            user.email?.split('@')[0] ??
            "Admin";
      });
    }
  }

  // --- FUNGSI LOGOUT MANAGER ---
  Future<void> _handleLogout() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        // Menghapus semua history page dan kembali ke Login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal logout: $e")));
      }
    }
  }

  // --- DIALOG KONFIRMASI LOGOUT ---
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Konfirmasi Logout"),
        content: const Text(
          "Apakah Anda yakin ingin keluar dari akun Manager?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("BATAL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "YA, KELUAR",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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

                // --- MENU SECTION ---
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

                _itemMenu(
                  context,
                  "Project Selesai",
                  Icons.assignment_turned_in_rounded,
                  const FinishedProjectPage(),
                  isFullWidth: true,
                ),

                const SizedBox(height: 40),

                // --- TOMBOL LOGOUT ---
                Center(
                  child: TextButton.icon(
                    onPressed: _showLogoutDialog,
                    icon: const Icon(Icons.logout, color: Colors.red, size: 20),
                    label: const Text(
                      "Logout Akun",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
        height: isFullWidth ? 100 : 160,
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
