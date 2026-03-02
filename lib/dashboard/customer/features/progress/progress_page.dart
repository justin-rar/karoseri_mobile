import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detail_progress_page.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> myProjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyProjects();
  }

  Future<void> _fetchMyProjects() async {
    try {
      setState(() => isLoading = true);
      final user = supabase.auth.currentUser;

      if (user == null) return;

      // Filter berdasarkan nomor HP atau Email yang terdaftar di tabel projects
      // Sesuaikan dengan kolom identitas yang kamu gunakan di database
      final data = await supabase
          .from('projects')
          .select()
          .eq('no_hp', user.userMetadata?['no_hp'] ?? '')
          .eq('is_completed', false) // Hanya proyek yang masih berjalan
          .order('created_at', ascending: false);

      setState(() {
        myProjects = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching customer projects: $e");
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
        title: const Text(
          "Progress Proyek Saya",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4B07E)),
            )
          : myProjects.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchMyProjects,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: myProjects.length,
                itemBuilder: (context, index) {
                  final project = myProjects[index];
                  // Logika persentase progress (jika ada kolom progress di DB)
                  double progressVal =
                      double.tryParse(project['progress']?.toString() ?? '0') ??
                      0;

                  return GestureDetector(
                    onTap: () {
                      final dataProyek = project[index];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailProgressPage(project: dataProyek),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                project['nama_project']
                                        ?.toString()
                                        .toUpperCase() ??
                                    "PROYEK",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "Status: ${project['status_pengerjaan'] ?? 'Dalam Antrean'}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Progress Bar Visual
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progressVal / 100,
                              minHeight: 8,
                              backgroundColor: Colors.black12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFD4B07E),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "${progressVal.toInt()}%",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_late_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 15),
          const Text("Belum ada proyek yang sedang berjalan."),
        ],
      ),
    );
  }
}
