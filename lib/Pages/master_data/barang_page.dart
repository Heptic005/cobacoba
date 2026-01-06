import 'package:dakara_weighbridge/Json/barang_model.dart';
import 'package:dakara_weighbridge/SQLite/database_helper.dart';
import 'package:flutter/material.dart';

class BarangPage extends StatefulWidget {
  const BarangPage({super.key});

  @override
  State<BarangPage> createState() => _BarangPageState();
}

class _BarangPageState extends State<BarangPage> {
  List<BarangModel> _barangs = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshBarangs();
  }

  Future<void> _refreshBarangs() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper().queryAll('barangs');
    setState(() {
      _barangs = data.map((e) => BarangModel.fromJson(e)).toList();
      _isLoading = false;
    });
  }

  Future<void> _addOrUpdateBarang({BarangModel? barang}) async {
    if (barang != null) {
      _nameController.text = barang.name;
      _codeController.text = barang.kodeBarang ?? '';
    } else {
      _nameController.clear();
      _codeController.clear();
    }

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF262F36),
            title: Text(
              barang == null ? 'Add Barang' : 'Edit Barang',
              style: const TextStyle(color: Colors.white),
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Please enter a name' : null,
                  ),
                  TextFormField(
                    controller: _codeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Code',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final model = BarangModel(
                      id: barang?.id,
                      name: _nameController.text,
                      kodeBarang: _codeController.text,
                    );
                    if (barang == null) {
                      await DatabaseHelper().insert(
                        'barangs',
                        model.toJson()..remove('id'),
                      );
                    } else {
                      await DatabaseHelper().update(
                        'barangs',
                        model.toJson(),
                        barang.id!,
                      );
                    }
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _refreshBarangs();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteBarang(int id) async {
    await DatabaseHelper().delete('barangs', id);
    _refreshBarangs();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateBarang(),
        backgroundColor: const Color(0xFF00E5FF),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _barangs.length,
        itemBuilder: (context, index) {
          final barang = _barangs[index];
          return Card(
            color: const Color(0xFF36444D),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                barang.name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                barang.kodeBarang ?? '-',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () => _addOrUpdateBarang(barang: barang),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteBarang(barang.id!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
