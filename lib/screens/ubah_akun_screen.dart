import 'package:absensi_app/screens/login_screen.dart';

import '../config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UbahAkunScreen extends StatefulWidget {
  const UbahAkunScreen({super.key});

  @override
  State<UbahAkunScreen> createState() => _UbahAkunScreenState();
}

class _UbahAkunScreenState extends State<UbahAkunScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordLamaController = TextEditingController();
  final _passwordBaruController = TextEditingController();
  final _konfirmasiPasswordController = TextEditingController();

  String? _passwordTersimpan;

  bool _obscureLama = true;
  bool _obscureBaru = true;
  bool _obscureKonfirmasi = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('_username') ?? '';
    final password = prefs.getString('_password'); // disimpan untuk cek password lama
    setState(() {
      _usernameController.text = username;
      _passwordTersimpan = password;
    });
  }

  Future<void> _simpanPerubahan() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final username = _usernameController.text;
      final passwordBaru = _passwordBaruController.text.isNotEmpty
          ? _passwordBaruController.text
          : _passwordTersimpan ?? '';
      final user_id = prefs.getString('user_id');

      try {
        final url = Uri.parse('${AppConfig.baseApiUrl}/api/ubah-password');
        final response = await http.post(
          url,
          headers: {'Accept': 'application/json'},
          body: {
            'username': username, 
            'password': passwordBaru,
            'user_id': user_id
          },
        );

        if (response.statusCode == 200) {
          // jika API sukses
          await prefs.setString('_username', username);
          await prefs.setString('_password', passwordBaru);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perubahan berhasil disimpan')),
          );

          await prefs.clear(); // hapus semua data login kalau berhasil ubah password
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
        } else {
          // jika API gagal
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal update: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }


  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Ubah Password"),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              
              // Username
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Username tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),

              // Password Lama
              _buildPasswordField(
                label: "Password Lama",
                controller: _passwordLamaController,
                obscureText: _obscureLama,
                onToggle: () => setState(() => _obscureLama = !_obscureLama),
              ),
              const SizedBox(height: 12),

              // Password Baru
              _buildPasswordField(
                label: "Password Baru",
                controller: _passwordBaruController,
                obscureText: _obscureBaru,
                onToggle: () => setState(() => _obscureBaru = !_obscureBaru),
              ),
              const SizedBox(height: 12),

              // Konfirmasi Password
              TextFormField(
                controller: _konfirmasiPasswordController,
                obscureText: _obscureKonfirmasi,
                decoration: InputDecoration(
                  labelText: "Konfirmasi Password Baru",
                  suffixIcon: IconButton(
                    icon: Icon(_obscureKonfirmasi
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscureKonfirmasi = !_obscureKonfirmasi),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                validator: (value) {
                  if (_passwordBaruController.text.isNotEmpty) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi Password tidak boleh kosong';
                    }
                    if (value != _passwordBaruController.text) {
                      return 'Password konfirmasi tidak sama';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  if (_passwordLamaController.text != _passwordTersimpan) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Password lama tidak sesuai')),
                    );
                    return;
                  }
                  _simpanPerubahan();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.red.shade200,
                  disabledForegroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // ubah angka sesuai kebutuhan
                  ),
                ),
                child: const Text("Simpan Perubahan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
