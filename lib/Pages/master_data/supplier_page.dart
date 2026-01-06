import 'package:dakara_weighbridge/Json/supplier_model.dart';
import 'package:dakara_weighbridge/SQLite/database_helper.dart';
import 'package:flutter/material.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  List<SupplierModel> _suppliers = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshSuppliers();
  }

  Future<void> _refreshSuppliers() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper().queryAll('suppliers');
    setState(() {
      _suppliers = data.map((e) => SupplierModel.fromJson(e)).toList();
      _isLoading = false;
    });
  }

  Future<void> _addOrUpdateSupplier({SupplierModel? supplier}) async {
    if (supplier != null) {
      _nameController.text = supplier.name;
      _addressController.text = supplier.alamat ?? '';
      _cityController.text = supplier.kabupatenKota ?? '';
    } else {
      _nameController.clear();
      _addressController.clear();
      _cityController.clear();
    }

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF262F36),
            title: Text(
              supplier == null ? 'Add Supplier' : 'Edit Supplier',
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
                    controller: _addressController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _cityController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'City',
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
                    final model = SupplierModel(
                      id: supplier?.id,
                      name: _nameController.text,
                      alamat: _addressController.text,
                      kabupatenKota: _cityController.text,
                    );
                    if (supplier == null) {
                      await DatabaseHelper().insert(
                        'suppliers',
                        model.toJson()..remove('id'),
                      );
                    } else {
                      await DatabaseHelper().update(
                        'suppliers',
                        model.toJson(),
                        supplier.id!,
                      );
                    }
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _refreshSuppliers();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteSupplier(int id) async {
    await DatabaseHelper().delete('suppliers', id);
    _refreshSuppliers();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateSupplier(),
        backgroundColor: const Color(0xFF00E5FF),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _suppliers.length,
        itemBuilder: (context, index) {
          final supplier = _suppliers[index];
          return Card(
            color: const Color(0xFF36444D),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                supplier.name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                supplier.alamat ?? '-',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () => _addOrUpdateSupplier(supplier: supplier),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteSupplier(supplier.id!),
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
