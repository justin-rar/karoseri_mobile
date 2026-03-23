import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:karoseri_mobile/auth/login.dart'; // Sesuaikan path LoginPage kamu
import 'features/progress/progress_page.dart';
import 'features/invoice/invoice_page.dart';

class DashboardCust extends StatefulWidget {
  const DashboardCust({super.key});

  @override
  State<DashboardCust> createState() => _DashboardCustState();
}

class _DashboardCustState extends State<DashboardCust> {
  final supabase = Supabase.instance.client;
  String userName = "pelanggan";

  @override
  void initState() {
    super.initState();
    _getDisplayName();
  }

  void _getDisplayName() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        userName =
            user.userMetadata?['nama'] ??
            user.userMetadata?['full_name'] ??
            user.email?.split('@')[0] ??
            "pelanggan";
      });
    }
  }

  // FUNGSI LOGOUT
  Future<void> _handleLogout() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saat keluar: $e")));
      }
    }
  }

  // Dialog Konfirmasi Logout
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Keluar Akun?"),
        content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
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
              backgroundColor: Colors.redAccent,
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
          // Padding vertical disesuaikan menjadi 40 agar tidak terlalu mepet atas
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- WELCOME HEADER (LANGSUNG DI ATAS) ---
              Text(
                "HELLO, ${userName.toLowerCase()}",
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Selamat datang di portal pelanggan kami. Di sini Anda dapat memantau perkembangan proyek Anda secara real-time dan mengelola tagihan dengan lebih mudah.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 50),

              // --- MENU GRID DENGAN LOGO/ICON RELEVAN ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildMenuCard(
                      title: "Lihat Progress",
                      iconData: Icons.local_shipping_rounded, // Icon Truk/Bus
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProgressPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    child: _buildMenuCard(
                      title: "Lihat Invoice Tagihan",
                      iconData:
                          Icons.receipt_long_rounded, // Icon Kertas Invoice
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InvoicePage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // --- TOMBOL LOGOUT ---
              Center(
                child: TextButton.icon(
                  onPressed: _showLogoutDialog,
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text(
                    "LOG OUT ACCOUNT",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET CARD MENU MODERN DENGAN LOGO DI DALAMNYA
  Widget _buildMenuCard({
    required String title,
    required IconData iconData,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 200, // Tinggi proporsional
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFD4B07E), // Warna coklat karoseri
              borderRadius: BorderRadius.circular(12), // Melengkung modern
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Logo/Icon watermark transparan di kanan bawah kotak
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    iconData,
                    size: 150,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                // Logo/Icon Solid di Tengah Menu
                Center(child: Icon(iconData, size: 80, color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
