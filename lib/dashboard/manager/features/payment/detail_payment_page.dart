import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DetailPaymentPage extends StatefulWidget {
  final Map<String, dynamic> project;
  const DetailPaymentPage({super.key, required this.project});

  @override
  State<DetailPaymentPage> createState() => _DetailPaymentPageState();
}

class _DetailPaymentPageState extends State<DetailPaymentPage> {
  final supabase = Supabase.instance.client;
  final profitController = TextEditingController();

  String formatIDR(dynamic nominal) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(nominal);
  }

  List<dynamic> items = [];
  double subtotal = 0;
  double profitPercent = 0;
  double totalTagihan = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    items = widget.project['items'] ?? [];
    _calculateSubtotal();

    if (widget.project['profit_percentage'] != null) {
      profitPercent =
          double.tryParse(widget.project['profit_percentage'].toString()) ?? 0;
      profitController.text = profitPercent.toString();
      _calculateTotal();
    }
  }

  void _calculateSubtotal() {
    double tempSubtotal = 0;
    for (var item in items) {
      double harga = double.tryParse(item['harga'].toString()) ?? 0;
      int qty = int.tryParse(item['qty'].toString()) ?? 0;
      tempSubtotal += (harga * qty);
    }
    setState(() {
      subtotal = tempSubtotal;
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    double profitAmount = subtotal * (profitPercent / 100);
    setState(() {
      totalTagihan = subtotal + profitAmount;
    });
  }

  // --- FUNGSI UTAMA: KONFIRMASI PEMBAYARAN & SELESAI ---
  Future<void> _konfirmasiDanSelesaikan() async {
    setState(() => isLoading = true);
    try {
      await supabase
          .from('projects')
          .update({
            'profit_percentage': profitPercent,
            'total_tagihan': totalTagihan,
            'status_bayar': 'Lunas', // Status berubah jadi Lunas
            'is_completed': true, // Project pindah ke menu 'Project Selesai'
          })
          .eq('id_project', widget.project['id_project']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pembayaran Lunas & Project Telah Selesai! ✅"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Kembali ke halaman sebelumnya dengan nilai true agar list di-refresh
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error Update: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal konfirmasi: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          "Konfirmasi Pembayaran",
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
          children: [
            // INFO PROYEK (KREM)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFD4B07E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.project['nama_project']?.toString().toUpperCase() ??
                        "PROYEK",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Divider(color: Colors.black26),
                  _buildCustomerInfo(
                    Icons.person,
                    "Pemesan",
                    widget.project['nama_pemesan'],
                  ),
                  const SizedBox(height: 8),
                  _buildCustomerInfo(
                    Icons.phone,
                    "Telepon",
                    widget.project['no_hp'],
                  ),
                ],
              ),
            ),

            // RINCIAN BIAYA (ABU-ABU)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFD9D9D9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          "Barang",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "Qty",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Total",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.black54),
                  ...items.map((item) {
                    double harga =
                        double.tryParse(item['harga'].toString()) ?? 0;
                    int qty = int.tryParse(item['qty'].toString()) ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(item['nama_barang'] ?? "-"),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              qty.toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              formatIDR(harga * qty),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const Divider(color: Colors.black54),
                  _buildRowBiaya("Subtotal Pokok", formatIDR(subtotal)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Margin Keuntungan:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: TextField(
                              controller: profitController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                fillColor: Colors.white,
                                filled: true,
                              ),
                              onChanged: (val) {
                                setState(() {
                                  profitPercent = double.tryParse(val) ?? 0;
                                  _calculateTotal();
                                });
                              },
                            ),
                          ),
                          const Text(
                            " %",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "TOTAL TAGIHAN:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          formatIDR(totalTagihan),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _konfirmasiDanSelesaikan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FF00),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              "KONFIRMASI & SELESAI",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(IconData icon, String label, dynamic value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Text(
          value?.toString() ?? "-",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRowBiaya(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
