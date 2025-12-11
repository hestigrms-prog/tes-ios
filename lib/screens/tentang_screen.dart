import 'package:flutter/material.dart';

class TentangScreen extends StatelessWidget {
  const TentangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            // Logo Aplikasi
            Center(
              child: Image.asset(
                'assets/icon/logo.png', // Ganti dengan path logo aplikasi
                height: 120,
              ),
            ),
            const SizedBox(height: 32),

            // Nama Aplikasi
            const Text(
              'Absensi Karyawan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Versi Aplikasi
            const Text(
              'Versi 1.0.0',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 32),

            // Deskripsi Aplikasi
            const Text(
              'Aplikasi ini digunakan untuk memudahkan proses absensi karyawan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 104),

            // Spacer untuk mendorong konten ke atas
            const Spacer(),

            Column(
              children: const [
                // Copyright
                const Text(
                  textAlign: TextAlign.center,
                  '© 2025 PT BOS. Semua hak dilindungi.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 6),

                // Informasi Pembuat
                const Text(
                  textAlign: TextAlign.center,
                  'Dibuat oleh: Tim Babah Digital',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ]
            ),
          ],
        ),
      ),
    );
  }
}
