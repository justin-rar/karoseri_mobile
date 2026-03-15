import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DetailBayarPage extends StatefulWidget {
  final Map<String, dynamic> projectData;

  const DetailBayarPage({super.key, required this.projectData});

  @override
  State<DetailBayarPage> createState() => _DetailBayarPageState();
}

class _DetailBayarPageState extends State<DetailBayarPage> {
  final supabase = Supabase.instance.client;

  // Formatter Mata Uang Rupiah
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    // Ambil ID Project dari data yang dikirim halaman sebelumnya
    final idProject = widget.projectData['id_project'];

    // Ambil Total Tagihan (data dari tabel projects)
    double totalTagihan =
        double.tryParse(
          widget.projectData['total_tagihan']?.toString() ?? '0',
        ) ??
        0;

    // Cek Status Pembayaran
    bool isLunas =
        widget.projectData['status_bayar']?.toString().toLowerCase() == 'lunas';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Detail Pembayaran",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFD4B07E), // Warna coklat muda karoseri
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.projectData['nama_project']
                            ?.toString()
                            .toUpperCase() ??
                        "PROJECT",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Divider(color: Colors.white54),
                  const SizedBox(height: 5),
                  Text(
                    "Pemesanan Atas Nama: ${widget.projectData['nama_pemesan'] ?? '-'}",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Status: ${isLunas ? 'LUNAS' : 'BELUM LUNAS'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- TABEL RINCIAN BARANG ---
            const Text(
              "RINCIAN MATERIAL & JASA",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 15),

            // Mengambil data item dari tabel projects_item
            FutureBuilder<List<Map<String, dynamic>>>(
              future: supabase
                  .from('projects_item')
                  .select()
                  .eq('id_project', idProject),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        color: Color(0xFFD4B07E),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        "Rincian barang belum tersedia.",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                }

                final items = snapshot.data!;

                return Column(
                  children: [
                    // Header Baris
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              "Barang",
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
                              "Total",
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // List Item
                    ...items.map((item) {
                      // Nama kolom sesuai gambar database: nama_item, harga, jumlah
                      String nama = item['nama_item']?.toString() ?? "Item";
                      double harga =
                          double.tryParse(item['harga']?.toString() ?? '0') ??
                          0;
                      int qty =
                          int.tryParse(item['jumlah']?.toString() ?? '0') ?? 0;
                      double subtotal = harga * qty;

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black12,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 3, child: Text(nama)),
                            Expanded(
                              flex: 1,
                              child: Text(
                                qty.toString(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                formatter.format(subtotal),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),

            const SizedBox(height: 25),

            // --- TOTAL AKHIR ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TOTAL TAGIHAN",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatter.format(totalTagihan),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4B07E),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- INSTRUKSI PEMBAYARAN (Hanya muncul jika belum lunas) ---
            if (!isLunas) ...[
              _buildPaymentInfo(),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "*Silahkan lampirkan bukti transfer ke Admin via WhatsApp.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Transfer Pembayaran:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Bank Mandiri",
            style: TextStyle(fontSize: 12, color: Colors.blue),
          ),
          Text(
            "123-456-7890",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          Text("a/n Karoseri Bus Wisata", style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
