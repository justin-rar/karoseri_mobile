import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 1. Import Supabase

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final supabase = Supabase.instance.client; // 2. Inisialisasi client

  List<Map<String, dynamic>> listBarang = [
    {"nama": "", "jumlah": ""},
  ];

  // 3. FUNGSI SIMPAN KE DATABASE
  Future<void> _simpanKeDatabase() async {
    try {
      // Tampilkan Loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Siapkan data agar sesuai dengan nama kolom di Supabase
      // Kita filter juga agar baris yang kosong tidak ikut tersimpan
      final dataToSave = listBarang
          .where((item) => item['nama'].toString().isNotEmpty)
          .map(
            (item) => {
              'nama_barang': item['nama'],
              'stok': int.tryParse(item['jumlah'].toString()) ?? 0,
            },
          )
          .toList();

      if (dataToSave.isEmpty) {
        Navigator.pop(context); // Tutup loading
        return;
      }

      // 4. Eksekusi Insert ke tabel 'inventory'
      await supabase.from('inventory').insert(dataToSave);

      if (mounted) {
        Navigator.pop(context); // Tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Stok Berhasil Diperbarui!")),
        );
        // Opsi: Kosongkan list atau kembali ke halaman sebelumnya
        setState(() {
          listBarang = [
            {"nama": "", "jumlah": ""},
          ];
        });
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Tutup loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e")));
    }
  }

  void _tambahBaris() {
    setState(() {
      listBarang.add({"nama": "", "jumlah": ""});
    });
  }

  void _hapusBaris(int index) {
    if (listBarang.length > 1) {
      setState(() {
        listBarang.removeAt(index);
      });
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
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Kelola Stock",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    color: const Color(0xFFD4B07E),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Text(
                              "nama barang",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text(
                              "jumlah",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(width: 40),
                      ],
                    ),
                  ),
                  // Body (List Input)
                  ...listBarang.asMap().entries.map((entry) {
                    int index = entry.key;
                    return Container(
                      decoration: BoxDecoration(
                        color: index % 2 == 1 ? Colors.grey[200] : Colors.white,
                        border: const Border(
                          top: BorderSide(color: Colors.black),
                        ),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: "Ketik nama...",
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (val) =>
                                      listBarang[index]['nama'] = val,
                                ),
                              ),
                            ),
                            Container(width: 1, color: Colors.black),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: "0",
                                  border: InputBorder.none,
                                ),
                                onChanged: (val) =>
                                    listBarang[index]['jumlah'] = val,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () => _hapusBaris(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            // Tombol Tambah
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _tambahBaris,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4B07E),
                    border: const Border(
                      left: BorderSide(color: Colors.black),
                      right: BorderSide(color: Colors.black),
                      bottom: BorderSide(color: Colors.black),
                    ),
                  ),
                  child: const Icon(Icons.add, size: 30, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // 5. Tombol Simpan Terhubung ke Fungsi
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _simpanKeDatabase, // Panggil fungsi di sini
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4B07E),
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  "SIMPAN PERUBAHAN",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
