import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import halaman tujuan
import 'features/project/add_project_page.dart';
import 'features/inventory/inventory_page.dart';
import 'features/progress/update_progress_page.dart';
import 'features/payment/payment_page.dart';

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
        // Menghilangkan SingleChildScrollView agar layar tetap diam (Fixed)
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

              // --- GRID MENU SECTION (FIXED / NON-SCROLLABLE) ---
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2, // Membagi menjadi 2 kolom
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  physics:
                      const NeverScrollableScrollPhysics(), // Mematikan scroll grid
                  children: [
                    _itemMenu(
                      context,
                      "Tambah\nProyek",
                      Icons.add_task_rounded,
                      const AddProjectPage(),
                    ),
                    _itemMenu(
                      context,
                      "Update\nProgress",
                      Icons.published_with_changes_rounded,
                      const UpdateProgressPage(),
                    ),
                    _itemMenu(
                      context,
                      "Kelola\nStok",
                      Icons.inventory_2_outlined,
                      const InventoryPage(),
                    ),
                    _itemMenu(
                      context,
                      "Kelola\nPayment",
                      Icons.payments_outlined,
                      const PaymentPage(),
                    ),
                  ],
                ),
              ),

              // Tombol Logout Opsional di bawah jika layar sisa banyak
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
    );
  }

  Widget _itemMenu(
    BuildContext context,
    String judul,
    IconData icon,
    Widget tujuan,
  ) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => tujuan),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
            // Ornamen dekorasi di pojok biar tidak kosong
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(icon, size: 80, color: Colors.white.withOpacity(0.2)),
            ),
            // Konten Utama (Icon & Text)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: const Color(0xFFD4B07E), size: 24),
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
