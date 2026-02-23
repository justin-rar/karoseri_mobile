import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final supabase = Supabase.instance.client;

  // List untuk baris input baru
  List<Map<String, dynamic>> listBarang = [
    {"nama": "", "jumlah": ""},
  ];

  // List untuk menampung data yang ditarik dari database
  List<dynamic> inventoryData = [];
  bool isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _ambilDataDariDatabase(); // Ambil data saat halaman pertama kali dibuka
  }

  // --- 1. FUNGSI AMBIL DATA DARI DATABASE ---
  Future<void> _ambilDataDariDatabase() async {
    try {
      final data = await supabase
          .from('inventory')
          .select()
          .order('id', ascending: false); // Data terbaru muncul di atas

      setState(() {
        inventoryData = data;
        isLoadingData = false;
      });
    } catch (e) {
      debugPrint("Error ambil data: $e");
      setState(() => isLoadingData = false);
    }
  }

  // --- 2. FUNGSI SIMPAN KE DATABASE ---
  Future<void> _simpanKeDatabase() async {
    try {
      // Tampilkan Loading Spinner
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Filter data agar baris kosong tidak ikut terkirim
      final dataToSave = listBarang
          .where((item) => item['nama'].toString().trim().isNotEmpty)
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

      // Eksekusi Insert ke tabel 'inventory'
      await supabase.from('inventory').insert(dataToSave);

      if (mounted) {
        Navigator.pop(context); // Tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Stok Berhasil Disimpan!")),
        );

        // Reset form input ke awal
        setState(() {
          listBarang = [
            {"nama": "", "jumlah": ""},
          ];
        });

        // Ambil data ulang agar daftar di HP langsung terupdate
        _ambilDataDariDatabase();
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "INPUT STOCK BARU",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),

            // --- TABEL INPUT ---
            _buildInputTable(),

            const SizedBox(height: 30),

            // --- TOMBOL SIMPAN ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _simpanKeDatabase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4B07E),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.black),
                  ),
                ),
                child: const Text(
                  "SIMPAN PERUBAHAN",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 40),
            const Divider(color: Colors.black45, thickness: 1),
            const SizedBox(height: 20),

            const Text(
              "DAFTAR STOK TERSEDIA (DATABASE)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),

            // --- DAFTAR DATA DARI DATABASE ---
            _buildDisplayTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputTable() {
    return Column(
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: Column(
            children: [
              // Header Tabel
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
              // Body Input Dinamis
              ...listBarang.asMap().entries.map((entry) {
                int index = entry.key;
                return Container(
                  decoration: BoxDecoration(
                    color: index % 2 == 1 ? Colors.grey[200] : Colors.white,
                    border: const Border(top: BorderSide(color: Colors.black)),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
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
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: _tambahBaris,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFD4B07E),
                border: Border(
                  left: BorderSide(color: Colors.black),
                  right: BorderSide(color: Colors.black),
                  bottom: BorderSide(color: Colors.black),
                ),
              ),
              child: const Icon(Icons.add, size: 30, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET UNTUK MENAMPILKAN DATA (PRINT KE HP) ---
  Widget _buildDisplayTable() {
    if (isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (inventoryData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("Belum ada data di database."),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: inventoryData.map((item) {
          return Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['nama_barang'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      "Status: Tersedia",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${item['stok']} Unit",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
