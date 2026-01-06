import 'package:dakara_weighbridge/Json/transaksi_model.dart';
import 'package:dakara_weighbridge/SQLite/database_helper.dart';
import 'package:dakara_weighbridge/Utils/pdf_generator.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  List<TransaksiModel> _transactions = [];
  List<TransaksiModel> _filteredTransactions = [];
  DateTimeRange? _selectedDateRange;

  // ignore: unused_field
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    final db = DatabaseHelper();
    final data = await db.queryAll('transaksis');
    if (!mounted) return;

    setState(() {
      _transactions =
          data
              .map((e) => TransaksiModel.fromJson(e))
              .toList()
              .reversed
              .toList();
      _filteredTransactions = _transactions;
      _isLoading = false;
    });
  }

  void _filterTransactions() {
    setState(() {
      _filteredTransactions =
          _transactions.where((t) {
            bool matchDate = true;
            if (_selectedDateRange != null && t.jamMasuk != null) {
              final date = DateTime.parse(t.jamMasuk!);
              matchDate =
                  date.isAfter(_selectedDateRange!.start) &&
                  date.isBefore(
                    _selectedDateRange!.end.add(const Duration(days: 1)),
                  );
            }
            return matchDate;
          }).toList();
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      _filterTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 90, 30, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Report Transaction",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _selectedDateRange == null
                            ? "Select Date"
                            : "${_selectedDateRange!.start.toLocal().toString().split(' ')[0]} - ${_selectedDateRange!.end.toLocal().toString().split(' ')[0]}",
                      ),
                      onPressed: _selectDateRange,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF36444D),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.print),
                      label: const Text("Export PDF"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        final pdfData = await PdfGenerator.generateReport(
                          _filteredTransactions,
                        );
                        await Printing.sharePdf(
                          bytes: pdfData,
                          filename: 'report.pdf',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF36444D),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      dataTextStyle: const TextStyle(color: Colors.white70),
                      columns: const [
                        DataColumn(label: Text('Ticket')),
                        DataColumn(label: Text('Date In')),
                        DataColumn(label: Text('Plate No')),
                        DataColumn(label: Text('Driver')),
                        DataColumn(label: Text('Bruto')),
                        DataColumn(label: Text('Tara')),
                        DataColumn(label: Text('Netto')),
                      ],
                      rows:
                          _filteredTransactions.map((t) {
                            return DataRow(
                              cells: [
                                DataCell(Text(t.noTiket.toString())),
                                DataCell(
                                  Text(t.jamMasuk?.split('T')[0] ?? '-'),
                                ),
                                DataCell(Text(t.platMobil ?? '-')),
                                DataCell(Text(t.namaSupir ?? '-')),
                                DataCell(Text(t.bruto.toString())),
                                DataCell(Text(t.tara.toString())),
                                DataCell(Text(t.netto.toString())),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
