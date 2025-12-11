import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'package:flutter/material.dart'; // diperlukan untuk AndroidInitializationSettings

@pragma('vm:entry-point')
class LocationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ID channel yang konsisten (harus sama di configure dan saat membuat channel)
  static const String _channelId = 'location_service';

  // Buat dan inisialisasi channel sebelum startService dipanggil
  @pragma('vm:entry-point')
  static Future<void> initNotificationChannel() async {
    // Android init settings (pakai ic_launcher default). 
    // Pastikan file ic_launcher ada di mipmap.
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      'Absensi Service',
      description: 'Notifikasi untuk service absensi',
      importance: Importance.low,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // onStart -> jalankan kode background. Jangan create channel di sini (sudah dibuat di initNotificationChannel)
  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Pastikan plugin di-registrasi untuk background isolate
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      // Pastikan setForegroundNotificationInfo dipanggil (title & content tidak null)
      service.setForegroundNotificationInfo(
        title: "Absensi Service",
        content: "Mengirim lokasi ke server",
      );
    }

    print("✅ Service onStart dipanggil");

    final prefs = await SharedPreferences.getInstance();
    int _lokasiTerkiniTimer = prefs.getInt('lokasi_terkini') ?? 60;

    // Timer kirim lokasi tiap _lokasiTerkiniTimer detik
    Timer.periodic(Duration(seconds: _lokasiTerkiniTimer), (_) async {
      try {
        if (!(await Geolocator.isLocationServiceEnabled())) return;

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        await sendLocationToServer(
            position.latitude.toString(), position.longitude.toString());

        service.invoke("update_location", {
          "latitude": position.latitude.toString(),
          "longitude": position.longitude.toString(),
          "timestamp": DateTime.now().toIso8601String(),
        });
      } catch (e, st) {
        print("Error send location: $e");
        service.invoke("update_location", {
          "error": e.toString(),
          "timestamp": DateTime.now().toIso8601String(),
        });
      }
    });

    // Stop listener
    service.on("stopService").listen((event) {
      print("🛑 Stop Service dipanggil");
      service.stopSelf();
    });
  }

  // startService: buat channel & initialize dulu, lalu configure service
  @pragma('vm:entry-point')
  static Future<void> startService() async {
    final service = FlutterBackgroundService();

    // 1) Init/create channel terlebih dahulu (Wajib!)
    await initNotificationChannel();

    // 2) Configure service. Pastikan notificationChannelId sama dengan channel yang dibuat
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: LocationService.onStart,
        isForegroundMode: true,
        autoStart: true,
        notificationChannelId: _channelId, // HARUS sama
        initialNotificationTitle: 'Absensi Service',
        initialNotificationContent: 'Sedang berjalan...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: LocationService.onStart,
        onBackground: LocationService.onIosBackground,
      ),
    );

    // 3) Start service
    service.startService();
  }

  @pragma('vm:entry-point')
  static bool onIosBackground(ServiceInstance service) {
    return true;
  }

  @pragma('vm:entry-point')
  static Future<void> sendLocationToServer(String lat, String lng) async {
    final prefs = await SharedPreferences.getInstance();
    final String? pegawaiId = prefs.getString('pegawai_id');

    print("✅ Kirim lokasi: $lat,$lng");

    try {
      await http.post(
        Uri.parse('${AppConfig.baseApiUrl}/api/lokasi-terkini'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pegawai_id': pegawaiId,
          'koordinat': '$lat,$lng',
        }),
      );
    } catch (e) {
      print("Gagal kirim lokasi: $e");
    }
  }

  @pragma('vm:entry-point')
  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke("stopService");
  }
}
