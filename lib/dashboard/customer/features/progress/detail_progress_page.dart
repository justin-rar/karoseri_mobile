import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailProgressPage extends StatelessWidget {
  final Map<String, dynamic> project;
  const DetailProgressPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    // Logika Status Berdasarkan Database
    bool isLunas = project['status_bayar'] == 'Lunas';
    // Mengambil rentang tanggal: Tanggal Buat s/d Tanggal Jadi
    String rentangWaktu =
        "${_formatDate(project['tgl_buat'])} - ${_formatDate(project['tgl_jadi'])}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Lihat Progress",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- KARTU HEADER (COKELAT) ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFD4B07E), // Warna cokelat sesuai gambar
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Estimasi Selesai $rentangWaktu",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isLunas
                              ? "Pesanan Selesai"
                              : "Pesanan sedang dikerjakan",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  // DETAIL PESANAN (ABU-ABU)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0E0E0), // Warna abu-abu bawah
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Detail Pesanan",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Status: ${project['status_pengerjaan']}\n"
                          "Deskripsi: ${project['deskripsi'] ?? '-'}",
                          style: const TextStyle(fontSize: 13, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- FOTO PROGRES 1 ---
            _buildImageCard(project['foto_progres_1']),
            const SizedBox(height: 15),

            // --- FOTO PROGRES 2 ---
            _buildImageCard(project['foto_progres_2']),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(String? imageUrl) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFFD4B07E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: imageUrl != null && imageUrl.startsWith('http')
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl, fit: BoxFit.cover),
            )
          : const Center(
              child: Icon(Icons.image, size: 50, color: Colors.white),
            ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "?";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM', 'id_ID').format(dt);
    } catch (e) {
      return dateStr;
    }
  }
}
