import 'package:flutter/material.dart';
import 'features/lihatLaporan/laporan.dart';

class DashboardDirektur extends StatelessWidget {
  final String? namaDirektur; // Pakai tanda tanya (?) agar boleh kosong

  const DashboardDirektur({super.key, this.namaDirektur});

  @override
  Widget build(BuildContext context) {
    // Jika namaDirektur null, pakai default "DIRECTOR"
    final displayNama = namaDirektur ?? "DIRECTOR";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "HELLO,\n$displayNama",
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -1,
                  color: Colors.black,
                  fontFamily: 'Serif',
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 25),

              const Text(
                "Selamat datang di pusat kendali strategis. Pantau efisiensi produksi dan validitas laporan karoseri secara real-time.",
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 40),

              Row(
                children: [
                  _buildStatItem("Total Proyek", "12"),
                  const SizedBox(width: 20),
                  _buildStatItem("On Progress", "05"),
                ],
              ),
              const SizedBox(height: 60),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: "Lihat Laporan",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ListLaporanPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: "Monitoring",
                      isLocked: true,
                      onTap: () {},
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

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD4B07E),
            ),
          ),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: Colors.black12),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 0.65,
            child: Container(
              decoration: BoxDecoration(
                color: isLocked ? Colors.grey[200] : const Color(0xFFD4B07E),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isLocked
                  ? const Icon(Icons.lock_outline, color: Colors.black26)
                  : CustomPaint(painter: CrossPainter()),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isLocked ? Colors.black38 : Colors.black,
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
      ..color = Colors.black.withOpacity(0.12)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
