import 'dart:async';
import 'package:dakara_weighbridge/Json/barang_model.dart';
import 'package:dakara_weighbridge/Json/customer_model.dart';
import 'package:dakara_weighbridge/Json/supplier_model.dart';
import 'package:dakara_weighbridge/Json/transaksi_model.dart';
import 'package:dakara_weighbridge/SQLite/database_helper.dart';
import 'package:dakara_weighbridge/Services/serial_service.dart';
import 'package:dakara_weighbridge/Utils/pdf_generator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Transaction extends StatefulWidget {
  const Transaction({super.key});

  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  late String _timeString;
  late Timer _timer;
  Color limeGreen = const Color.fromARGB(255, 151, 255, 33);

  // Controllers
  final _noPolisiController = TextEditingController();
  final _supirController = TextEditingController();
  final _noDoController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _brutoController = TextEditingController(text: "0");
  final _taraController = TextEditingController(text: "0");
  final _nettoController = TextEditingController(text: "0");

  // Dropdown Selections
  SupplierModel? _selectedSupplier;
  CustomerModel? _selectedCustomer;
  BarangModel? _selectedBarang;

  // Data Lists
  List<SupplierModel> _suppliers = [];
  List<CustomerModel> _customers = [];
  List<BarangModel> _barangs = [];
  List<TransaksiModel> _recentTransactions = [];

  bool _isWeighIn =
      true; // Mode: True = Weigh In (Masuk), False = Weigh Out (Keluar)
  int _currentWeight = 0; // Simulated indicator weight
  TransaksiModel? _selectedPendingTransaction;

  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _getTime(),
    );
    _loadMasterData();
    _loadRecentTransactions();

    // Listen to Serial Port for Weight
    // Note: parsing logic depends on potential data format.
    // Assuming format like "=002500" or raw string for now.
    // We try to parse the last integer found in the string.
    SerialService().getReaderStream().listen((data) {
      // Simple parser: Extract digits
      // This is a placeholder parser. Real world needs specific protocol (e.g. STX/ETX).
      final RegExp digitRegExp = RegExp(r'\d+');
      final matches = digitRegExp.allMatches(data);
      if (matches.isNotEmpty) {
        // Take the longest match or just the last one?
        // Let's assume the indicator sends " 2000 "
        for (final match in matches) {
          final val = int.tryParse(match.group(0) ?? "");
          if (val != null && val > 0 && val < 100000) {
            // Basic sanity check
            if (mounted) {
              setState(() {
                _currentWeight = val;
              });
            }
          }
        }
      }
    });
  }

  Future<void> _loadMasterData() async {
    final db = DatabaseHelper();
    final suppliersData = await db.queryAll('suppliers');
    final customersData = await db.queryAll('customers');
    final barangsData = await db.queryAll('barangs');

    setState(() {
      _suppliers = suppliersData.map((e) => SupplierModel.fromJson(e)).toList();
      _customers = customersData.map((e) => CustomerModel.fromJson(e)).toList();
      _barangs = barangsData.map((e) => BarangModel.fromJson(e)).toList();
    });
  }

  Future<void> _loadRecentTransactions() async {
    final db = DatabaseHelper();
    final data = await db.queryAll(
      'transaksis',
    ); // Should filter/limit logic here
    setState(() {
      _recentTransactions = data
          .map((e) => TransaksiModel.fromJson(e))
          .toList()
          .reversed
          .take(10)
          .toList();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _getTime() {
    setState(() {
      _timeString = _formatDateTime(DateTime.now());
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  void _calculateNetto() {
    int bruto = int.tryParse(_brutoController.text) ?? 0;
    int tara = int.tryParse(_taraController.text) ?? 0;
    setState(() {
      _nettoController.text = (bruto - tara).toString();
    });
  }

  void _setWeightFromIndicator() {
    // In real app, read from Serial Port
    // For now, use manual input simulation or keeping it 0 if no indicator
    if (_isWeighIn) {
      _brutoController.text = _currentWeight.toString();
    } else {
      _taraController.text = _currentWeight.toString();
    }
    _calculateNetto();
  }

  Future<void> _saveTransaction() async {
    final db = DatabaseHelper();

    if (_isWeighIn) {
      // Save Weigh In (Ticket Masuk)
      final transaction = TransaksiModel(
        jamMasuk: DateTime.now().toIso8601String(),
        platMobil: _noPolisiController.text,
        namaSupir: _supirController.text,
        supplierId: _selectedSupplier?.id,
        customerId: _selectedCustomer?.id,
        barangId: _selectedBarang?.id,
        noDo: _noDoController.text,
        keterangan: _keteranganController.text,
        bruto: int.tryParse(_brutoController.text),
        tara:
            0, // Tara 0 initially for Weigh In? Or dependent on logic. Usually Weigh In = Bruto, Weigh Out = Tara/Netto
        netto: 0,
        createdAt: DateTime.now().toIso8601String(),
      );

      // If Logic is: Masuk = Berat Pertama (Bruto/Tara depending on Empty/Full entry)
      // Assumption: Truck enters FULL -> Bruto measured.

      await db.insert(
        'transaksis',
        transaction.toJson()
          ..remove('no_tiket')
          ..remove('id'),
      ); // Remove ID for Autoincrement
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Weigh In Saved")));
    } else {
      // Save Weigh Out (Ticket Keluar)
      if (_selectedPendingTransaction == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please select a pending transaction via Ticket No or Plate",
            ),
          ),
        );
        return;
      }

      // Update existing transaction
      final updateData = {
        'jam_keluar': DateTime.now().toIso8601String(),
        'tara': int.tryParse(_taraController.text),
        'netto': int.tryParse(_nettoController.text),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await db.update(
        'transaksis',
        updateData,
        _selectedPendingTransaction!.noTiket!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Weigh Out Saved")));
    }

    _clearForm();
    _loadRecentTransactions();
  }

  void _clearForm() {
    _noPolisiController.clear();
    _supirController.clear();
    _noDoController.clear();
    _keteranganController.clear();
    _brutoController.text = "0";
    _taraController.text = "0";
    _nettoController.text = "0";
    _selectedSupplier = null;
    _selectedCustomer = null;
    _selectedBarang = null;
    _selectedPendingTransaction = null;
    setState(() {
      _isWeighIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 90, 30, 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "PT. Dakara Prima Internasional",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _timeString,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    DateFormat(
                      "EEEE, d MMMM yyyy",
                      "id_ID",
                    ).format(DateTime.now()),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weighing Indicator & Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicator Box
              Container(
                width: MediaQuery.of(context).size.width * 0.45,
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12, width: 0.4),
                  color: const Color.fromARGB(69, 84, 88, 96),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: limeGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          "Weighing Indicator",
                          style: TextStyle(fontSize: 10, color: Colors.white54),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        "$_currentWeight kg",
                        style: const TextStyle(
                          fontSize: 64,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _setWeightFromIndicator,
                      child: const Text("Capture Weight"),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Transaction Mode Switch
              Column(
                children: [
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text("Timbang Masuk"),
                        selected: _isWeighIn,
                        onSelected: (val) {
                          setState(() {
                            _isWeighIn = true;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text("Timbang Keluar"),
                        selected: !_isWeighIn,
                        onSelected: (val) {
                          setState(() {
                            _isWeighIn = false;
                            // Typically you'd popup a search dialog here to find the pending ticket
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Form Input
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Form
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12, width: 0.4),
                    color: const Color.fromARGB(69, 84, 88, 96),
                  ),
                  child: Column(
                    children: [
                      // No Polisi
                      TextFormField(
                        controller: _noPolisiController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Plat Nomor",
                          labelStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Supir
                      TextFormField(
                        controller: _supirController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: "Nama Supir",
                          labelStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Dropdowns
                      DropdownButtonFormField<SupplierModel>(
                        value: _selectedSupplier,
                        dropdownColor: const Color(0xFF36444D),
                        style: const TextStyle(color: Colors.white),
                        items: _suppliers
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedSupplier = val),
                        decoration: const InputDecoration(
                          labelText: "Supplier",
                          labelStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<CustomerModel>(
                        value: _selectedCustomer,
                        dropdownColor: const Color(0xFF36444D),
                        style: const TextStyle(color: Colors.white),
                        items: _customers
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedCustomer = val),
                        decoration: const InputDecoration(
                          labelText: "Customer",
                          labelStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<BarangModel>(
                        value: _selectedBarang,
                        dropdownColor: const Color(0xFF36444D),
                        style: const TextStyle(color: Colors.white),
                        items: _barangs
                            .map(
                              (b) => DropdownMenuItem(
                                value: b,
                                child: Text(b.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedBarang = val),
                        decoration: const InputDecoration(
                          labelText: "Barang",
                          labelStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 50,
                          ),
                        ),
                        onPressed: _saveTransaction,
                        child: Text(
                          _isWeighIn ? "SIMPAN MASUK" : "SIMPAN KELUAR",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Right Values (Weights)
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12, width: 0.4),
                    color: const Color.fromARGB(69, 84, 88, 96),
                  ),
                  child: Column(
                    children: [
                      _buildWeightInput("Bruto", _brutoController),
                      const SizedBox(height: 10),
                      _buildWeightInput("Tara", _taraController),
                      const SizedBox(height: 10),
                      _buildWeightInput(
                        "Netto",
                        _nettoController,
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          // Recent Transactions
          Container(
            height: 300,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12, width: 0.5),
              color: const Color.fromARGB(69, 84, 88, 96),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Recent Transactions",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _recentTransactions.length,
                    itemBuilder: (context, index) {
                      final t = _recentTransactions[index];
                      return ListTile(
                        title: Text(
                          t.platMobil ?? '-',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "Tiket: ${t.noTiket} | Netto: ${t.netto}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t.jamMasuk?.split('T')[0] ?? '',
                              style: const TextStyle(color: Colors.white54),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.print,
                                color: Colors.blueAccent,
                              ),
                              onPressed: () => PdfGenerator.printSlip(t),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightInput(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        suffixText: "kg",
        suffixStyle: const TextStyle(color: Colors.white70),
        border: const OutlineInputBorder(),
      ),
      onChanged: (val) => _calculateNetto(),
    );
  }
}
