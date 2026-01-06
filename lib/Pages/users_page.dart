import 'package:flutter/material.dart';
import 'package:dakara_weighbridge/SQLite/database_helper.dart';
import 'package:dakara_weighbridge/Json/user_model.dart';
import 'package:dakara_weighbridge/Services/auth_service.dart';

class UsersPage extends StatefulWidget {
  final bool showAppBar;
  const UsersPage({Key? key, this.showAppBar = true}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final DatabaseHelper _db = DatabaseHelper();
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  Future<void> _refreshUsers() async {
    setState(() => _isLoading = true);
    final data = await _db.getAllUsers();
    final allUsers = data.map((e) => UserModel.fromJson(e)).toList();

    final auth = AuthService();
    final current = auth.currentUser;

    List<UserModel> visible = [];
    if (current?.role == 'owner') {
      visible = allUsers;
    } else if (auth.isManager) {
      visible = allUsers.where((u) => ['supervisor', 'operator', 'ktu'].contains(u.role)).toList();
    } else if (auth.isSupervisor) {
      visible = allUsers.where((u) => u.role == 'operator').toList();
    } else {
      visible = [];
    }

    setState(() {
      _users = visible;
      _isLoading = false;
    });
  }

  List<String> _allowedRoles() {
    final auth = AuthService();
    final role = auth.currentUser?.role;
    if (role == 'owner') return ['owner', 'manager', 'supervisor', 'ktu', 'operator'];
    if (auth.isManager) return ['supervisor', 'ktu', 'operator'];
    if (auth.isSupervisor) return ['operator'];
    return [];
  }

  Future<void> _showForm({UserModel? user}) async {
    final allowed = _allowedRoles();
    if (allowed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No permission')));
      return;
    }

    final usernameCtrl = TextEditingController(text: user?.username ?? '');
    final passwordCtrl = TextEditingController();
    String role = user?.role ?? allowed.first;
    final formKey = GlobalKey<FormState>();

    // If editing a user whose role is not allowed, prevent edit
    if (user != null && !allowed.contains(user.role) && AuthService().currentUser?.role != 'owner') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot edit this user')));
      return;
    }

    final res = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(user == null ? 'Create User' : 'Edit User'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: usernameCtrl,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: passwordCtrl,
                decoration: InputDecoration(labelText: user == null ? 'Password' : 'New password (leave blank to keep)'),
                obscureText: true,
                validator: (v) {
                  if (user == null && (v == null || v.isEmpty)) return 'Required';
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: role,
                items: allowed.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => role = v ?? role,
                decoration: const InputDecoration(labelText: 'Role'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final username = usernameCtrl.text.trim();
              final password = passwordCtrl.text;
              try {
                if (user == null) {
                  await _db.createUser({'username': username, 'password': password, 'role': role});
                } else {
                  final data = {'username': username, 'role': role};
                  if (password.isNotEmpty) data['password'] = password;
                  await _db.updateUser(user.id!, data);
                }
                Navigator.of(c).pop(true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (res == true) await _refreshUsers();
  }

  Future<void> _deleteUser(int id) async {
    if (id == AuthService().currentUser?.id) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot delete yourself')));
      return;
    }
    await _db.deleteUserById(id);
    await _refreshUsers();
  }

  Future<void> _inspectDb() async {
    final all = await _db.getAllUsers();
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('DB Users (raw)'),
        content: SizedBox(
          width: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: all.length,
            itemBuilder: (context, i) {
              final r = all[i];
              return ListTile(title: Text('${r['id']}: ${r['username']}'), subtitle: Text('role=${r['role']}'));
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Close'))],
      ),
    );
    for (final r in all) {
      // ignore: avoid_print
      print('USER ROW: $r');
    }
  }

  Future<void> _seedManager() async {
    final existing = await _db.getUserByUsername('manager1');
    if (existing != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('manager1 already exists')));
      return;
    }
    await _db.createUser({'username': 'manager1', 'password': 'managerpass', 'role': 'manager'});
    await _refreshUsers();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeded manager1 / managerpass')));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('User Management'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(icon: const Icon(Icons.search), onPressed: _inspectDb, tooltip: 'Inspect DB'),
                IconButton(icon: const Icon(Icons.person_add), onPressed: _seedManager, tooltip: 'Seed manager1'),
              ],
            )
          : null,
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: EdgeInsets.only(top: widget.showAppBar ? kToolbarHeight + 24 : 0),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _users.length,
          itemBuilder: (context, i) {
            final u = _users[i];
            return Card(
              color: const Color(0xFF36444D),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(u.username, style: const TextStyle(color: Colors.white)),
                subtitle: Text(u.role.toUpperCase(), style: const TextStyle(color: Colors.lightBlueAccent)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.white70), onPressed: () => _showForm(user: u)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => _deleteUser(u.id!)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF00E5FF),
        child: const Icon(Icons.add),
      ),
    );
  }
}
