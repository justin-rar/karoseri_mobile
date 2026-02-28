// import 'package:flutter/material.dart';
// import 'detailtimeline.dart';

// class TimelineDirekturPage extends StatelessWidget {
//   const TimelineDirekturPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Simulasi data dari database
//     final List<Map<String, dynamic>> projects = [
//       {'title': 'NAMA-PROJECT', 'color': const Color(0xFFE0E0E0)}, // Abu-abu
//       {
//         'title': 'NAMA-PROJECT',
//         'color': const Color(0xFFD4B07E),
//       }, // Cokelat/Gold
//       {'title': 'NAMA-PROJECT', 'color': const Color(0xFFE0E0E0)},
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
//           "Lihat Timeline",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 24,
//           ),
//         ),
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(25),
//         itemCount: projects.length,
//         itemBuilder: (context, index) {
//           return Container(
//             margin: const EdgeInsets.only(bottom: 20),
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: projects[index]['color'],
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   projects[index]['title'],
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.1,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,",
//                   style: TextStyle(fontSize: 13, height: 1.4),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
// Import halaman detail timeline yang kita buat tadi
import 'detailtimeline.dart';

class TimelineDirekturPage extends StatelessWidget {
  const TimelineDirekturPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulasi data dari database
    final List<Map<String, dynamic>> projects = [
      {
        'title': 'PROJECT KAROSERI BUS A',
        'color': const Color(0xFFE0E0E0),
        'deskripsi': 'Pengerjaan bodi utama dan interior kelas eksekutif.',
      },
      {
        'title': 'RESTORASI TRUK B',
        'color': const Color(0xFFD4B07E),
        'deskripsi': 'Pengecatan ulang dan perbaikan sasis rangka bawah.',
      },
      {
        'title': 'MODIFIKASI AMBULANS C',
        'color': const Color(0xFFE0E0E0),
        'deskripsi': 'Pemasangan alat medis dan kelistrikan darurat.',
      },
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
          "Lihat Timeline",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(25),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];

          return GestureDetector(
            // Navigasi ke Detail saat kartu diklik
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetailTimelineDirekturPage(projectData: project),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: project['color'],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project['title'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    project['deskripsi'] ??
                        "Klik untuk melihat detail progres dan persetujuan proyek ini.",
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 15),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Lihat Detail >",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
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
