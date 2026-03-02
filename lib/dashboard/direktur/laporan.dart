// import 'package:flutter/material.dart';
// import 'detaillaporan.dart'; // Pastikan import ini benar agar bisa ke detail

// class ListLaporanPage extends StatelessWidget {
//   // <--- Pastikan nama class ini sama dengan yang dipanggil
//   const ListLaporanPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final List<String> daftarLaporan = [
//       "LAPORAN JANUARI",
//       "LAPORAN FEBRUARI",
//       "LAPORAN MARET",
//       "LAPORAN APRIL",
//       "LAPORAN MEI",
//       "LAPORAN JUNI",
//     ];

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
//           "Lihat Laporan",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 24,
//           ),
//         ),
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(25),
//         itemCount: daftarLaporan.length,
//         itemBuilder: (context, index) {
//           final bool isEven = index % 2 == 0;
//           final Color cardColor = isEven
//               ? const Color(0xFFE0E0E0)
//               : const Color(0xFFD4B07E);
//           return GestureDetector(
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const DetailLaporanDirekturPage(),
//               ),
//             ),
//             child: Container(
//               margin: const EdgeInsets.only(bottom: 20),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: cardColor,
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     daftarLaporan[index],
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 5),
//                   const Text(
//                     "Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
//                     style: TextStyle(fontSize: 12),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ListLaporanPage extends StatefulWidget {
  const ListLaporanPage({super.key});

  @override
  State<ListLaporanPage> createState() => _ListLaporanPageState();
}

class _ListLaporanPageState extends State<ListLaporanPage> {
  final supabase = Supabase.instance.client;
  String selectedFilter = 'Bulanan'; // Default filter
  List<dynamic> laporanData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    try {
      setState(() => isLoading = true);
      // Mengambil data proyek yang sudah selesai/terbayar
      final data = await supabase
          .from('projects')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        laporanData = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "LAPORAN KEUANGAN",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
            fontFamily: 'Serif',
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Tombol Filter (Bulanan / Tahunan)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Row(
              children: [
                _buildFilterButton("Bulanan"),
                const SizedBox(width: 15),
                _buildFilterButton("Tahunan"),
              ],
            ),
          ),

          // 2. List Laporan
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD4B07E)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(25),
                    itemCount: laporanData.length,
                    itemBuilder: (context, index) {
                      final item = laporanData[index];
                      return _buildLaporanCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Widget Helper: Tombol Filter Minimalis
  Widget _buildFilterButton(String label) {
    bool isActive = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFD4B07E) : Colors.transparent,
          border: Border.all(color: const Color(0xFFD4B07E)),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // Widget Helper: Kartu Laporan Premium
  Widget _buildLaporanCard(Map<String, dynamic> data) {
    // Format tanggal
    String tanggal = data['created_at'] != null
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(data['created_at']))
        : "-";

    // Format Rupiah
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    String totalBayar = formatter.format(data['total_tagihan'] ?? 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sisi Kiri: Ornamen Gold dengan CrossPaint
            Container(
              width: 60,
              color: const Color(0xFFD4B07E),
              child: CustomPaint(painter: SmallCrossPainter()),
            ),
            // Sisi Kanan: Detail Data
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['nama_project']?.toString().toUpperCase() ??
                              "PROJECT",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          tanggal,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 25),
                    _buildRowInfo("Pemesan", data['nama_pemesan'] ?? "-"),
                    const SizedBox(height: 8),
                    _buildRowInfo("Total Bayar", totalBayar),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowInfo(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Painter untuk ornamen silang kecil di samping kartu
class SmallCrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
