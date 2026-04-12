import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailLaporanDirekturPage extends StatelessWidget {
  final Map<String, dynamic> project;

  const DetailLaporanDirekturPage({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    // Sinkronisasi kolom 'created_at' dari database
    String tanggalDibuat = project['created_at'] != null
        ? DateFormat(
            'dd MMMM yyyy HH:mm',
          ).format(DateTime.parse(project['created_at']))
        : "-";

    final currency = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Sinkronisasi kolom 'items' (jsonb) dan 'foto_url' (text)
    List<dynamic> items = project['items'] ?? [];
    String? fotoUrl = project['foto_url']; // Di database-mu ini tipe text

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
          "DETAIL PROYEK",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header menggunakan 'nama_project'
            _buildHeader(tanggalDibuat),

            const SizedBox(height: 30),

            _buildSectionTitle("INFORMASI TRANSAKSI"),
            _buildInfoRow("Nama Pemesan", project['nama_pemesan'] ?? "-"),
            // Menggunakan kolom 'metode_bayar'
            _buildInfoRow(
              "Metode Pembayaran",
              project['metode_bayar'] ?? "Belum Diatur",
              isHighlight: true,
            ),
            _buildInfoRow("Status Bayar", project['status_bayar'] ?? "-"),

            const SizedBox(height: 30),

            _buildSectionTitle("RINCIAN BARANG"),
            _buildTableItems(items, currency),

            const SizedBox(height: 20),
            // Menggunakan kolom 'total_tagihan'
            _buildTotalTagihan(currency),

            const SizedBox(height: 30),

            _buildSectionTitle("DESKRIPSI & KETERANGAN"),
            Text(
              project['deskripsi'] ??
                  project['keterangan'] ??
                  "Tidak ada deskripsi.",
              style: const TextStyle(color: Colors.black87, height: 1.5),
            ),

            const SizedBox(height: 30),

            _buildSectionTitle("DOKUMENTASI FOTO"),
            fotoUrl == null || fotoUrl.isEmpty
                ? const Text(
                    "Belum ada foto dokumentasi.",
                    style: TextStyle(color: Colors.grey),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      fotoUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String tanggal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(color: Color(0xFFD4B07E)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project['nama_project']?.toString().toUpperCase() ?? "PROJECT",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Dibuat pada: $tanggal",
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ... (Widget helper _buildSectionTitle, _buildInfoRow, _buildTableItems sama seperti sebelumnya)

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black54,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isHighlight ? const Color(0xFFD4B07E) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableItems(List<dynamic> items, NumberFormat currency) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
      child: Column(
        children: [
          Container(
            color: Colors.black12,
            padding: const EdgeInsets.all(10),
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
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Harga",
                    textAlign: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text("Tidak ada item"),
            ),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(item['nama_item'] ?? item['nama'] ?? "-"),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      (item['jumlah'] ?? item['qty'] ?? 0).toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      currency.format(
                        int.tryParse(item['harga'].toString()) ?? 0,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalTagihan(NumberFormat currency) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Total Tagihan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          currency.format(project['total_tagihan'] ?? 0),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4B07E),
          ),
        ),
      ],
    );
  }
}
