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

  // Fungsi fetch data yang akan dipanggil saat inisialisasi & refresh manual
  Future<void> _fetchMyProjects() async {
    try {
      if (!mounted) return;
      setState(() => isLoading = true);

      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final data = await supabase
          .from('projects')
          .select()
          .eq('no_hp', user.userMetadata?['no_hp'] ?? '')
          .eq('is_completed', false)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          myProjects = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      if (mounted) setState(() => isLoading = false);
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
      // REFRESH INDICATOR: Agar bisa ditarik ke bawah (Force Refresh)
      body: RefreshIndicator(
        onRefresh: _fetchMyProjects, // Panggil fungsi fetch data lagi
        color: const Color(0xFFD4B07E),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFD4B07E)),
              )
            : myProjects.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                // Memastikan list bisa ditarik meski isinya sedikit
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: myProjects.length,
                itemBuilder: (context, index) {
                  final project = myProjects[index];

                  return GestureDetector(
                    onTap: () {
                      String hp = project['no_hp']?.toString() ?? '';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailProgressPage(noHpCustomer: hp),
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
                          const SizedBox(height: 10),
                          Text(
                            "Status: ${project['status_pengerjaan'] ?? 'Dalam Antrean'}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // PERSEN SUDAH DIHAPUS TOTAL DI SINI
                          const SizedBox(height: 5),
                          const Text(
                            "Ketuk untuk melihat detail tahapan",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
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
    return ListView(
      // Pakai ListView agar RefreshIndicator bisa jalan di layar kosong
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Icon(
          Icons.assignment_late_outlined,
          size: 80,
          color: Colors.grey,
        ),
        const Center(child: Text("Belum ada proyek yang sedang berjalan.")),
      ],
    );
  }
}
