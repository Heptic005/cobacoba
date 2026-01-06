import 'package:dakara_weighbridge/Services/auth_service.dart';
import 'package:dakara_weighbridge/dashboard.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedShift = 'Shift 1';
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final auth = AuthService();
      final user = await auth.login(
        _usernameController.text,
        _passwordController.text,
        _selectedShift,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid Username or Password"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2830), // Dark Industrial Background
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF262F36),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.white10),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo or Title
                const Text(
                  "DAKARA WEIGHBRIDGE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "SYSTEM LOGIN",
                  style: TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 14,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 40),

                // Username
                TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "USERNAME",
                    labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Color(0xFF00E5FF),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF00E5FF)),
                    ),
                  ),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 20),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "PASSWORD",
                    labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Color(0xFF00E5FF),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF00E5FF)),
                    ),
                  ),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 20),

                // Shift Selector
                DropdownButtonFormField<String>(
                  value: _selectedShift,
                  dropdownColor: const Color(0xFF36444D),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "SHIFT",
                    labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                    prefixIcon: Icon(
                      Icons.access_time,
                      color: Color(0xFF00E5FF),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                  ),
                  items:
                      ['Shift 1', 'Shift 2', 'Shift 3']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _selectedShift = val!),
                ),
                const SizedBox(height: 40),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.black,
                            )
                            : const Text(
                              "LOGIN",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
