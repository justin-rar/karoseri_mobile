import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final TextEditingController _tglBuatController = TextEditingController();
  final TextEditingController _tglJadiController = TextEditingController();

  // Variabel untuk Dropdown
  String? _pilihanPembayaran = "cash";

  List<Map<String, dynamic>> listBarang = [
    {"nama": "", "harga": "", "jumlah": ""},
  ];

  Future<void> _pilihTanggal(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  void _tambahBarisBarang() {
    setState(() {
      listBarang.add({"nama": "", "harga": "", "jumlah": ""});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tambah Proyek",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Proyek Baru",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 30),

            _labelInput("nama proyek"),
            _kotakInput(),

            _labelInput("nama pemesan"),
            _kotakInput(),

            _labelInput("no hp pemesan"),
            _kotakInput(type: TextInputType.phone),

            _labelInput("alamat pemesan"),
            _kotakInput(lines: 2),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _labelInput("tanggal buat"),
                      _kotakInputTanggal(
                        _tglBuatController,
                        () => _pilihTanggal(context, _tglBuatController),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _labelInput("tanggal jadi"),
                      _kotakInputTanggal(
                        _tglJadiController,
                        () => _pilihTanggal(context, _tglJadiController),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // --- BAGIAN DROPDOWN PEMBAYARAN ---
            _labelInput("pembayaran"),
            _buildDropdownPembayaran(),

            const SizedBox(height: 30),

            const Text(
              "Kebutuhan Barang",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Column(
                children: [
                  Container(
                    color: const Color(0xFFD4B07E),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            "nama barang",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "harga",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            "jumlah",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: listBarang.asMap().entries.map((entry) {
                      int index = entry.key;
                      return Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.black12),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: "...",
                                  border: InputBorder.none,
                                ),
                                onChanged: (val) =>
                                    listBarang[index]['nama'] = val,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: "0",
                                  border: InputBorder.none,
                                ),
                                onChanged: (val) =>
                                    listBarang[index]['harga'] = val,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: "0",
                                  border: InputBorder.none,
                                ),
                                onChanged: (val) =>
                                    listBarang[index]['jumlah'] = val,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _tambahBarisBarang,
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4B07E),
                    border: Border.all(color: Colors.black),
                  ),
                  child: const Icon(Icons.add, size: 20),
                ),
              ),
            ),

            const SizedBox(height: 20),
            _labelInput("deskripsi pesanan"),
            _kotakInput(lines: 3),

            _labelInput("tuliskan keterangan produk"),
            _kotakInput(lines: 3),

            const SizedBox(height: 40),

            SizedBox(
              width: 130,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  print("Metode Bayar: $_pilihanPembayaran");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0E0E0),
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  "TAMBAH",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGET DROPDOWN ---
  Widget _buildDropdownPembayaran() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        // Supaya garis bawah bawaannya hilang
        child: DropdownButton<String>(
          value: _pilihanPembayaran,
          isExpanded: true, // Supaya lebarnya penuh
          items: const [
            DropdownMenuItem(value: "cash", child: Text("Cash")),
            DropdownMenuItem(value: "leasing", child: Text("Leasing")),
          ],
          onChanged: (String? value) {
            setState(() {
              _pilihanPembayaran = value;
            });
          },
        ),
      ),
    );
  }

  // --- Fungsi Helper Lainnya ---
  Widget _labelInput(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _kotakInput({
    String? hint,
    int lines = 1,
    TextInputType type = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        keyboardType: type,
        maxLines: lines,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(10),
        ),
      ),
    );
  }

  Widget _kotakInputTanggal(
    TextEditingController controller,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: const InputDecoration(
          suffixIcon: Icon(Icons.calendar_month, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12),
        ),
      ),
    );
  }
}
