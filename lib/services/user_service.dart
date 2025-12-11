import '../config.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<Pegawai> fetchUser() async {
  final prefs = await SharedPreferences.getInstance();
  final String? pegawaiId = prefs.getString('pegawai_id');

  final response = await http.post(
    Uri.parse('${AppConfig.baseApiUrl}/api/get-profile'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'pegawai_id': pegawaiId.toString()
    }),
  );

  if (response.statusCode == 200) {
    return Pegawai.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Gagal mengambil data user!');
  }
}