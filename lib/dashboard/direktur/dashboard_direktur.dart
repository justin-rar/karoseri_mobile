import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:karoseri_mobile/auth/login.dart'; // Import disamakan dengan dashboard customer
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

  // --- FUNGSI LOGOUT (DIUBAH AGAR PASTI BISA) ---
  Future<void> _handleLogout() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        // Menggunakan cara yang sama dengan Dashboard Customer
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saat keluar: $e")));
      }
    }
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
        child: Stack(
          children: [
            SingleChildScrollView(
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
                          icon: Icons
                              .assignment_outlined, // Menambah Logo agar tidak kosong
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
                  const SizedBox(height: 120),
                ],
              ),
            ),

            // --- TOMBOL LOGOUT MERAH DI BAWAH ---
            Positioned(
              bottom: 20,
              left: 30,
              right: 30,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  foregroundColor: Colors.redAccent,
                ),
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                label: const Text(
                  "LOGOUT ACCOUNT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari akun ini?"),
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
              child: Center(
                child: Icon(
                  icon ?? Icons.help_outline,
                  color: Colors.white.withOpacity(0.9),
                  size: 45,
                ),
              ),
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
