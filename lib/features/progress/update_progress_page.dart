import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateProgressPage extends StatefulWidget {
  const UpdateProgressPage({super.key});

  @override
  State<UpdateProgressPage> createState() => _UpdateProgressPageState();
}

class _UpdateProgressPageState extends State<UpdateProgressPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> projects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  // Fungsi untuk mengambil data project dari database
  Future<void> _fetchProjects() async {
    try {
      setState(() => isLoading = true);

      final data = await supabase
          .from('projects')
          .select()
          .order('created_at', ascending: false);

      // Log untuk memastikan data sampai di HP atau tidak
      debugPrint("Data dari Supabase: $data");

      setState(() {
        projects = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetch projects: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "Update Progress",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : projects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Belum ada project ditambahkan"),
                  TextButton(
                    onPressed: _fetchProjects,
                    child: const Text("Refresh"),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];

                // Logika warna selang-seling: Genap = Abu, Ganjil = Cokelat
                final bool isEven = index % 2 == 0;
                final Color cardColor = isEven
                    ? const Color(0xFFD9D9D9)
                    : const Color(0xFFD4B07E);

                return GestureDetector(
                  onTap: () {
                    debugPrint(
                      "Navigasi ke Detail Project: ${project['nama_project']}",
                    );
                    // TODO: Navigator ke DetailProgressPage
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project['nama_project']?.toString().toUpperCase() ??
                              "NAMA-PROJECT",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          project['deskripsi']?.toString() ??
                              "Tidak ada deskripsi untuk proyek ini.",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
