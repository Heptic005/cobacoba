import 'package:dakara_weighbridge/Json/user_model.dart';
import 'package:dakara_weighbridge/SQLite/database_helper.dart';
import 'package:dakara_weighbridge/Services/auth_service.dart';
import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<UserModel> _users = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'operator';

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  Future<void> _refreshUsers() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper().queryAll('users');
    setState(() {
      _users = data.map((e) => UserModel.fromJson(e)).toList();
      _isLoading = false;
    });
  }

  List<String> _getAllowedRoles() {
    if (AuthService().isManager) {
      return ['supervisor', 'ktu', 'operator'];
    } else if (AuthService().isSupervisor) {
      return ['operator'];
    }
    return [];
  }

  bool _canManageUser(UserModel targetUser) {
    if (AuthService().isManager) {
      // Manager can manage everyone except probably other owners/admins if we want to be strict,
      // but let's assume they can manage subordinates.
      // Prevent deleting self
      if (targetUser.id == AuthService().currentUser?.id) return false;
      return true;
    } else if (AuthService().isSupervisor) {
      // Supervisor can only manage operators
      return targetUser.role == 'operator';
    }
    return false;
  }

  Future<void> _addOrUpdateUser({UserModel? user}) async {
    final allowedRoles = _getAllowedRoles();
    if (allowedRoles.isEmpty) return;

    // Reset default role to first allowed if not editing
    if (user == null && allowedRoles.isNotEmpty) {
      _selectedRole = allowedRoles.first;
    }

    if (user != null) {
      _usernameController.text = user.username;
      _passwordController.text = ""; // Don't show password hash
      _selectedRole = user.role;
      // If editing a user with a role not in allowed list (e.g. Manager editing another Manager), handle dynamically?
      // For now, assume strict hierarchy.
      if (!allowedRoles.contains(_selectedRole)) {
        // If the target user has a role we can't assign (e.g. Manager > Manager), maybe just show it
        allowedRoles.add(_selectedRole);
      }
    } else {
      _usernameController.clear();
      _passwordController.clear();
    }

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF262F36),
            title: Text(
              user == null ? 'Add User' : 'Edit User',
              style: const TextStyle(color: Colors.white),
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Please enter a username' : null,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText:
                          user == null
                              ? 'Password'
                              : 'New Password (Leave blank to keep)',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                    ),
                    validator: (value) {
                      if (user == null && value!.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    dropdownColor: const Color(0xFF262F36),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                    ),
                    items:
                        allowedRoles.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role.toUpperCase()),
                          );
                        }).toList(),
                    onChanged:
                        (value) => setState(() => _selectedRole = value!),
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
                    // Should hash password here if we were doing it properly in UI,
                    // but AuthService has a hash method. Let's use it or just save plain for now if AuthService matches plain.
                    // Re-checking AuthService... it compares hash OR plain.
                    // Let's safe plain for now or hash it?
                    // Let's use AuthService().hashPassword if available, otherwise just text.
                    // AuthService is not exported here? It is.

                    String passwordToSave = _passwordController.text;
                    // If editing and password blank, keep old
                    if (user != null && passwordToSave.isEmpty) {
                      passwordToSave = user.password;
                    } else {
                      // Hash it
                      // Assuming AuthService.hashPassword is just a helper we can call?
                      // It's an instance method.
                      passwordToSave = AuthService().hashPassword(
                        passwordToSave,
                      );
                    }

                    final model = UserModel(
                      id: user?.id,
                      username: _usernameController.text,
                      password: passwordToSave,
                      role: _selectedRole,
                    );

                    if (user == null) {
                      await DatabaseHelper().insert(
                        'users',
                        model.toJson()..remove('id'),
                      );
                    } else {
                      await DatabaseHelper().update(
                        'users',
                        model.toJson(),
                        user.id!,
                      );
                    }
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _refreshUsers();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteUser(int id) async {
    await DatabaseHelper().delete('users', id);
    _refreshUsers();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateUser(),
        backgroundColor: const Color(0xFF00E5FF),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final canEdit = _canManageUser(user);

          return Card(
            color: const Color(0xFF36444D),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                user.username,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                user.role.toUpperCase(),
                style: const TextStyle(color: Colors.white70),
              ),
              trailing:
                  canEdit
                      ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () => _addOrUpdateUser(user: user),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deleteUser(user.id!),
                          ),
                        ],
                      )
                      : null,
            ),
          );
        },
      ),
    );
  }
}
