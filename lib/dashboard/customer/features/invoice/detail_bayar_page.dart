import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DetailBayarPage extends StatefulWidget {
  final Map<String, dynamic> projectData;

  const DetailBayarPage({super.key, required this.projectData});

  @override
  State<DetailBayarPage> createState() => _DetailBayarPageState();
}

class _DetailBayarPageState extends State<DetailBayarPage> {
  final supabase = Supabase.instance.client;
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    // Ambil ID Project untuk filter rincian barang
    final idProject = widget.projectData['id_project'];
    double totalTagihan =
        double.tryParse(
          widget.projectData['total_tagihan']?.toString() ?? '0',
        ) ??
        0;
    bool isLunas =
        widget.projectData['status_bayar']?.toString().toLowerCase() == 'lunas';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Rincian Tagihan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Proyek
            Text(
              widget.projectData['nama_project']?.toString().toUpperCase() ??
                  "PROJECT",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Status: ${isLunas ? 'LUNAS' : 'BELUM LUNAS'}",
              style: TextStyle(
                color: isLunas ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(),
            ),

            const Text(
              "RINCIAN BARANG & JASA",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 15),

            // LIST BARANG DARI TABEL projects_item
            FutureBuilder<List<Map<String, dynamic>>>(
              future: supabase
                  .from('projects_item')
                  .select()
                  .eq(
                    'id_project',
                    idProject,
                  ), // Filter berdasarkan project ini
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: LinearProgressIndicator(color: Color(0xFFD4B07E)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text(
                    "Tidak ada rincian barang.",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  );
                }

                final items = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    double harga =
                        double.tryParse(item['harga']?.toString() ?? '0') ?? 0;
                    int jumlah =
                        int.tryParse(item['jumlah']?.toString() ?? '1') ?? 1;
                    double subtotal = harga * jumlah;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['nama_item'] ?? "Item",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "$jumlah x ${formatter.format(harga)}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            formatter.format(subtotal),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(thickness: 1.5),
            ),

            // TOTAL AKHIR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "TOTAL TAGIHAN",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  formatter.format(totalTagihan),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4B07E),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Info Rekening (Hanya muncul jika belum lunas)
            if (!isLunas) _buildPaymentInstruction(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInstruction() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Transfer Pembayaran:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Bank Mandiri",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(
            "123-456-7890",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text("a/n Karoseri Gacor", style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
