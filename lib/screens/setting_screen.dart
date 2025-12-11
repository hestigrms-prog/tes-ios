import 'package:absensi_app/screens/location_setting_screen.dart';
import 'package:absensi_app/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:absensi_app/screens/login_screen.dart';
import 'package:absensi_app/screens/profile_screen.dart';
import 'package:absensi_app/screens/tentang_screen.dart';
import 'package:absensi_app/screens/ubah_akun_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

@override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Tambahkan variabel _namaPegawai
  String _namaPegawai = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaPegawai = prefs.getString('nama_pegawai').toString();
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        title: Text('Logout', style: TextStyle(color: Colors.blue), textAlign: TextAlign.center),
        content: Text('$_namaPegawai, Apakah Kamu yakin ingin logout?', textAlign: TextAlign.center),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text('Batal'),
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                )
              ),
              SizedBox(width: 16),
              ElevatedButton(
                child: Text('Logout'),
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                )
              ),
            ],
          ),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // hapus semua data login
      await LocationService.stopService();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // List pengaturan
    final List<Map<String, dynamic>> settingsItems = [
      {
        'icon': Icons.person,
        'title': 'Profil',
        'subtitle': 'Lihat profil Anda',
      },
      {
        'icon': Icons.lock,
        'title': 'Ubah Password',
        'subtitle': 'Ganti kata sandi Anda',
      },
      {
        'icon': Icons.location_city,
        'title': 'Lokasi Terkini',
        'subtitle': 'Aktifkan lokasi terkini Anda',
      },
      {
        'icon': Icons.info,
        'title': 'Tentang Aplikasi',
        'subtitle': 'Informasi versi dan pembuat aplikasi',
      },
      {
        'icon': Icons.logout,
        'title': 'Keluar',
        'subtitle': 'Logout dari aplikasi',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Daftar pengaturan
          ...List.generate(settingsItems.length, (index) {
            final item = settingsItems[index];
            return Column(
              children: [
                ListTile(
                  leading: Icon(item['icon'], color: Colors.red),
                  title: Text(item['title']),
                  subtitle: Text(item['subtitle']),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    switch (item['title']) {
                      case 'Profil':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
                        break;
                      case 'Ubah Password':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => UbahAkunScreen()));
                        break;
                      case 'Lokasi Terkini':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => LocationSettingScreen()));
                        break;
                      case 'Tentang Aplikasi':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => TentangScreen()));
                        break;
                      case 'Keluar':
                        _logout();
                        break;
                    }
                  },
                ),
                Divider(height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}