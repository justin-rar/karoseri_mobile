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

  // Formatter untuk Rupiah
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final idProject = widget.projectData['id_project'];

    // Ambil total tagihan yang sudah di-update Manager
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
            // --- HEADER INFO ---
            Text(
              widget.projectData['nama_project']?.toString().toUpperCase() ??
                  "PROJECT",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  isLunas ? Icons.check_circle : Icons.pending_actions_rounded,
                  size: 16,
                  color: isLunas ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 5),
                Text(
                  "Status: ${isLunas ? 'LUNAS' : 'MENUNGGU PEMBAYARAN'}",
                  style: TextStyle(
                    color: isLunas ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(),
            ),

            const Text(
              "RINCIAN BARANG & MATERIAL",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 15),

            // --- FETCH DATA DARI projects_item ---
            FutureBuilder<List<Map<String, dynamic>>>(
              future: supabase
                  .from('projects_item')
                  .select()
                  .eq('id_project', idProject),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: LinearProgressIndicator(color: Color(0xFFD4B07E)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        "Rincian barang sedang disiapkan oleh Admin.",
                      ),
                    ),
                  );
                }

                final items = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    // SESUAIKAN DENGAN NAMA KOLOM DI DATABASE
                    double harga =
                        double.tryParse(item['harga']?.toString() ?? '0') ?? 0;
                    int qty = int.tryParse(item['qty']?.toString() ?? '0') ?? 0;
                    double subtotal = harga * qty;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['nama_barang'] ?? "Item Tanpa Nama",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  "$qty unit x ${formatter.format(harga)}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatter.format(subtotal),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            const Divider(thickness: 1.5, height: 40),

            // --- TOTAL TAGIHAN ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFD4B07E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TOTAL AKHIR",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatter.format(totalTagihan),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4B07E),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- INFO REKENING ---
            if (!isLunas) _buildPaymentInstruction(),

            const SizedBox(height: 20),
            if (!isLunas)
              const Center(
                child: Text(
                  "Silahkan kirim bukti bayar ke WhatsApp Admin\nsetelah melakukan transfer.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
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
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Transfer ke Rekening:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bank Mandiri",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.copy, size: 16, color: Colors.grey),
            ],
          ),
          Text(
            "123-456-7890",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          Text("a/n Karoseri Maju Jaya", style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
