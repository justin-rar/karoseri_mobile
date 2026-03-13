import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DetailProgressPage extends StatefulWidget {
  final String noHpCustomer;
  const DetailProgressPage({super.key, required this.noHpCustomer});

  @override
  State<DetailProgressPage> createState() => _DetailProgressPageState();
}

class _DetailProgressPageState extends State<DetailProgressPage> {
  // Masukkan daftar tahapan di sini agar rapi
  final List<Map<String, String>> daftarTahapan = [
    {
      'key': 'tahap_1',
      'judul': '1. Perencanaan & Desain',
      'sub': 'SKRB & Pembuatan Blueprint desain.',
    },
    {
      'key': 'tahap_2',
      'judul': '2. Persiapan Sasis',
      'sub': 'Pengecekan mesin & modifikasi sasis.',
    },
    {
      'key': 'tahap_3',
      'judul': '3. Pembuatan Rangka Bodi',
      'sub': 'Pengelasan rangka utama pipa besi/baja.',
    },
    {
      'key': 'tahap_4',
      'judul': '4. Pembuatan Bodi',
      'sub': 'Pemasangan plat bodi, kaca, dan pintu.',
    },
    {
      'key': 'tahap_5',
      'judul': '5. Pengecatan & Anti-Karat',
      'sub': 'Proses pengecatan oven & anti-karat.',
    },
    {
      'key': 'tahap_6',
      'judul': '6. Perakitan Interior/Eksterior',
      'sub': 'Pemasangan AC, kursi, dan kelistrikan.',
    },
    {
      'key': 'tahap_7',
      'judul': '7. Finishing & QC',
      'sub': 'Uji kebocoran & sertifikasi uji tipe.',
    },
  ];

  List<String> _parseImages(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return [];
    try {
      return rawUrl
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('"', '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Detail Progress",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('projects')
            .stream(primaryKey: ['id_project'])
            .eq('no_hp', widget.noHpCustomer),
        builder: (context, snapshot) {
          // 1. CEK LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4B07E)),
            );
          }

          // 2. CEK ERROR ATAU DATA KOSONG (Mencegah Crash)
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(
                    child: Text(
                      "Data project belum tersedia.\nSilakan tarik ke bawah untuk muat ulang.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          final project = snapshot.data!.first;
          final List<String> images = _parseImages(project['foto_url']);

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project['nama_project']?.toString().toUpperCase() ??
                        "PROYEK",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4B07E),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Foto Progres Terbaru",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  if (images.isEmpty)
                    _buildEmptyPhoto()
                  else
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 220,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: false,
                      ),
                      items: images
                          .map(
                            (url) => GestureDetector(
                              onTap: () => _showFullScreenImage(context, url),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Text("Gagal memuat gambar"),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                  const SizedBox(height: 30),
                  const Text(
                    "Alur Pengerjaan Karoseri",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 15),

                  // Mapping Tahapan 1-7
                  ...daftarTahapan.map((t) {
                    return _buildStepItem(
                      judul: t['judul']!,
                      sub: t['sub']!,
                      status: project[t['key']] ?? 'Belum dikerjakan',
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepItem({
    required String judul,
    required String sub,
    required String status,
  }) {
    Color color = status == 'Selesai'
        ? Colors.green
        : (status == 'Sedang dikerjakan' ? Colors.orangeAccent : Colors.grey);
    IconData icon = status == 'Selesai'
        ? Icons.check_circle
        : (status == 'Sedang dikerjakan'
              ? Icons.construction
              : Icons.radio_button_unchecked);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color == Colors.grey ? Colors.grey : Colors.black,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(child: InteractiveViewer(child: Image.network(url))),
        ),
      ),
    );
  }

  Widget _buildEmptyPhoto() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: Text(
          "Belum ada foto progres",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
