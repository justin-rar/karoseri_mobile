import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailPaymentPage extends StatefulWidget {
  final Map<String, dynamic> project;
  const DetailPaymentPage({super.key, required this.project});

  @override
  State<DetailPaymentPage> createState() => _DetailPaymentPageState();
}

class _DetailPaymentPageState extends State<DetailPaymentPage> {
  final supabase = Supabase.instance.client;
  final profitController = TextEditingController();

  List<dynamic> items = [];
  double subtotal = 0;
  double profitPercent = 0;
  double totalTagihan = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Sesuaikan 'items' dengan nama kolom di tabel kamu (misal: 'bahan_baku')
    items = widget.project['items'] ?? [];
    _calculateSubtotal();
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

  Future<void> _simpanTagihan() async {
    setState(() => isLoading = true);
    try {
      await supabase
          .from('projects')
          .update({
            'profit_percentage': profitPercent,
            'total_tagihan': totalTagihan,
          })
          .eq('id_project', widget.project['id_project']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tagihan Berhasil Dikonfirmasi!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // SUDAH DIPERBAIKI (Bukan app_appBar)
        title: const Text(
          "Lihat Tagihan",
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
            // Bagian Atas: Info Proyek (Warna Krem)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
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
                  const SizedBox(height: 5),
                  Text(
                    widget.project['deskripsi'] ?? "Tanpa deskripsi",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            // Bagian Bawah: List Barang & Kalkulasi (Warna Abu-abu)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Column(
                children: [
                  // Header Tabel
                  const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // SUDAH DIPERBAIKI
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
                  const Divider(color: Colors.black),

                  // List Barang
                  items.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text("Data barang tidak ada"),
                        )
                      : Column(
                          children: items.map((item) {
                            double harga =
                                double.tryParse(item['harga'].toString()) ?? 0;
                            int qty = int.tryParse(item['qty'].toString()) ?? 0;
                            double lineTotal = harga * qty;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
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
                                      "Rp ${lineTotal.toStringAsFixed(0)}",
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                  const Divider(color: Colors.black),

                  // Perhitungan
                  const SizedBox(height: 10),
                  _buildRowInfo(
                    "Subtotal Pokok",
                    "Rp ${subtotal.toStringAsFixed(0)}",
                  ),
                  const SizedBox(height: 10),

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
                            width: 50,
                            child: TextField(
                              controller: profitController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.all(5),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  profitPercent = double.tryParse(val) ?? 0;
                                  _calculateTotal();
                                });
                              },
                            ),
                          ),
                          const Text(" %"),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Total Tagihan Akhir
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "TOTAL TAGIHAN:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Rp ${totalTagihan.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Tombol Konfirmasi (Warna Hijau stabilo sesuai gambar lo)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _simpanTagihan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF00FF00,
                        ), // Hijau sesuai gambar
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              "konfirmasi",
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

  Widget _buildRowInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}
