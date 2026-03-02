// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';

// class DetailLaporanDirekturPage extends StatelessWidget {
//   const DetailLaporanDirekturPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_new,
//             color: Colors.black,
//             size: 30,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Detail Laporan",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 24,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(25),
//         child: Column(
//           children: [
//             // Bagian Teks Laporan
//             Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(15),
//                 //overflow: BoxOverflow.hidden,
//               ),
//               child: Column(
//                 children: [
//                   // Header Laporan (Abu-abu)
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(20),
//                     color: const Color(0xFFE0E0E0),
//                     child: const Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "NAMA-LAPORAN",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 5),
//                         Text(
//                           "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,",
//                           style: TextStyle(fontSize: 12),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Isi Laporan (Cokelat/Gold)
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(20),
//                     color: const Color(0xFFD4B07E),
//                     child: const Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "LAPORAN - xxxx",
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           "XXXXXXXXXXXXXXXXXXXXXXXXXXXX\nXXXXXXXXXXXXXXXXXXXXXXXXXXXX\nXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
//                         ),
//                         SizedBox(height: 15),
//                         Text(
//                           "LAPORAN - xxxx",
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         Text(
//                           "XXXXXXXXXXXXXXXXXXXXXXXXXXXX\nXXXXXXXXXXXXXXXXXXXXXXXXXXXX\nXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 30),

//             // Bagian Gambar (X-Box placeholder sesuai wireframe)
//             AspectRatio(
//               aspectRatio: 1,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFD4B07E),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: CustomPaint(painter: CrossPainter()),
//               ),
//             ),
//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Painter untuk silang di dalam kotak gambar
// class CrossPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.black38
//       ..strokeWidth = 1.0;
//     canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
//     canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailLaporanDirekturPage extends StatelessWidget {
  final Map<String, dynamic> project;

  const DetailLaporanDirekturPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    // Format Tanggal
    String tanggalDibuat = project['created_at'] != null
        ? DateFormat(
            'dd MMMM yyyy HH:mm',
          ).format(DateTime.parse(project['created_at']))
        : "-";

    // Format Rupiah Helper
    final currency = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Ambil list items dari JSON database
    List<dynamic> items = project['items'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "DETAIL TRANSAKSI",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Project (Gold Card)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(color: Color(0xFFD4B07E)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project['nama_project']?.toString().toUpperCase() ??
                        "PROJECT",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Dibuat pada: $tanggalDibuat",
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 2. Info Pelanggan
            _buildSectionTitle("INFORMASI PEMESAN"),
            _buildInfoRow("Nama Pemesan", project['nama_pemesan'] ?? "-"),
            _buildInfoRow("No. Telepon", project['no_hp'] ?? "-"),

            const SizedBox(height: 30),

            // 3. Rincian Kebutuhan Barang
            _buildSectionTitle("RINCIAN KEBUTUHAN BARANG"),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  // Header Tabel
                  Container(
                    color: Colors.black12,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Item",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            "Qty",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "Harga",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // List Item
                  ...items
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(item['nama'] ?? "-"),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  item['qty']?.toString() ?? "0",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  currency.format(
                                    int.tryParse(
                                          item['harga']?.toString().replaceAll(
                                                '.',
                                                '',
                                              ) ??
                                              '0',
                                        ) ??
                                        0,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 4. Total Pembayaran (Highlight)
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TOTAL TRANSAKSI",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    currency.format(project['total_tagihan'] ?? 0),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFFD4B07E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Widget Helper: Judul Section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.black54,
          fontSize: 12,
        ),
      ),
    );
  }

  // Widget Helper: Baris Informasi
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
