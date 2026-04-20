import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // ✅ FIX BUG #1

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool isLoadingPdf = false;
  bool isLoadingCsv = false;

  @override
  void initState() {
    super.initState();
    // ✅ FIX BUG #1: Inisialisasi locale 'id' sebelum DateFormat dipakai
    initializeDateFormatting('id', null);
  }

  Future<List<Map<String, dynamic>>> _fetchAllProjects() async {
    final result = await supabase
        .from('projects')
        .select('*')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(result);
  }

  // ─── EXPORT PDF ───────────────────────────────────────────────
  Future<void> _exportPdf() async {
    setState(() => isLoadingPdf = true);
    try {
      final projects = await _fetchAllProjects();
      final currency = NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp ',
        decimalDigits: 0,
      );

      final pdf = pw.Document();
      final now = DateFormat('dd MMMM yyyy HH:mm', 'id').format(DateTime.now());

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'BACKUP LAPORAN PROYEK',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Dicetak pada: $now',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 8),
            ],
          ),
          footer: (context) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total Proyek: ${projects.length}',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Text(
                'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
          build: (context) => projects.map((p) {
            final items = (p['items'] as List<dynamic>?) ?? [];
            String tanggal = '-';
            if (p['created_at'] != null) {
              tanggal = DateFormat(
                'dd MMM yyyy',
                'id',
              ).format(DateTime.parse(p['created_at'].toString()));
            }
            double total =
                double.tryParse(p['total_tagihan']?.toString() ?? '0') ?? 0;

            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 20),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              padding: const pw.EdgeInsets.all(14),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: pw.BoxDecoration(
                      color: const PdfColor.fromInt(0xFFD4B07E),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          (p['nama_project'] ?? 'Tanpa Nama')
                              .toString()
                              .toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.Text(
                          tanggal,
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  _pdfInfoRow('Nama Pemesan', p['nama_pemesan'] ?? '-'),
                  _pdfInfoRow('Metode Bayar', p['metode_bayar'] ?? '-'),
                  _pdfInfoRow('Status Bayar', p['status_bayar'] ?? '-'),
                  pw.SizedBox(height: 8),
                  if (items.isNotEmpty) ...[
                    pw.Text(
                      'Rincian Barang',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Table(
                      border: pw.TableBorder.all(
                        color: PdfColors.grey300,
                        width: 0.5,
                      ),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(3),
                        1: const pw.FlexColumnWidth(1),
                        2: const pw.FlexColumnWidth(2),
                      },
                      children: [
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.grey200,
                          ),
                          children: [
                            _pdfTableCell('Item', bold: true),
                            _pdfTableCell('Qty', bold: true, center: true),
                            _pdfTableCell('Harga', bold: true, right: true),
                          ],
                        ),
                        ...items.map((item) {
                          double harga =
                              double.tryParse(
                                item['harga']?.toString() ?? '0',
                              ) ??
                              0;
                          return pw.TableRow(
                            children: [
                              _pdfTableCell(
                                item['nama_barang'] ?? item['nama_item'] ?? '-',
                              ),
                              _pdfTableCell(
                                (item['qty'] ?? item['jumlah'] ?? 0).toString(),
                                center: true,
                              ),
                              _pdfTableCell(
                                currency.format(harga),
                                right: true,
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                  ],
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total Tagihan',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        currency.format(total),
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor.fromInt(0xFFD4B07E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name:
            'Backup_Laporan_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal export PDF: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoadingPdf = false);
    }
  }

  pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
          pw.Text(
            ': ',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfTableCell(
    String text, {
    bool bold = false,
    bool center = false,
    bool right = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(
        text,
        textAlign: right
            ? pw.TextAlign.right
            : center
            ? pw.TextAlign.center
            : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // ─── EXPORT CSV ───────────────────────────────────────────────
  Future<void> _exportCsv() async {
    setState(() => isLoadingCsv = true);
    try {
      final projects = await _fetchAllProjects();

      List<List<dynamic>> rows = [
        [
          'Nama Proyek',
          'Nama Pemesan',
          'Metode Bayar',
          'Status Bayar',
          'Total Tagihan',
          'Deskripsi',
          'Tanggal Dibuat',
        ],
        ...projects.map(
          (p) => [
            p['nama_project'] ?? '',
            p['nama_pemesan'] ?? '',
            p['metode_bayar'] ?? '',
            p['status_bayar'] ?? '',
            p['total_tagihan']?.toString() ?? '0',
            p['deskripsi'] ?? p['keterangan'] ?? '',
            p['created_at'] != null
                ? DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(DateTime.parse(p['created_at'].toString()))
                : '',
          ],
        ),
      ];

      final csv = const ListToCsvConverter().convert(rows);

      // ✅ FIX BUG #2: Simpan ke direktori Downloads/temp lalu share
      // Gunakan getTemporaryDirectory() agar kompatibel di semua platform
      final dir = await getTemporaryDirectory();
      final fileName =
          'Backup_Laporan_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csv);

      // ✅ FIX BUG #2: Pakai ShareResult dan XFile dengan mimeType eksplisit
      final xFile = XFile(file.path, mimeType: 'text/csv', name: fileName);

      final result = await Share.shareXFiles(
        [xFile],
        subject: 'Backup Laporan Proyek',
        text: 'File backup laporan proyek dalam format CSV.',
      );

      if (mounted && result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV berhasil dibagikan!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal export CSV: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoadingCsv = false);
    }
  }

  // ─── UI ───────────────────────────────────────────────────────
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
          "BACKUP DATA",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ekspor data",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w300,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Pilih format backup yang ingin kamu ekspor. Semua data proyek akan disertakan.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            _buildExportCard(
              icon: Icons.picture_as_pdf_outlined,
              iconColor: const Color(0xFFD4B07E),
              title: "Ekspor sebagai PDF",
              subtitle:
                  "Laporan lengkap siap cetak, termasuk rincian barang dan total tagihan.",
              isLoading: isLoadingPdf,
              onTap: _exportPdf,
            ),
            const SizedBox(height: 16),

            _buildExportCard(
              icon: Icons.table_chart_outlined,
              iconColor: Colors.green.shade600,
              title: "Ekspor sebagai CSV",
              subtitle:
                  "Data tabel proyek yang bisa dibuka di Excel atau Google Sheets.",
              isLoading: isLoadingCsv,
              onTap: _exportCsv,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFD4B07E),
                    ),
                  )
                : const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.black38,
                  ),
          ],
        ),
      ),
    );
  }
}
