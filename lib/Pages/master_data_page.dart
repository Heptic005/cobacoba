import 'package:dakara_weighbridge/Pages/master_data/barang_page.dart';
import 'package:dakara_weighbridge/Pages/master_data/customer_page.dart';
import 'package:dakara_weighbridge/Pages/master_data/supplier_page.dart';
import 'package:dakara_weighbridge/Pages/users_page.dart';
import 'package:dakara_weighbridge/Services/auth_service.dart';
import 'package:flutter/material.dart';

class MasterDataPage extends StatefulWidget {
  const MasterDataPage({super.key});

  @override
  State<MasterDataPage> createState() => _MasterDataPageState();
}

class _MasterDataPageState extends State<MasterDataPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Dynamic tabs
  final List<Widget> _pages = [];
  final List<Tab> _tabs = [];

  @override
  void initState() {
    super.initState();
    _setupTabs();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  void _setupTabs() {
    _pages.addAll([
      const SupplierPage(),
      const CustomerPage(),
      const BarangPage(),
    ]);
    _tabs.addAll([
      const Tab(text: 'Suppliers'),
      const Tab(text: 'Customers'),
      const Tab(text: 'Barang'),
    ]);

    // Add User Management if authorized
    if (AuthService().canManageUsers) {
      _pages.add(const UsersPage(showAppBar: false));
      _tabs.add(const Tab(text: 'Users'));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Master Data', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF00E5FF),
          tabs: _tabs,
        ),
      ),
      body: TabBarView(controller: _tabController, children: _pages),
    );
  }
}
