import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detaillaporan.dart';

class ListLaporanPage extends StatefulWidget {
  const ListLaporanPage({super.key});

  @override
  State<ListLaporanPage> createState() => _ListLaporanPageState();
}

class _ListLaporanPageState extends State<ListLaporanPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  String? selectedMonth;
  // ✅ FIX: Default tahun diset ke 2026 agar langsung relevan
  String selectedYear = '2026';

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

  // ✅ FIX BUG #1 & #2: Pakai Future (bukan Stream) + kolom tgl_buat yang benar
  Future<List<Map<String, dynamic>>> _getProjects() async {
    var query = supabase.from('projects').select('*');

    if (selectedMonth != null) {
      int monthIdx = months.indexOf(selectedMonth!) + 1;
      String monthStr = monthIdx.toString().padLeft(2, '0');

      // ✅ FIX BUG #3: Hitung bulan berikutnya agar range tanggal akurat
      int nextMonth = monthIdx + 1;
      String nextYear = selectedYear;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear = (int.parse(selectedYear) + 1).toString();
      }
      String nextMonthStr = nextMonth.toString().padLeft(2, '0');

      // ✅ FIX BUG #2: Ganti 'tanggal' → 'tgl_buat' sesuai schema Supabase
      query = query
          .gte('tgl_buat', '$selectedYear-$monthStr-01')
          .lt('tgl_buat', '$nextYear-$nextMonthStr-01');
    }

    final result = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(result);
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
          // Filter Dropdown
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
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Semua Bulan'),
                      ),
                      ...months.map(
                        (m) => DropdownMenuItem(value: m, child: Text(m)),
                      ),
                    ],
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
                    value: selectedYear,
                    items: years
                        .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedYear = val);
                    },
                  ),
                ),
              ],
            ),
          ),

          // ✅ FIX BUG #1: Pakai FutureBuilder dengan key unik agar
          //    rebuild otomatis setiap kali filter berubah
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              key: ValueKey('$selectedMonth-$selectedYear'),
              future: _getProjects(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD4B07E)),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Terjadi kesalahan: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
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
