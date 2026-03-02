import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detail_update_progress_page.dart';

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

  Future<void> _fetchProjects() async {
    try {
      setState(() => isLoading = true);

      // Filter: Hanya ambil project yang aktif (is_completed = false)
      final data = await supabase
          .from('projects')
          .select()
          .eq('is_completed', false)
          .order('created_at', ascending: false);

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
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                // Murni memanggil kartu proyek tanpa fitur geser/slide
                return _buildProjectCard(project, index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Belum ada project aktif"),
          TextButton(onPressed: _fetchProjects, child: const Text("Refresh")),
        ],
      ),
    );
  }

  Widget _buildProjectCard(dynamic project, int index) {
    final bool isEven = index % 2 == 0;
    final Color cardColor = isEven
        ? const Color(0xFFD9D9D9)
        : const Color(0xFFD4B07E);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailProgressPage(projectData: project),
          ),
        ).then((value) => _fetchProjects());
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project['nama_project']?.toString().toUpperCase() ??
                        "NAMA PROJECT",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              project['deskripsi']?.toString() ?? "Tidak ada deskripsi.",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
