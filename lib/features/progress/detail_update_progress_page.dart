import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class DetailProgressPage extends StatefulWidget {
  final Map<String, dynamic> projectData;
  const DetailProgressPage({super.key, required this.projectData});

  @override
  State<DetailProgressPage> createState() => _DetailProgressPageState();
}

class _DetailProgressPageState extends State<DetailProgressPage> {
  final supabase = Supabase.instance.client;
  bool isLoading = false;
  File? imageFile;

  // Status yang tersedia
  final List<String> statusOptions = [
    'Belum dikerjakan',
    'Sedang dikerjakan',
    'Selesai',
  ];

  // Map untuk menyimpan status tahapan
  late Map<String, String> progressStatus;

  // Definisi 7 Tahapan sesuai permintaan sebelumnya
  final List<Map<String, String>> tahapan = [
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

  @override
  void initState() {
    super.initState();
    // Proteksi Null: Jika data dari list utama kosong, set default ke 'Belum dikerjakan'
    progressStatus = {
      for (var t in tahapan)
        t['key']!:
            widget.projectData[t['key']]?.toString() ?? 'Belum dikerjakan',
    };
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<void> _updateProgress() async {
    // ANALISIS ID: Merujuk pada kolom 'id_project' sesuai gambar skema kamu
    final dynamic projectId = widget.projectData['id_project'];

    if (projectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: ID Proyek tidak ditemukan"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);

    try {
      String? imageUrl = widget.projectData['foto_url']?.toString() ?? "";

      // 1. Upload Foto jika ada yang baru
      if (imageFile != null) {
        final fileName =
            'img_${projectId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage
            .from('progress_images')
            .upload(fileName, imageFile!);
        imageUrl = supabase.storage
            .from('progress_images')
            .getPublicUrl(fileName);
      }

      // 2. Update data ke tabel 'projects'
      await supabase
          .from('projects')
          .update({
            'tahap_1': progressStatus['tahap_1'],
            'tahap_2': progressStatus['tahap_2'],
            'tahap_3': progressStatus['tahap_3'],
            'tahap_4': progressStatus['tahap_4'],
            'tahap_5': progressStatus['tahap_5'],
            'tahap_6': progressStatus['tahap_6'],
            'tahap_7': progressStatus['tahap_7'],
            'foto_url': imageUrl,
          })
          .eq('id_project', projectId); // Sesuaikan ID Project

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Progress Berhasil Diperbarui!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal Update: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.projectData['deskripsi']?.toString() ??
                        "Tidak ada deskripsi",
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // List Dropdown Tahapan
            ...tahapan.map(
              (t) => _buildStepCard(t['judul']!, t['sub']!, t['key']!),
            ),

            const SizedBox(height: 20),
            const Text(
              "TAMBAH GAMBAR PROGRESS",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Image Picker UI
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _buildImagePreview(),
              ),
            ),

            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _updateProgress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4B07E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "UPDATE PROGRESS",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(imageFile!, fit: BoxFit.cover),
      );
    } else if (widget.projectData['foto_url'] != null &&
        widget.projectData['foto_url'] != "") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(widget.projectData['foto_url'], fit: BoxFit.cover),
      );
    } else {
      return const Center(
        child: Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
      );
    }
  }

  Widget _buildStepCard(String judul, String sub, String key) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD4B07E).withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4B07E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(judul, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            sub,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: progressStatus[key],
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            items: statusOptions
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => progressStatus[key] = val);
            },
          ),
        ],
      ),
    );
  }
}
