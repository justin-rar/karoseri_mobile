import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinishedProjectDetailPage extends StatelessWidget {
  final dynamic projectData;

  const FinishedProjectDetailPage({super.key, required this.projectData});

  @override
  Widget build(BuildContext context) {
    // Formatter untuk Rupiah
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    // Formatter untuk Tanggal (Contoh: 12 Jan 2024)
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return "-";
      try {
        DateTime dt = DateTime.parse(dateStr);
        return DateFormat('dd MMM yyyy').format(dt);
      } catch (e) {
        return dateStr.substring(0, 10);
      }
    }

    final List<dynamic> items = projectData['items'] ?? [];
    final double profitPercent =
        double.tryParse(projectData['profit_percentage']?.toString() ?? '0') ??
        0;
    final double totalTagihan =
        double.tryParse(projectData['total_tagihan']?.toString() ?? '0') ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Detail Project Selesai",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER STATUS ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "PROJECT INI TELAH SELESAI",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Status Pembayaran: ${projectData['status_bayar'] ?? 'Lunas'}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // --- INFO PELANGGAN & TANGGAL ---
            _buildSectionTitle("Informasi Proyek"),
            _buildInfoCard([
              _buildInfoRow(
                Icons.person,
                "Nama Pemesan",
                projectData['nama_pemesan'] ?? "-",
              ),
              _buildInfoRow(
                Icons.directions_car,
                "Nama Project",
                projectData['nama_project'] ?? "-",
              ),
              const Divider(),
              _buildInfoRow(
                Icons.calendar_today,
                "Tanggal Masuk",
                formatDate(projectData['created_at']),
              ),
              _buildInfoRow(
                Icons.event_available,
                "Tanggal Selesai",
                formatDate(projectData['updated_at']),
              ),
            ]),

            const SizedBox(height: 20),

            // --- DETAIL PEKERJAAN ---
            _buildSectionTitle("Keterangan"),
            _buildInfoCard([
              _buildInfoRow(
                Icons.description,
                "Deskripsi",
                projectData['deskripsi'] ?? "Tidak ada deskripsi",
              ),
            ]),

            const SizedBox(height: 20),

            // --- RINCIAN BAHAN & BIAYA ---
            _buildSectionTitle("Rincian Bahan & Biaya"),
            _buildInfoCard([
              const Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Item",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Qty",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Total",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),

              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "Tidak ada rincian bahan baku",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                ...items.map((item) {
                  double harga = double.tryParse(item['harga'].toString()) ?? 0;
                  int qty = int.tryParse(item['qty'].toString()) ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            item['nama_barang'] ?? "-",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            qty.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            currencyFormatter.format(harga * qty),
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

              const Divider(),
              _buildSummaryRow("Margin Keuntungan", "$profitPercent%"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TOTAL AKHIR",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      currencyFormatter.format(totalTagihan),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 40),
            // Tombol sudah dihapus sesuai permintaan
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black54,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFD4B07E)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
