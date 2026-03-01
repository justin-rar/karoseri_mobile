import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tambahkan ini untuk TextInputFormatter
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

// Formatter kustom untuk menambahkan titik
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = '.';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // Hapus semua karakter selain angka
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Format angka dengan titik
    final formatter = NumberFormat.decimalPattern('id');
    String formattedText = formatter
        .format(int.parse(newText))
        .replaceAll(',', '.');

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class _AddProjectPageState extends State<AddProjectPage> {
  final TextEditingController _namaProyekController = TextEditingController();
  final TextEditingController _namaPemesanController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _tglBuatController = TextEditingController();
  final TextEditingController _tglJadiController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  String? _pilihanPembayaran = "cash";

  // Kita buat List of Controllers untuk menghandle harga per baris agar tidak bentrok
  List<Map<String, dynamic>> listBarang = [
    {
      "nama_barang": "",
      "harga": "",
      "qty": "",
      "controller": TextEditingController(),
    },
  ];

  Future<void> _simpanProyek() async {
    if (_namaProyekController.text.isEmpty ||
        _namaPemesanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama proyek dan pemesan wajib diisi!")),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final supabase = Supabase.instance.client;
      final String? userId = supabase.auth.currentUser?.id;

      if (userId == null) throw "User tidak terdeteksi. Silahkan login ulang.";

      // Bersihkan titik dari harga sebelum simpan ke Database (biar jadi angka murni)
      List<Map<String, dynamic>> itemsToSave = listBarang.map((item) {
        return {
          "nama_barang": item["nama_barang"],
          "harga": item["harga"].toString().replaceAll('.', ''), // Hapus titik
          "qty": item["qty"],
        };
      }).toList();

      await supabase.from('projects').insert({
        'nama_project': _namaProyekController.text,
        'nama_pemesan': _namaPemesanController.text,
        'no_hp': _noHpController.text,
        'alamat': _alamatController.text,
        'tgl_buat': _tglBuatController.text,
        'tgl_jadi': _tglJadiController.text,
        'metode_bayar': _pilihanPembayaran,
        'status_bayar': 'Belum Lunas',
        'progres_persen': 0,
        'deskripsi': _deskripsiController.text,
        'keterangan': _keteranganController.text,
        'cust_id': userId,
        'items': itemsToSave,
      });

      if (mounted) Navigator.pop(context); // Tutup loading

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Proyek berhasil ditambahkan!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menyimpan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
      setState(() => controller.text = formattedDate);
    }
  }

  void _tambahBarisBarang() {
    setState(() {
      listBarang.add({
        "nama_barang": "",
        "harga": "",
        "qty": "",
        "controller":
            TextEditingController(), // Controller baru untuk baris baru
      });
    });
  }

  @override
  void dispose() {
    // Bersihkan semua controller agar tidak memory leak
    for (var item in listBarang) {
      item['controller'].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
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
            const Text(
              "Isi formulir pengerjaan proyek karoseri di bawah ini.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 30),

            _labelInput("nama proyek"),
            _kotakInput(controller: _namaProyekController),

            _labelInput("nama pemesan"),
            _kotakInput(controller: _namaPemesanController),

            _labelInput("no hp pemesan"),
            _kotakInput(controller: _noHpController, type: TextInputType.phone),

            _labelInput("alamat pemesan"),
            _kotakInput(controller: _alamatController, lines: 2),

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

            _labelInput("pembayaran"),
            _buildDropdownPembayaran(),

            const SizedBox(height: 30),
            _tabelBarangWidget(),

            const SizedBox(height: 20),
            _labelInput("deskripsi pesanan"),
            _kotakInput(controller: _deskripsiController, lines: 3),

            _labelInput("tuliskan keterangan produk"),
            _kotakInput(controller: _keteranganController, lines: 3),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _simpanProyek,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4B07E),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "TAMBAH PROYEK",
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

  // --- WIDGET HELPERS ---

  Widget _labelInput(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _kotakInput({
    required TextEditingController controller,
    int lines = 1,
    TextInputType type = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        maxLines: lines,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(10),
        ),
      ),
    );
  }

  Widget _buildDropdownPembayaran() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _pilihanPembayaran,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: "cash", child: Text("Cash")),
            DropdownMenuItem(value: "leasing", child: Text("Leasing")),
          ],
          onChanged: (value) => setState(() => _pilihanPembayaran = value),
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

  Widget _tabelBarangWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Kebutuhan Barang",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black26),
          ),
          child: Column(
            children: [
              Container(
                color: const Color(0xFFD4B07E),
                padding: const EdgeInsets.all(10),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        "Nama Barang",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Harga",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "Qty",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 40),
                  ],
                ),
              ),
              ...listBarang.asMap().entries.map((entry) {
                int index = entry.key;
                return Container(
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Colors.white : Colors.grey[100],
                    border: const Border(
                      top: BorderSide(color: Colors.black12),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      // NAMA BARANG
                      Expanded(
                        flex: 3,
                        child: TextField(
                          onChanged: (val) =>
                              listBarang[index]['nama_barang'] = val,
                          decoration: const InputDecoration(
                            hintText: "...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      // HARGA (DENGAN TITIK)
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller:
                              listBarang[index]['controller'], // Pakai controller khusus
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            ThousandsSeparatorInputFormatter(), // Formatter titik kita
                          ],
                          onChanged: (val) {
                            listBarang[index]['harga'] = val;
                          },
                          decoration: const InputDecoration(
                            hintText: "0",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      // QTY
                      Expanded(
                        flex: 1,
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          onChanged: (val) => listBarang[index]['qty'] = val,
                          decoration: const InputDecoration(
                            hintText: "0",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () {
                          if (listBarang.length > 1) {
                            setState(() => listBarang.removeAt(index));
                          }
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: _tambahBarisBarang,
          icon: const Icon(Icons.add),
          label: const Text("Tambah Baris"),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFD4B07E)),
        ),
      ],
    );
  }
}
