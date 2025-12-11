import '../config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'login_screen.dart';

class LupaPasswordScreen extends StatefulWidget {
  @override
  _LupaPasswordScreenState createState() => _LupaPasswordScreenState();
}

class _LupaPasswordScreenState extends State<LupaPasswordScreen> {
  final usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _submitResetPassword() async {
    final username = usernameController.text.trim();

    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.parse('${AppConfig.baseApiUrl}/api/reset-password');
      try {
        final response = await http.post(
          url,
          headers: {'Accept': 'application/json'},
          body: {
            'username': username
          },
        );

        final data = json.decode(response.body);
        if (response.statusCode == 200) {
          if(data['status'] == 'success'){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(data['message'] ?? 'Permintaan reset password kamu berhasil :)'),
            ));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            );
          }else{
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(data['message'] ?? 'Ups, Kamu gagal login :('),
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(data['message'] ?? 'Ups, Kamu gagal login :('),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aduh, terjadi kesalahan: $e')),
        );
      } finally {
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SvgPicture.asset(
            'assets/images/working.svg', 
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          Container(
            color: Colors.white.withOpacity(0.8),
          ),

          // Form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo & Judul
                      Image.asset(
                        'assets/icon/logo.png',
                        height: 100,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Lupa Password',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 72, 42, 241),
                        ),
                      ),
                      const Text(
                        'Masukkan Username Anda',
                        style: TextStyle(color: Color.fromARGB(255, 72, 42, 241)),
                      ),
                      const SizedBox(height: 28),

                      // Username
                      TextFormField(
                        controller: usernameController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Username tidak boleh kosong'
                            : null,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          hintText: 'Masukkan Username Kamu',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(1),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Kembali ke Login
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                          },
                          child: const Text(
                            'Kembali ke Login?',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Tombol Berikutnya
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitResetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Berikutnya',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}