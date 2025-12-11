// File: absensi_screen.dart
import 'dart:async';
import 'dart:io';

import 'package:absensi_app/screens/login_screen.dart';
import 'package:absensi_app/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:path/path.dart' as p;
// import 'package:http/http.dart' as http;
// import '../config.dart';
import '../models/shift.dart';
import '../services/shift_service.dart';
import '../services/absen_service.dart';

class AbsensiScreen extends StatefulWidget {
  @override
  _AbsensiScreenState createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  late Future<Shift> shiftFuture = fetchShift();
  late DateTime _currentTime;
  late Timer _timer;

  Position? _currentPosition;
  CameraController? _cameraController;
  File? _image;
  bool _sudahAbsenMasuk = false;
  bool _sudahBisaPulang = false;
  bool _ishariLibur = false;
  String _labelLibur = 'Kamu sedang Cuti/DL.';

  String _namaPegawai = '';
  String latitude = '-6.200000'; 
  String longitude = '106.816666';

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _getLocation();
    _initializeCamera();
    _currentTime = DateTime.now();
    _startClock();
    _loadAbsenStatus();
    _loadData();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _startClock() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  Future<void> _getLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _handleAbsenMasuk(Shift shift) async {
    await AbsenService.handleAbsenMasuk(
      context: context,
      shift: shift,
      cameraController: _cameraController,
      currentPosition: _currentPosition,
      currentTime: _currentTime,
      alasanCallback: (value) => value,
      onSuccess: () async {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('sudah_absen_masuk', true);
        setState(() {
          _sudahAbsenMasuk = true;
          _sudahBisaPulang = true;
          shiftFuture = fetchShift();
        });
        await _initializeCamera();
      },
    );
  }

  Future<void> _handleAbsenPulang(Shift shift) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Absen Pulang', style: TextStyle(color: Colors.blue)),
        content: Text('$_namaPegawai, Apakah Kamu yakin ingin melakukan absen pulang sekarang?'),
        actions: [
          ElevatedButton(
            child: Text('Batal'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: Text('Ya'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AbsenService.handleAbsenPulang(
        context: context,
        shift: shift,
        cameraController: _cameraController,
        currentPosition: _currentPosition,
        currentTime: _currentTime,
        alasanCallback: (value) => value,
        onSuccess: () async {
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('sudah_absen_pulang', true);
          setState(() {
            _sudahBisaPulang = false;
            shiftFuture = fetchShift();
          });
          await _initializeCamera();
        },
      );
    }
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.location.request();
  }

  Future<void> _loadAbsenStatus() async {
    final shift = await shiftFuture;
    setState(() {
      final bool autoPulang = AbsenService.isHarusAbsenPulang(
        jamMasukStr: shift.jamMasuk,
        now: _currentTime,
        sudahAbsenMasuk: _sudahAbsenMasuk,
      );

      if(shift.jmlCutiDl == '0'){
        if(shift.namaLibur != ""){
          _sudahAbsenMasuk = true;
          _sudahBisaPulang = false;
          _ishariLibur = true;
          _labelLibur = shift.namaLibur;
        }else{
          if(shift.jamMasuk == '00:00'){
            _sudahAbsenMasuk = true;
            _sudahBisaPulang = false;
            _ishariLibur = true;
            _labelLibur = shift.namaShift;
          }else{
            if(shift.jamMasukAbsen != ''){ //kalau sudah absen masuk
              _sudahAbsenMasuk = true;
            }else{
              if(autoPulang){ //kalau sudah melewati 5 jam
                _sudahAbsenMasuk = true;
              }else{
                _sudahAbsenMasuk = false; //bisa absen masuk
              }
            }

            if(shift.jamPulangAbsen != ''){ //kalau sudah absen pulang tidak absen lagi
              _sudahBisaPulang = false;
            }else{
              if(autoPulang){ //kalau sudah melebihi 5 jam bisa absen
                _sudahBisaPulang = true;
              }else if(shift.jamMasukAbsen != ''){
                _sudahBisaPulang = true; //sudah absen masuk
              }
            }
          }
        }
      }else{
        _sudahAbsenMasuk = true;
        _sudahBisaPulang = false;
        _ishariLibur = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kamu sedang Cuti/DL.')),
        );
      }
    });

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Absensi Karyawan', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 1,
        actions: [
        IconButton(
          icon: Icon(Icons.logout, color: Colors.black),
          tooltip: 'Logout',
          onPressed: () async {
            _logout();
          },
        ),
      ],
      ),
      body: FutureBuilder<Shift>(
        future: shiftFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Gagal memuat data shift'));
          if (!snapshot.hasData) return SizedBox();

          final shift = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Shift: ${shift.namaShift}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Jam Masuk: ${shift.jamMasuk}', style: TextStyle(fontSize: 13)),
                          Text('Jam Pulang: ${shift.jamPulang}', style: TextStyle(fontSize: 13)),
                          SizedBox(height: 8),
                          Text('Sekarang:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            ((_ishariLibur) ? _labelLibur : '${DateFormat.Hms().format(_currentTime)}'),
                            style: TextStyle(
                              color: AbsenService.cekTelat(shift.jamMasuk, int.parse(shift.toleransiKeterlambatan)) && (shift.jamMasukAbsen == '')
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              height: 1
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Absen hari ini:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Absen Masuk: ${shift.jamMasukAbsen}', style: TextStyle(fontSize: 13)),
                          Text('Absen Pulang: ${shift.jamPulangAbsen}', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _cameraController != null && _cameraController!.value.isInitialized
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CameraPreview(_cameraController!),
                            )
                          : Center(child: CircularProgressIndicator()),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                if (_currentPosition != null)
                  Container(
                    height: 250,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                          _currentPosition!.latitude, 
                          _currentPosition!.longitude
                        ),
                        initialZoom: 16.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: ['a', 'b', 'c'],
                          userAgentPackageName: 'com.absensi.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 40.0,
                              height: 40.0,
                              point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                              child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _sudahAbsenMasuk ? null : () => _handleAbsenMasuk(shift), //ketika true tombol tidak bisa di klik
                        child: Text('Absen Masuk'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Warna tombol
                          foregroundColor: Colors.white, // Warna teks
                          disabledBackgroundColor: Colors.blue.shade200, // Saat disable
                          disabledForegroundColor: Colors.white, // Teks saat disable
                          minimumSize: const Size.fromHeight(45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5), // ⬅️ lebih kotak
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _sudahBisaPulang ? () => _handleAbsenPulang(shift) : null, //ketika true tombol bisa diklik
                        child: Text('Absen Pulang'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.red.shade200,
                          disabledForegroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5), // ⬅️ lebih kotak
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (_image != null) ...[
                  SizedBox(height: 16),
                  Image.file(_image!, height: 150),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
