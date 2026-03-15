import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class DetailBayarPage extends StatefulWidget {
  final Map<String, dynamic> projectData;

  const DetailBayarPage({super.key, required this.projectData});

  @override
  State<DetailBayarPage> createState() => _DetailBayarPageState();
}

class _DetailBayarPageState extends State<DetailBayarPage> {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    // 1. Ambil data total tagihan
    double totalTagihan =
        double.tryParse(
          widget.projectData['total_tagihan']?.toString() ?? '0',
        ) ??
        0;

    // 2. Ambil rincian barang dari kolom 'items' (JSONB)
    List<dynamic> items = [];
    if (widget.projectData['items'] != null) {
      if (widget.projectData['items'] is List) {
        items = widget.projectData['items'];
      } else if (widget.projectData['items'] is String) {
        items = jsonDecode(widget.projectData['items']);
      }
    }

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
            // --- HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFD4B07E),
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

            // --- RINCIAN BARANG ---
            const Text(
              "RINCIAN MATERIAL & JASA",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 15),

            if (items.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Rincian barang belum tersedia.",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  _buildTableHeader(),
                  ...items.map((item) {
                    String nama =
                        item['nama']?.toString() ??
                        (item['nama_barang']?.toString() ?? "Item");
                    double harga =
                        double.tryParse(item['harga']?.toString() ?? '0') ?? 0;
                    int qty = int.tryParse(item['qty']?.toString() ?? '0') ?? 0;
                    double subtotal = harga * qty;

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12, width: 0.5),
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
                              // Jika harga 0, tampilkan strip
                              harga == 0 ? "-" : formatter.format(subtotal),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),

            const SizedBox(height: 25),

            // --- TOTAL AKHIR (BAGIAN YANG DIPERBAIKI) ---
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
                  // Logika: Jika total 0, tampilkan teks "Sedang dihitung admin"
                  totalTagihan == 0
                      ? const Text(
                          "Sedang dihitung admin",
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Text(
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

            // --- INFO PEMBAYARAN ---
            // Hanya muncul jika tagihan sudah ada (> 0) dan belum lunas
            if (!isLunas && totalTagihan > 0) ...[
              _buildPaymentInfo(),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "*Silahkan lampirkan bukti transfer ke Admin.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ] else if (!isLunas && totalTagihan == 0) ...[
              const Center(
                child: Text(
                  "*Tagihan Anda sedang diproses oleh admin.\nMohon cek kembali secara berkala.",
                  textAlign: TextAlign.center,
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

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
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
