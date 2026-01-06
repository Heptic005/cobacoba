import 'dart:typed_data';

import 'package:dakara_weighbridge/Json/transaksi_model.dart';
import 'package:dakara_weighbridge/SQLite/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<Uint8List> generateSlip(TransaksiModel data) async {
    final doc = pw.Document();

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    String barangName = '-';

    if (data.barangId != null) {
      final db = DatabaseHelper();
      final List<Map<String, dynamic>> result = await db.queryAll('barangs');
      // Filter manually since we don't have queryById exposed yet genericly
      final barang = result.firstWhere(
        (element) => element['id'] == data.barangId,
        orElse: () => {},
      );
      if (barang.isNotEmpty) {
        barangName = barang['name'];
      }
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80, // Thermal printer width usually 80mm
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  "DAKARA WEIGHBRIDGE",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              pw.Center(child: pw.Text("Jl. Example No. 123")),
              pw.Divider(),
              pw.Text("Ticket No: ${data.noTiket}"),
              pw.Text(
                "Date In: ${data.jamMasuk != null ? dateFormat.format(DateTime.parse(data.jamMasuk!)) : '-'}",
              ),
              pw.Text(
                "Date Out: ${data.jamKeluar != null ? dateFormat.format(DateTime.parse(data.jamKeluar!)) : '-'}",
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [pw.Text("Plate No:"), pw.Text("${data.platMobil}")],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [pw.Text("Driver:"), pw.Text("${data.namaSupir}")],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [pw.Text("Product:"), pw.Text(barangName)],
              ),
              pw.Divider(),
              _buildRow("Bruto", "${data.bruto} kg"),
              _buildRow("Tara", "${data.tara} kg"),
              pw.Divider(),
              _buildRow("Netto", "${data.netto} kg", isBold: true),
              pw.SizedBox(height: 20),
              pw.Center(child: pw.Text("Thank You")),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
        ),
        pw.Text(
          value,
          style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
        ),
      ],
    );
  }

  static Future<void> printSlip(TransaksiModel data) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => generateSlip(data),
    );
  }

  static Future<Uint8List> generateReport(
    List<TransaksiModel> transactions,
  ) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build:
            (context) => [
              pw.Header(
                level: 0,
                child: pw.Text(
                  "Transaction Report",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>[
                    'Ticket',
                    'Date',
                    'Plate',
                    'Driver',
                    'Bruto',
                    'Tara',
                    'Netto',
                  ],
                  ...transactions.map(
                    (item) => [
                      item.noTiket.toString(),
                      item.jamMasuk?.split('T')[0] ?? '-',
                      item.platMobil ?? '-',
                      item.namaSupir ?? '-',
                      item.bruto.toString(),
                      item.tara.toString(),
                      item.netto.toString(),
                    ],
                  ),
                ],
              ),
            ],
      ),
    );

    return doc.save();
  }
}
