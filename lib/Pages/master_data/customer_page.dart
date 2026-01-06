import 'package:dakara_weighbridge/Json/customer_model.dart';
import 'package:dakara_weighbridge/SQLite/database_helper.dart';
import 'package:flutter/material.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  List<CustomerModel> _customers = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshCustomers();
  }

  Future<void> _refreshCustomers() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper().queryAll('customers');
    setState(() {
      _customers = data.map((e) => CustomerModel.fromJson(e)).toList();
      _isLoading = false;
    });
  }

  Future<void> _addOrUpdateCustomer({CustomerModel? customer}) async {
    if (customer != null) {
      _nameController.text = customer.name;
      _addressController.text = customer.alamat ?? '';
      _phoneController.text = customer.noTelp ?? '';
    } else {
      _nameController.clear();
      _addressController.clear();
      _phoneController.clear();
    }

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF262F36),
            title: Text(
              customer == null ? 'Add Customer' : 'Edit Customer',
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
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Phone',
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
                    final model = CustomerModel(
                      id: customer?.id,
                      name: _nameController.text,
                      alamat: _addressController.text,
                      noTelp: _phoneController.text,
                    );
                    if (customer == null) {
                      await DatabaseHelper().insert(
                        'customers',
                        model.toJson()..remove('id'),
                      );
                    } else {
                      await DatabaseHelper().update(
                        'customers',
                        model.toJson(),
                        customer.id!,
                      );
                    }
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _refreshCustomers();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteCustomer(int id) async {
    await DatabaseHelper().delete('customers', id);
    _refreshCustomers();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateCustomer(),
        backgroundColor: const Color(0xFF00E5FF),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final customer = _customers[index];
          return Card(
            color: const Color(0xFF36444D),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                customer.name,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                '${customer.alamat ?? '-'} | ${customer.noTelp ?? '-'}',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () => _addOrUpdateCustomer(customer: customer),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteCustomer(customer.id!),
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
