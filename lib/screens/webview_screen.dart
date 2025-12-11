import 'package:absensi_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({Key? key}) : super(key: key);

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  late final WebViewController _controller;

  String _namaPegawai = '';

  @override
  void initState() {
    final PlatformWebViewControllerCreationParams params =
      const PlatformWebViewControllerCreationParams();

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    // Konfigurasi tambahan
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://flutter.dev')); // Ubah ke URL kamu

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
    }

    _controller = controller;

    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaPegawai = prefs.getString('nama_pegawai').toString();
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // hapus semua data login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman Webview', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 1,
        actions: [
        IconButton(
          icon: Icon(Icons.logout, color: Colors.black),
          tooltip: 'Logout',
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Logout', style: TextStyle(color: Colors.blue)),
                content: Text('$_namaPegawai, Apakah Kamu yakin ingin logout?'),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        child: Text('Batal'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        child: Text('Logout'),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                ],
              ),
            );

            if (confirm == true) {
              _logout();
            }
          },
        ),
      ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}