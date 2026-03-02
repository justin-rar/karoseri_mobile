import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Import halaman detail baru kamu
import 'finished_project_detail_page.dart';

class FinishedProjectPage extends StatefulWidget {
  const FinishedProjectPage({super.key});

  @override
  State<FinishedProjectPage> createState() => _FinishedProjectPageState();
}

class _FinishedProjectPageState extends State<FinishedProjectPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> finishedProjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFinishedProjects();
  }

  Future<void> _fetchFinishedProjects() async {
    try {
      setState(() => isLoading = true);
      final data = await supabase
          .from('projects')
          .select()
          .eq('is_completed', true)
          .order('created_at', ascending: false);

      setState(() {
        finishedProjects = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetch finished projects: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _restoreToActive(dynamic projectId) async {
    try {
      await supabase
          .from('projects')
          .update({'is_completed': false})
          .eq('id_project', projectId);

      _fetchFinishedProjects();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Project dikembalikan ke daftar progres aktif 🔄"),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error restoring project: $e");
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
          "Project Selesai",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : finishedProjects.isEmpty
          ? const Center(child: Text("Belum ada project yang diselesaikan."))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: finishedProjects.length,
              itemBuilder: (context, index) {
                final project = finishedProjects[index];

                return Dismissible(
                  key: Key(project['id_project'].toString()),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await _showUndoDialog(
                      context,
                      project['nama_project'],
                    );
                  },
                  onDismissed: (direction) =>
                      _restoreToActive(project['id_project']),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.undo, color: Colors.white),
                        Text(
                          "Batal Selesai",
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  // SEKARANG BISA DIKLIK
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FinishedProjectDetailPage(projectData: project),
                        ),
                      );
                    },
                    child: _buildFinishedCard(project),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildFinishedCard(dynamic project) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  project['nama_project']?.toString().toUpperCase() ??
                      "PROJECT",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey,
              ), // Indikator bisa diklik
            ],
          ),
          const Divider(height: 25),
          Text(
            "Pelanggan: ${project['nama_pemesan'] ?? '-'}",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            "Keterangan: ${project['deskripsi'] ?? '-'}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              "STATUS: SELESAI",
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showUndoDialog(BuildContext context, String? name) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Batalkan Status?"),
        content: Text(
          "Yakin ingin memindahkan '$name' kembali ke daftar Update Progress?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("TIDAK"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "YA, PINDAHKAN",
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}
