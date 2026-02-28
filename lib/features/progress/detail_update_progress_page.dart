import 'dart:io';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
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

  // List untuk menampung banyak file baru
  List<XFile> selectedImages = [];
  // List untuk menampung URL foto yang sudah ada di database
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
    // Inisialisasi status progres
    progressStatus = {
      for (var t in tahapan)
        t['key']!:
            widget.projectData[t['key']]?.toString() ?? 'Belum dikerjakan',
    };

    // Ambil data foto lama (asumsikan database menyimpan array)
    if (widget.projectData['foto_url'] != null) {
      if (widget.projectData['foto_url'] is List) {
        existingUrls = List<String>.from(widget.projectData['foto_url']);
      } else {
        existingUrls = [widget.projectData['foto_url'].toString()];
      }
    }
  }

  // Fungsi pilih banyak gambar
  Future<void> _pickMultiImages() async {
    final List<XFile> picked = await ImagePicker().pickMultiImage(
      imageQuality: 50,
    );
    if (picked.isNotEmpty) {
      setState(() => selectedImages.addAll(picked));
    }
  }

  Future<void> _updateProgress() async {
    final dynamic projectId = widget.projectData['id_project'];
    if (projectId == null) return;

    setState(() => isLoading = true);

    try {
      List<String> allUrls = [...existingUrls];

      // Upload file-file baru satu per satu
      for (var image in selectedImages) {
        final fileExt = image.name.split('.').last;
        final fileName =
            'img_${projectId}_${DateTime.now().microsecondsSinceEpoch}.$fileExt';

        // Baca file sebagai bytes agar support WEB
        final bytes = await image.readAsBytes();

        await supabase.storage
            .from('progress_images')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: FileOptions(contentType: 'image/$fileExt'),
            );

        final url = supabase.storage
            .from('progress_images')
            .getPublicUrl(fileName);
        allUrls.add(url);
      }

      // Update tabel dengan ARRAY of URLs
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
            'foto_url': allUrls, // Mengirim List/Array
          })
          .eq('id_project', projectId);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Berhasil Update!")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Update Multi-Photo")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ...tahapan.map(
              (t) => _buildStepCard(t['judul']!, t['sub']!, t['key']!),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "DOKUMENTASI FOTO",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            // Grid View untuk menampilkan banyak foto
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: existingUrls.length + selectedImages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: _pickMultiImages,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_a_photo_outlined),
                    ),
                  );
                }

                int adjustedIndex = index - 1;
                if (adjustedIndex < existingUrls.length) {
                  // Foto dari Database
                  return _buildImageItem(
                    existingUrls[adjustedIndex],
                    isNetwork: true,
                  );
                } else {
                  // Foto yang baru dipilih (Preview)
                  int fileIndex = adjustedIndex - existingUrls.length;
                  return _buildImageItem(
                    selectedImages[fileIndex].path,
                    isNetwork: false,
                    file: selectedImages[fileIndex],
                  );
                }
              },
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _updateProgress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4B07E),
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("SIMPAN SEMUA"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(String path, {required bool isNetwork, XFile? file}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: isNetwork
              ? Image.network(
                  path,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : (kIsWeb
                    ? Image.network(
                        path,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ) // Image.network di web support blob path
                    : Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isNetwork)
                  existingUrls.remove(path);
                else
                  selectedImages.remove(file);
              });
            },
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 15, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard(String judul, String sub, String key) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(
          judul,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: DropdownButton<String>(
          value: progressStatus[key],
          isExpanded: true,
          items: statusOptions
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) => setState(() => progressStatus[key] = val!),
        ),
      ),
    );
  }
}
