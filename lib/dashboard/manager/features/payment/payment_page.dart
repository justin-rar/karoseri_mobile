import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // Mengambil data project dari database Supabase
  Future<void> _fetchProjects() async {
    try {
      final data = await supabase
          .from('projects')
          .select()
          .order('nama_project', ascending: true);

      setState(() {
        projects = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
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
          ? const Center(child: Text("Data project tidak ditemukan."))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];

                // Logika warna selang-seling sesuai screenshot
                // Index genap (0, 2, 4) = Abu-abu terang
                // Index ganjil (1, 3, 5) = Krem/Coklat muda
                final bool isEven = index % 2 == 0;
                final Color cardColor = isEven
                    ? const Color(0xFFD9D9D9)
                    : const Color(0xFFD4B07E);

                return GestureDetector(
                  onTap: () {
                    // Navigasi ke halaman detail pembayaran (akan kita buat nanti)
                    print("Klik Project: ${project['nama_project']}");
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
                            letterSpacing: 1.2,
                          ),
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
    );
  }
}
