import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailProgressPage extends StatelessWidget {
  final Map<String, dynamic> project;
  const DetailProgressPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    // Ambil persentase progress
    double progressVal =
        double.tryParse(project['progress']?.toString() ?? '0') ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Detail Progress",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- NAMA & STATUS PROYEK ---
            Text(
              project['nama_project']?.toString().toUpperCase() ??
                  "DETAIL PROYEK",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD4B07E).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                project['status_pengerjaan'] ?? "Dalam Pengerjaan",
                style: const TextStyle(
                  color: Color(0xFF8D6E63),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- VISUAL PROGRESS CIRCLE ---
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: progressVal / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.black12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFD4B07E),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        "${progressVal.toInt()}%",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Selesai",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- RINCIAN INFORMASI ---
            _buildSectionTitle("Informasi Pengerjaan"),
            const SizedBox(height: 15),
            _buildDetailTile(
              Icons.calendar_month,
              "Tanggal Mulai",
              _formatDate(project['created_at']),
            ),
            _buildDetailTile(
              Icons.notes,
              "Keterangan Update",
              project['deskripsi'] ?? "Belum ada catatan update terbaru.",
            ),

            const SizedBox(height: 30),

            // --- ESTIMASI ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFD4B07E)),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "Tim kami sedang bekerja maksimal untuk menyelesaikan proyek Anda tepat waktu.",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
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

  // Helper untuk format tanggal
  String _formatDate(String? dateStr) {
    if (dateStr == null) return "-";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
