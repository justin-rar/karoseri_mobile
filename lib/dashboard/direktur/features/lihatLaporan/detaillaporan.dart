import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DetailLaporanDirekturPage extends StatelessWidget {
  final Map<String, dynamic> project;

  const DetailLaporanDirekturPage({super.key, required this.project});

  // Fungsi bantuan untuk mengubah data apa pun (String/int/double) menjadi double
  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Fungsi untuk memproses data foto dari berbagai format
  List<String> getImageList() {
    var rawFoto = project['foto_url'] ?? project['foto'];
    if (rawFoto == null || rawFoto.toString().trim().isEmpty) return [];

    if (rawFoto is List) {
      return rawFoto
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    if (rawFoto is String) {
      final str = rawFoto.trim();
      if (str.startsWith('[')) {
        try {
          final cleaned = str
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('"', '')
              .replaceAll("'", '');
          return cleaned
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        } catch (_) {}
      }
      return str
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  // Fungsi popup foto Full Screen
  void _showFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    String tanggalDibuat = project['created_at'] != null
        ? DateFormat(
            'dd MMMM yyyy HH:mm',
          ).format(DateTime.parse(project['created_at'].toString()))
        : "-";

    List<dynamic> items = project['items'] ?? [];
    List<String> images = getImageList();

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
            _buildHeader(tanggalDibuat),
            const SizedBox(height: 30),
            _buildSectionTitle("INFORMASI TRANSAKSI"),
            _buildInfoRow("Nama Pemesan", project['nama_pemesan'] ?? "-"),
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
            _buildTotalTagihan(currency),
            const SizedBox(height: 30),
            _buildSectionTitle("DESKRIPSI & KETERANGAN"),
            Text(
              project['deskripsi'] ??
                  project['keterangan'] ??
                  "Tidak ada deskripsi tambahan.",
              style: const TextStyle(color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle("DOKUMENTASI FOTO"),
            images.isEmpty
                ? const Text(
                    "Belum ada foto dokumentasi.",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  )
                : _buildCarousel(context, images),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel(BuildContext context, List<String> images) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 250.0,
        enlargeCenterPage: true,
        enableInfiniteScroll: images.length > 1,
        autoPlay: images.length > 1,
        viewportFraction: 0.9,
      ),
      items: images.map((url) {
        return GestureDetector(
          onTap: () => _showFullImage(context, url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: const Color(0xFFD4B07E),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: const Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeader(String tanggal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Color(0xFFD4B07E),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black54,
          fontSize: 11,
          letterSpacing: 1.1,
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
          ...items.map((item) {
            double harga = _parseToDouble(item['harga']);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      item['nama_barang'] ?? item['nama_item'] ?? "-",
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      (item['qty'] ?? item['jumlah'] ?? 0).toString(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      currency.format(harga),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTotalTagihan(NumberFormat currency) {
    double total = _parseToDouble(project['total_tagihan']);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Total Tagihan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          currency.format(total),
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
