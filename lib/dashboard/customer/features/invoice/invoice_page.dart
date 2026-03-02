import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> myInvoices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  Future<void> _fetchInvoices() async {
    try {
      setState(() => isLoading = true);
      final user = supabase.auth.currentUser;

      if (user == null) return;

      // Ambil data berdasarkan no_hp yang ada di metadata user
      final data = await supabase
          .from('projects')
          .select()
          .eq('no_hp', user.userMetadata?['no_hp'] ?? '')
          .order('created_at', ascending: false);

      setState(() {
        myInvoices = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching invoices: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Tagihan Saya",
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
          : myInvoices.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _fetchInvoices,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: myInvoices.length,
                itemBuilder: (context, index) {
                  final item = myInvoices[index];
                  double total =
                      double.tryParse(
                        item['total_tagihan']?.toString() ?? '0',
                      ) ??
                      0;
                  String status = item['status_bayar'] ?? "Belum Lunas";

                  // Format Tanggal yang aman
                  String formattedDate = "-";
                  if (item['created_at'] != null) {
                    try {
                      formattedDate = DateFormat(
                        'dd MMM yyyy',
                      ).format(DateTime.parse(item['created_at']));
                    } catch (e) {
                      formattedDate = item['created_at'].toString().substring(
                        0,
                        10,
                      );
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['nama_project']
                                          ?.toString()
                                          .toUpperCase() ??
                                      "PROJECT",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: status.toLowerCase() == 'lunas'
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ), // <-- PERBAIKAN: Gunakan ) bukan ]
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: status.toLowerCase() == 'lunas'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Tagihan",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              currencyFormatter.format(total),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFFD4B07E),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("Tidak ada riwayat tagihan."));
  }
}
