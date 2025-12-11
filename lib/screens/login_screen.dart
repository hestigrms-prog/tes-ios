import 'package:absensi_app/services/location_service.dart';

import '../config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'home_screen.dart';
import 'lupa_password_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _submitLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.parse('${AppConfig.baseApiUrl}/api/login');
      try {
        final response = await http.post(
          url,
          headers: {'Accept': 'application/json'},
          body: {
            'username': username, 
            'password': password,
            'app_id': '3',
            'remember_me': '0'
          },
        );

        final data = json.decode(response.body);

        if (response.statusCode == 200) {
          if(data['status'] == 'success'){
            final pegawai = data['pegawai'];
            final user = data['user'];
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', 'true');
            await prefs.setString('pegawai_id', pegawai['pegawai_id']);
            await prefs.setString('branch_id', pegawai['branch_id']);
            await prefs.setString('organisai_id', pegawai['organisasi_id']);
            await prefs.setString('job_level_id', pegawai['job_level_id']);
            await prefs.setString('job_position_id', pegawai['job_position_id']);
            await prefs.setString('branch', pegawai['branch']);
            await prefs.setString('organisai', pegawai['organisasi']);
            await prefs.setString('job_level', pegawai['job_level']);
            await prefs.setString('job_position', pegawai['job_position']);
            await prefs.setString('nama_pegawai', pegawai['nama_pegawai']);
            await prefs.setString('nomor_pegawai', pegawai['nomor_pegawai']);
            await prefs.setString('foto', pegawai['foto']);
            await prefs.setString('_username', username);
            await prefs.setString('username', data['username']);
            await prefs.setString('_password', password);
            await prefs.setString('password', data['password']);
            await prefs.setString('user_id', user['id']);
            await prefs.setInt('lokasi_terkini', data['lokasi_terkini']);
            await LocationService.startService();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          }else{
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(data['message'] ?? 'Ups, Kamu gagal login :('),
            ));
          }
        } else {
          // final error = json.decode(response.body);
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
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
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
            color: Colors.white.withOpacity(0.5),
          ),
        
          // Form login
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Image.asset(
                        'assets/icon/logo.png',
                        height: 100,
                      ),
                      const SizedBox(height: 40),

                      // Username
                      TextFormField(
                        controller: usernameController,
                        validator: (value) => value!.isEmpty ? 'Username tidak boleh kosong' : null,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          hintText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(1),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        validator: (value) => value!.isEmpty ? 'Password tidak boleh kosong' : null,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(1),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Lupa Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LupaPasswordScreen()),
                            );
                          },
                          child: const Text(
                            'Lupa Password?',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Tombol Masuk
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Masuk',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
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