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

  // List menampung gambar baru (lokal) & gambar lama (URL)
  List<File> selectedImages = [];
  List<String> existingUrls = [];

  final List<String> statusOptions = [
    'Belum dikerjakan',
    'Sedang dikerjakan',
    'Selesai',
  ];
  late Map<String, String> progressStatus;

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
    // Load status dropdown dari database
    progressStatus = {
      for (var t in tahapan)
        t['key']!:
            widget.projectData[t['key']]?.toString() ?? 'Belum dikerjakan',
    };

    // Load URL foto lama, pecah String jadi List
    String urls = widget.projectData['foto_url']?.toString() ?? "";
    if (urls.isNotEmpty) {
      existingUrls = urls.split(',');
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedList = await ImagePicker().pickMultiImage(
      imageQuality: 50,
    );
    if (pickedList.isNotEmpty) {
      setState(() {
        selectedImages.addAll(pickedList.map((x) => File(x.path)).toList());
      });
    }
  }

  // Fungsi hapus foto yang baru dipilih (sebelum upload)
  void _removeSelectedImage(int index) {
    setState(() => selectedImages.removeAt(index));
  }

  // Fungsi hapus foto yang sudah ada di database
  void _removeExistingImage(int index) {
    setState(() => existingUrls.removeAt(index));
  }

  Future<void> _updateProgress() async {
    final dynamic projectId = widget.projectData['id_project'];
    if (projectId == null) return;

    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);

    try {
      List<String> newUploadedUrls = [];

      // 1. Upload foto-foto baru ke Storage
      for (File image in selectedImages) {
        final fileName =
            'img_${projectId}_${DateTime.now().microsecondsSinceEpoch}.jpg';
        await supabase.storage.from('progress_images').upload(fileName, image);
        final String publicUrl = supabase.storage
            .from('progress_images')
            .getPublicUrl(fileName);
        newUploadedUrls.add(publicUrl);
      }

      // 2. Gabungkan yang lama (setelah mungkin ada yang dihapus) & yang baru
      List<String> finalUrls = [...existingUrls, ...newUploadedUrls];
      String joinedUrls = finalUrls.join(',');

      // 3. Update Status & Galeri ke Database
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
            'foto_url': joinedUrls,
          })
          .eq('id_project', projectId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Berhasil memperbarui data!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Update Error: $e");
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
          "Update Progres",
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
            // Header
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
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.projectData['deskripsi']?.toString() ??
                        "Tidak ada deskripsi",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Dropdowns
            const Text(
              "STATUS TAHAPAN",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...tahapan.map(
              (t) => _buildStepCard(t['judul']!, t['sub']!, t['key']!),
            ),

            const SizedBox(height: 25),

            // Gallery Grid
            const Text(
              "GALERI FOTO PROGRESS",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: existingUrls.length + selectedImages.length + 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_a_photo, color: Colors.grey),
                    ),
                  );
                }

                int i = index - 1;
                if (i < existingUrls.length) {
                  return _buildPhotoTile(
                    existingUrls[i],
                    isNetwork: true,
                    onRemove: () => _removeExistingImage(i),
                  );
                } else {
                  int fileIdx = i - existingUrls.length;
                  return _buildPhotoTile(
                    selectedImages[fileIdx],
                    isNetwork: false,
                    onRemove: () => _removeSelectedImage(fileIdx),
                  );
                }
              },
            ),

            const SizedBox(height: 35),
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
                        "SIMPAN PERUBAHAN",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoTile(
    dynamic source, {
    required bool isNetwork,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: isNetwork
                ? Image.network(source as String, fit: BoxFit.cover)
                : Image.file(source as File, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard(String judul, String sub, String key) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD4B07E).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD4B07E).withOpacity(0.3)),
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
