import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import sesuai struktur folder di gambar
import 'features/progress/progress_page.dart';

class DashboardCust extends StatefulWidget {
  const DashboardCust({super.key});

  @override
  State<DashboardCust> createState() => _DashboardCustState();
}

class _DashboardCustState extends State<DashboardCust> {
  final supabase = Supabase.instance.client;
  String userName = "User";

  @override
  void initState() {
    super.initState();
    _getDisplayName();
  }

  void _getDisplayName() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        // Mengambil nama dari metadata atau fallback ke email
        userName =
            user.userMetadata?['nama'] ??
            user.userMetadata?['full_name'] ??
            user.email?.split('@')[0] ??
            "Pelanggan";
      });
    }
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
                "HELLO, ${(userName ?? "user").toLowerCase()}",
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Selamat datang di portal pelanggan kami. Di sini Anda dapat memantau perkembangan proyek Anda secara real-time dan mengelola tagihan dengan lebih mudah dan transparan.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 60),

              // --- MENU GRID ---
              Row(
                children: [
                  // Menu Lihat Progress
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
                  // Menu Lihat Invoice
                  Expanded(
                    child: _buildMenuCard(
                      title: "Lihat Invoice Tagihan",
                      onTap: () {
                        // Tambahkan navigasi ke invoice_page.dart jika sudah dibuat
                      },
                    ),
                  ),
                ],
              ),
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
            height: 280, // Tinggi disesuaikan dengan desain panjang di gambar
            decoration: BoxDecoration(
              color: const Color(
                0xFFD4B07E,
              ), // Warna cokelat keemasan sesuai desain
              borderRadius: BorderRadius.circular(4),
            ),
            // Cross lines placeholder sesuai desain wireframe
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
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

// Painter untuk menggambar tanda silang (X) di dalam kotak menu
class CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
