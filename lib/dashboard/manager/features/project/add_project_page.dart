import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
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

  // Sesuaikan key agar sama dengan yang diharapkan di DetailPaymentPage
  List<Map<String, dynamic>> listBarang = [
    {"nama_barang": "", "harga": "", "qty": ""},
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

      // AMBIL ID USER YANG SEDANG LOGIN (Penting agar tidak error UUID)
      final String? userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw "User tidak terdeteksi. Silahkan login ulang.";
      }

      // Kirim data ke tabel 'projects'
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
        'cust_id': userId, // MENGGUNAKAN UUID ASLI
        'items': listBarang, // MENYIMPAN LIST BARANG KE KOLOM JSONB
      });

      if (mounted) Navigator.pop(context);

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

  // --- WIDGET HELPERS ---

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
      listBarang.add({"nama_barang": "", "harga": "", "qty": ""});
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

  Widget _labelInput(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                      Expanded(
                        flex: 2,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (val) => listBarang[index]['harga'] = val,
                          decoration: const InputDecoration(
                            hintText: "0",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
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
                          if (listBarang.length > 1)
                            setState(() => listBarang.removeAt(index));
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
