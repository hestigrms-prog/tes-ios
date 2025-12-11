import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'services/location_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'providers/location_provider.dart';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // // Init Firebase
  // await Firebase.initializeApp();
  // // Tangkap error Flutter ke Crashlytics
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // // Tangkap error dari zona Dart
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  // permission
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) {
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(child: Text("Lokasi wajib diaktifkan di Settings")),
      ),
    ));
    return;
  }

  // start service
  await LocationService.startService();

  // main
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocationProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Absensi App',
      home: SplashScreen(),
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoggedIn = false;
  bool _serviceStatus = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();

    // cek service sudah running atau belum
    FlutterBackgroundService().isRunning().then((running) async {
      setState(() => _serviceStatus = running);
      if (!running) {
        await LocationService.startService();
        setState(() => _serviceStatus = true);
      }
    });

    // Listener realtime lokasi
    FlutterBackgroundService().on("update_location").listen((event) {
      if (event != null && event.containsKey("latitude")) {
        String lat = event["latitude"].toString();
        String lng = event["longitude"].toString();
        String time = event["timestamp"];
        Provider.of<LocationProvider>(context, listen: false)
            .updateLocation(lat, lng, time);
      }
    });
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // simulasi delay splash screen 2 detik
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoggedIn = token != null;
    });

    // navigasi ke halaman sesuai login
    if (_isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}