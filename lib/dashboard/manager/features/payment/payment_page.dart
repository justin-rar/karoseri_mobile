import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detail_payment_page.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> projects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    try {
      if (mounted) setState(() => isLoading = true);

      // FILTER TAMBAHAN: Hanya ambil yang is_completed = false
      final data = await supabase
          .from('projects')
          .select()
          .eq(
            'is_completed',
            false,
          ) // Agar project yang sudah SELESAI tidak muncul lagi
          .order('nama_project', ascending: true);

      if (mounted) {
        setState(() {
          projects = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching projects: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Kelola Pembayaran",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4B07E)),
            )
          : projects.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchProjects,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  final bool isEven = index % 2 == 0;
                  final Color cardColor = isEven
                      ? const Color(0xFFD9D9D9)
                      : const Color(0xFFD4B07E);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailPaymentPage(project: project),
                        ),
                      ).then((value) {
                        // Jika kembali dari detail membawa nilai 'true', kita refresh list
                        if (value == true) {
                          _fetchProjects();
                        }
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 25,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  project['nama_project']
                                          ?.toString()
                                          .toUpperCase() ??
                                      "NAMA-PROJECT",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            project['deskripsi']?.toString() ??
                                "Deskripsi project tidak tersedia saat ini.",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.4,
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
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(height: 10),
          const Text(
            "Semua tagihan aktif sudah selesai.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          TextButton(
            onPressed: _fetchProjects,
            child: const Text(
              "Refresh",
              style: TextStyle(color: Color(0xFFD4B07E)),
            ),
          ),
        ],
      ),
    );
  }
}
