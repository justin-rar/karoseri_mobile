import 'package:flutter/material.dart';
import 'detaillaporan.dart'; // Pastikan import ini benar agar bisa ke detail

class ListLaporanPage extends StatelessWidget {
  // <--- Pastikan nama class ini sama dengan yang dipanggil
  const ListLaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> daftarLaporan = [
      "LAPORAN JANUARI",
      "LAPORAN FEBRUARI",
      "LAPORAN MARET",
      "LAPORAN APRIL",
      "LAPORAN MEI",
      "LAPORAN JUNI",
    ];

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
          "Lihat Laporan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(25),
        itemCount: daftarLaporan.length,
        itemBuilder: (context, index) {
          final bool isEven = index % 2 == 0;
          final Color cardColor = isEven
              ? const Color(0xFFE0E0E0)
              : const Color(0xFFD4B07E);
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DetailLaporanDirekturPage(),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    daftarLaporan[index],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
