import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/lihatLaporan/laporan.dart';
import 'features/backup/backup_page.dart';

class DashboardDirektur extends StatefulWidget {
  final String? namaDirektur;

  const DashboardDirektur({super.key, this.namaDirektur});

  @override
  State<DashboardDirektur> createState() => _DashboardDirekturState();
}

class _DashboardDirekturState extends State<DashboardDirektur> {
  final SupabaseClient supabase = Supabase.instance.client;

  int totalProyek = 0;
  int onProgress = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final allProjects = await supabase
          .from('projects')
          .select('status_bayar');

      final total = allProjects.length;
      final progress = allProjects.where((p) {
        final status = (p['status_bayar'] ?? '').toString().toLowerCase();
        return status != 'lunas';
      }).length;

      if (mounted) {
        setState(() {
          totalProyek = total;
          onProgress = progress;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetch stats: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayNama = widget.namaDirektur ?? "DIRECTOR";

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

              isLoading
                  ? const SizedBox(
                      height: 60,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFD4B07E),
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        _buildStatItem(
                          "Total Proyek",
                          totalProyek.toString().padLeft(2, '0'),
                        ),
                        const SizedBox(width: 20),
                        _buildStatItem(
                          "On Progress",
                          onProgress.toString().padLeft(2, '0'),
                        ),
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
                      imagePath: 'assets/images/laporan.jpg',
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
                  // ✅ Menu Backup menggantikan Monitoring
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      title: "Backup",
                      icon: Icons.cloud_download_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BackupPage(),
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
    String? imagePath,
    IconData? icon,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 0.65,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD4B07E),
                borderRadius: BorderRadius.circular(4),
              ),
              child: imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            CustomPaint(painter: CrossPainter()),
                      ),
                    )
                  : icon != null
                  ? Icon(icon, color: Colors.white.withOpacity(0.85), size: 40)
                  : CustomPaint(painter: CrossPainter()),
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
