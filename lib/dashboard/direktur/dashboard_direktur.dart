import 'package:flutter/material.dart';

// Import halaman tujuan sesuai struktur foldermu
import '../manager/features/project/add_project_page.dart';
import '../manager/features/inventory/inventory_page.dart';
import '../manager/features/progress/update_progress_page.dart';
import '../manager/features/payment/payment_page.dart';
import 'timelinedirektur.dart';
import 'laporan.dart';

class DashboardDirektur extends StatelessWidget {
  const DashboardDirektur({super.key});

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
              // 1. Header: Hello User
              const Text(
                "HELLO, user",
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.5,
                  color: Colors.black,
                  fontFamily: 'Serif', // Memberikan kesan mewah/otoritas
                ),
              ),
              const SizedBox(height: 25),

              // 2. Deskripsi / Visi Misi
              const Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat laborom.",
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 70),

              // 3. Menu Utama (Dua Kartu Vertikal)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tombol Lihat Laporan
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: "Lihat Laporan",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ListLaporanPage(),
                          ), // Ke List dulu
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 30),
                  // Tombol Timeline
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: "Timeline",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TimelineDirekturPage(),
                          ),
                        );
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

  // Widget Helper: Kartu Menu Premium
  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 0.65, // Membuat bentuk persegi panjang vertikal
            child: Container(
              decoration: BoxDecoration(
                color: const Color(
                  0xFFD4B07E,
                ), // Warna Gold/Tan sesuai referensi
                borderRadius: BorderRadius.circular(2), // Sudut tajam/minimalis
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              // Simbol Silang (X) di tengah kartu
              child: CustomPaint(painter: CrossPainter()),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// Custom Painter untuk menggambar silang (X) tipis di tengah kartu
class CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
          .withOpacity(0.15) // Garis halus
      ..strokeWidth = 1.0;

    // Garis dari pojok kiri atas ke kanan bawah
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    // Garis dari pojok kanan atas ke kiri bawah
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
