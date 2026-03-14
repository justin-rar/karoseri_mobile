import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:karoseri_mobile/auth/login.dart'; // Import LoginPage kamu
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
        // Mengambil nama dari metadata atau email
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
        // Navigasi balik ke LoginPage dan hapus semua history page
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
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- WELCOME HEADER ---
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
              const SizedBox(height: 60),

              // --- MENU GRID ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildMenuCard(
                      title: "Lihat Progress",
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

              const SizedBox(height: 80),

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

  Widget _buildMenuCard({required String title, required VoidCallback onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 240, // Sedikit disesuaikan agar proporsional
            decoration: BoxDecoration(
              color: const Color(0xFFD4B07E),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                Center(
                  child: CustomPaint(
                    size: const Size(double.infinity, double.infinity),
                    painter: CrossPainter(),
                  ),
                ),
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

class CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
