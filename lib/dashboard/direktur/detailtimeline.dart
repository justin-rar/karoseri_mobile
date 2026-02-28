import 'package:flutter/material.dart';
import 'laporan.dart';

class DetailTimelineDirekturPage extends StatelessWidget {
  final Map<String, dynamic> projectData;

  const DetailTimelineDirekturPage({super.key, required this.projectData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Timeline",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // Kontainer Utama Detail
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                //overflow: BoxOverflow.hidden,
              ),
              child: Column(
                children: [
                  // Header (Abu-abu)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    color: const Color(0xFFE0E0E0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          projectData['title'] ?? "NAMA-PROJECT",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Isi Detail & Persetujuan (Cokelat/Gold)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    color: const Color(0xFFD4B07E),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "LAPORAN- xxxx\nXXXXXXXXXXXXXXXXXXXXXXXXXXXX\nXXXXXXXXXXXXXXXXXXXXXXXXXXXX\nXXXXXXXXXXXXXXXXXXXXXXXXXXXX\nXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
                            style: TextStyle(height: 1.5),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "PERSETUJUAN",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Tombol SETUJU
                            _buildActionButton("SETUJU", Colors.green, () {
                              debugPrint("Proyek Disetujui");
                            }),
                            // Tombol TOLAK
                            _buildActionButton("TOLAK", Colors.red, () {
                              debugPrint("Proyek Ditolak");
                            }),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
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

  // Helper Widget untuk Tombol
  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.black, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ), // Kotak sesuai gambar
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
