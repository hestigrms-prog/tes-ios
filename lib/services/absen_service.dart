// File: services/absen_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/shift.dart';
import '../config.dart';

class AbsenService {
  static bool cekTelat(String jamMasuk, int toleransiMenit) {
    final now = DateTime.now();
    final parts = jamMasuk.split(":");
    final masukTime = DateTime(now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]));
    final toleransi = Duration(minutes: toleransiMenit);
    return now.isAfter(masukTime.add(toleransi));
  }

  static bool bolehAbsenPulang({
    required String jamMasuk,         // ex: '08:00'
    required String jamPulang,        // ex: '17:00'
    required String waktuAbsenMasuk,  // ex: '08:30'
  }) {
    final format = DateFormat('HH:mm');
    // Parsing jam kerja dan waktu absen
    final masukTime = format.parse(jamMasuk);
    final pulangTime = format.parse(jamPulang);
    final absenTime = format.parse(waktuAbsenMasuk);
    // Durasi kerja
    final durasiKerja = pulangTime.difference(masukTime);
    // Hitung waktu minimum boleh absen pulang
    final minimalPulangTime = absenTime.add(durasiKerja);
    // Sekarang
    final now = DateTime.now();
    final nowTime = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    // Sesuaikan minimalPulangTime ke tanggal hari ini
    final adjustedMinimalPulang = DateTime(
      now.year,
      now.month,
      now.day,
      minimalPulangTime.hour,
      minimalPulangTime.minute,
    );
    return nowTime.isAfter(adjustedMinimalPulang);
  }

  static bool isHarusAbsenPulang({
    required String jamMasukStr,
    required DateTime now,
    required bool sudahAbsenMasuk,
  }) {
    try {
      final parts = jamMasukStr.split(':');
      if (parts.length != 2) return false;
      final jam = int.parse(parts[0]);
      final menit = int.parse(parts[1]);
      final jamMasuk = DateTime(now.year, now.month, now.day, jam, menit);
      final selisih = now.difference(jamMasuk);
      return selisih.inHours >= 5 && !sudahAbsenMasuk;
    } catch (e) {
      print('Gagal parsing jamMasuk: $e');
      return false;
    }
  }


  static Future<void> handleAbsenMasuk({
    required BuildContext context,
    required Shift shift,
    required CameraController? cameraController,
    required currentPosition,
    required DateTime currentTime,
    required Function(String) alasanCallback,
    required Function onSuccess,
  }) async {
    try {
      // Ambil foto
      final picture = await cameraController!.takePicture();
      final File imageFile = File(picture.path);
      final compressedImage = await _compressImage(imageFile);
      final base64Image = base64Encode(await compressedImage.readAsBytes());

      // Cek keterlambatan
      final isTelat = cekTelat(shift.jamMasuk, int.parse(shift.toleransiKeterlambatan));
      String alasan = '';

      if (isTelat) {
        alasan = await _showAlasanTelatDialog(context);
        alasanCallback(alasan);
      }

      final prefs = await SharedPreferences.getInstance();
      final pegawaiId = prefs.getString('pegawai_id') ?? '';

      final response = await http.post(
        Uri.parse("${AppConfig.baseApiUrl}/api/absensi/masuk"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "pegawai_id": pegawaiId,
          "shift_id": shift.shiftId,
          "shift_jam_masuk": shift.jamMasuk,
          "shift_jam_pulang": shift.jamPulang,
          "tanggal": shift.tanggal,
          "jam_masuk": DateFormat('HH:mm').format(currentTime),
          "koordinat_masuk": currentPosition.latitude.toString()+','+currentPosition.longitude.toString(),
          "foto_masuk": 'data:image/jpeg;base64,'+base64Image,
          "status_telat": (isTelat) ? 'T' : '',
          "alasan_telat": alasan,
          "app": "mobile"
        }),
      );

      if (response.statusCode == 200) {
        onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kamu berhasil absen hari ini :)')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ups, kamu gagal absen!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  static Future<void> handleAbsenPulang({
    required BuildContext context,
    required Shift shift,
    required CameraController? cameraController,
    required currentPosition,
    required DateTime currentTime,
    required Function(String) alasanCallback,
    required Function onSuccess,
  }) async {
    try {
      // Ambil foto
      final picture = await cameraController!.takePicture();
      final File imageFile = File(picture.path);
      final compressedImage = await _compressImage(imageFile);
      final base64Image = base64Encode(await compressedImage.readAsBytes());

      // Cek pulang cepat
      bool isPulangAwal = false;
      if(shift.jamMasukAbsen != ''){
        if (!bolehAbsenPulang(
          jamMasuk: shift.jamMasuk,
          jamPulang: shift.jamPulang,
          waktuAbsenMasuk: shift.jamMasukAbsen, // waktu saat absen masuk
        )) {
          isPulangAwal = true;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final pegawaiId = prefs.getString('pegawai_id') ?? '';
      final idAbsen = shift.idAbsen;

      final response = await http.post(
        Uri.parse("${AppConfig.baseApiUrl}/api/absensi/pulang"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "pegawai_id": pegawaiId,
          "id": idAbsen,
          "shift_id": shift.shiftId,
          "shift_jam_masuk": shift.jamMasuk,
          "shift_jam_pulang": shift.jamPulang,
          "tanggal": shift.tanggal,
          "jam_pulang": DateFormat('HH:mm').format(currentTime),
          "koordinat_pulang": currentPosition.latitude.toString()+','+currentPosition.longitude.toString(),
          "foto_pulang": 'data:image/jpeg;base64,'+base64Image,
          "status_pulang_cepat": (isPulangAwal) ? 'C' : '',
          "app": "mobile"
        }),
      );

      if (response.statusCode == 200) {
        onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kamu berhasil absen pulang :)')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ups, kamu gagal absen pulang!')),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  static Future<File> _compressImage(File image) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final compressed = await FlutterImageCompress.compressAndGetFile(
      image.path,
      targetPath,
      quality: 50,
    );
    if (compressed == null) {
      throw Exception("Aduh, gagal mengompres gambar :(");
    }
    return File(compressed.path);
  }

  static Future<String> _showAlasanTelatDialog(BuildContext context) async {
    String alasan = '';
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Alasan Telat'),
          content: TextField(
            autofocus: true,
            onChanged: (value) => alasan = value,
            decoration: InputDecoration(labelText: 'Masukkan alasan'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Kirim'),
            ),
          ],
        );
      },
    );
    return alasan;
  }
}
