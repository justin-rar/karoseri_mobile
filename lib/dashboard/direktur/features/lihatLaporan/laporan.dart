import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Mengimpor file detail yang sudah kamu buat
import 'detaillaporan.dart';

class ListLaporanPage extends StatefulWidget {
  const ListLaporanPage({super.key});

  @override
  State<ListLaporanPage> createState() => _ListLaporanPageState();
}

class _ListLaporanPageState extends State<ListLaporanPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  String? selectedMonth;
  String? selectedYear;

  final List<String> months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final List<String> years = ['2024', '2025', '2026', '2027'];

  Stream<List<Map<String, dynamic>>> _getProjects() {
    var query = supabase.from('projects').select('*');

    // Filter logika menggunakan kolom 'tanggal' di Supabase
    if (selectedMonth != null && selectedYear != null) {
      int monthIdx = months.indexOf(selectedMonth!) + 1;
      String monthStr = monthIdx.toString().padLeft(2, '0');

      query = query
          .gte('tanggal', '$selectedYear-$monthStr-01')
          .lte('tanggal', '$selectedYear-$monthStr-31');
    }

    return query.order('created_at', ascending: false).asStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "LAPORAN PROYEK",
          style: TextStyle(
            fontFamily: 'Serif',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Bagian Filter Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Bulan',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedMonth,
                    items: months
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedMonth = val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Tahun',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedYear ?? '2026',
                    items: years
                        .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedYear = val),
                  ),
                ),
              ],
            ),
          ),

          // List Data Proyek dari Supabase
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getProjects(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD4B07E)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Tidak ada laporan pada periode ini."),
                  );
                }

                final projects = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final item = projects[index];
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        title: Text(
                          item['nama_project'] ?? 'Tanpa Nama',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          "Status: ${item['status_bayar'] ?? 'Pending'}",
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // PERBAIKAN: Menggunakan DetailLaporanDirekturPage dan parameter 'project'
                              builder: (context) =>
                                  DetailLaporanDirekturPage(project: item),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
