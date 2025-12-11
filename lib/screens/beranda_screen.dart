import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../config.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({Key? key}) : super(key: key);

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  InAppWebViewController? _controller;
  String? _username;
  String? _password;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
      _password = prefs.getString('password') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading sementara SharedPreferences belum siap
    if (_username == null || _password == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final loginUrl = '${AppConfig.baseApiUrl}/login/redirect/${Uri.encodeComponent(_username!)}/${Uri.encodeComponent(_password!)}';

    return Scaffold(
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(loginUrl)),
        onWebViewCreated: (controller) {
          _controller = controller;
        },
        // Gunakan settings untuk mengaktifkan fitur
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true, // JavaScript aktif
          mediaPlaybackRequiresUserGesture: false,
        ),
      ),
    );
  }
}
