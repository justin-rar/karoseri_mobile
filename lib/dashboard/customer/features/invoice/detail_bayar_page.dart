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

  // URL Gambar QRIS Dummy (Kita simpan di variabel agar konsisten)
  final String qrisUrl =
      'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=DummyQrisKaroseriGacor';

  @override
  Widget build(BuildContext context) {
    // 1. Ambil data total tagihan
    double totalTagihan =
        double.tryParse(
          widget.projectData['total_tagihan']?.toString() ?? '0',
        ) ??
        0;

    // 2. Ambil rincian barang dari JSONB
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

    // Membaca metode bayar dari database
    String metodeBayar =
        widget.projectData['metode_bayar']?.toString().toLowerCase() ?? 'cash';

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
            // --- HEADER INFO PROYEK ---
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
                    "Metode Pembayaran: ${metodeBayar.toUpperCase()}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Status: ${isLunas ? 'LUNAS' : 'BELUM LUNAS'}",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- RINCIAN MATERIAL ---
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
                child: Text(
                  "Rincian belum tersedia.",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
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

            // --- TOTAL TAGIHAN ---
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
                  totalTagihan == 0
                      ? const Text(
                          "Sedang dihitung admin",
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.orange,
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

            // --- INSTRUKSI PEMBAYARAN BERDASARKAN METODE BAYAR ---
            if (!isLunas && totalTagihan > 0) ...[
              if (metodeBayar == 'leasing')
                _buildLeasingInstruction()
              else
                _buildCashInstructions(), // Bank & QRIS di sini

              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "*Silakan lampirkan bukti bayar ke WhatsApp Admin.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  "ex: NamaPemesan - Mandiri",
                  textAlign: TextAlign.center,
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
                  "*Menunggu kalkulasi harga dari admin.",
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

  // --- KUMPULAN WIDGET CASH (BANK & QRIS) ---
  Widget _buildCashInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pilihan Pembayaran Transfer Bank:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        _buildBankTile("MANDIRI", "123-456-7890", Colors.blue),
        const SizedBox(height: 10),
        _buildBankTile("BCA", "098-765-4321", Colors.blue.shade900),
        const SizedBox(height: 10),
        _buildBankTile("BRI", "5555-01-234567-89-0", Colors.blue.shade700),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Divider(),
        ),

        const Text(
          "Atau Bayar Instan pakai QRIS:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        Center(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                // --- PERBAIKAN: Tambahkan GestureDetector untuk Zoom ---
                GestureDetector(
                  onTap: () =>
                      _showZoomableQRIS(context), // Panggil fungsi zoom
                  child: Hero(
                    // Tambahkan animasi Hero agar transisi mulus
                    tag: 'qris_image',
                    child: Image.network(
                      qrisUrl, // Gunakan variabel URL
                      height: 180,
                      width: 180,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          height: 180,
                          width: 180,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.qr_code_2,
                        size: 150,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Ketuk gambar untuk memperbesar/zoom",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- FUNGSI UNTUK MENAMPILKAN DIALOG ZOOM QRIS ---
  void _showZoomableQRIS(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent, // Latar belakang transparan
        insetPadding: const EdgeInsets.all(
          10,
        ), // Jarak dialog dari pinggir layar
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Widget utama untuk Zoom (Pinch to Zoom)
            GestureDetector(
              onTap: () =>
                  Navigator.pop(context), // Ketuk di luar gambar untuk menutup
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black87, // Warna latar belakang gelap transparan
                child: InteractiveViewer(
                  panEnabled: true, // Bisa digeser
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4.0, // Maksimal zoom 4x
                  child: Hero(
                    tag:
                        'qris_image', // Tag harus sama dengan Hero di halaman utama
                    child: Image.network(
                      qrisUrl,
                      fit: BoxFit.contain, // Gambar muat di dalam layar
                    ),
                  ),
                ),
              ),
            ),
            // Tombol Tutup di pojok kanan atas
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Positioned(
              bottom: 40,
              child: Text(
                "Gunakan dua jari untuk memperbesar (zoom)",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET LIST BANK ---
  Widget _buildBankTile(String namaBank, String noRek, Color warna) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: warna.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: warna.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                namaBank,
                style: TextStyle(fontWeight: FontWeight.bold, color: warna),
              ),
              const SizedBox(height: 5),
              Text(
                noRek,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                "a/n Karoseri Gacor",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
            onPressed: () {
              // Contoh implementasi copy dummy
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Nomor Rekening $namaBank Berhasil Disalin!"),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- WIDGET INSTRUKSI LEASING ---
  Widget _buildLeasingInstruction() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_center, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                "Prosedur Pembayaran Leasing:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            "• Hubungi Admin Karoseri untuk pengajuan PO ke pihak Leasing.",
            style: TextStyle(fontSize: 13),
          ),
          SizedBox(height: 10),
          Text(
            "• Siapkan berkas identitas usaha/perorangan untuk survei dari Leasing.",
            style: TextStyle(fontSize: 13),
          ),
          SizedBox(height: 10),
          Text(
            "• Proses produksi akan dikerjakan setelah surat PO disetujui pihak Leasing.",
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
