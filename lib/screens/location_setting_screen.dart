import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/location_provider.dart';
import '../services/location_service.dart';

class LocationSettingScreen extends StatefulWidget {
  const LocationSettingScreen({super.key});

  @override
  _LocationSettingScreenState createState() => _LocationSettingScreenState();
}

class _LocationSettingScreenState extends State<LocationSettingScreen> {
  String currentLocation = "-";
  bool _serviceStatus = false;
  String status = "Tidak Aktif";
  int _interval = 15;

  @override
  void initState() {
    super.initState();
    _loadData();

    FlutterBackgroundService().isRunning().then((running) {
      setState(() {
        _serviceStatus = running;
        status = running ? "Aktif" : "Tidak Aktif";
      });
    });

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

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _interval = prefs.getInt('lokasi_terkini') ?? 15;
    });
  }

  void _toggleService() async {
    if (_serviceStatus) {
      await LocationService.stopService();
      Provider.of<LocationProvider>(context, listen: false).reset();
      setState(() {
        _serviceStatus = false;
        status = "Tidak Aktif";
      });
    } else {
      await LocationService.startService();
      setState(() {
        _serviceStatus = true;
        status = "Aktif";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = Provider.of<LocationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Lokasi Terkini"), backgroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Status:"),
            Text("$status",
              style: TextStyle(fontSize: 16, color: (_serviceStatus ? Colors.green : Colors.red))
            ),
            const SizedBox(height: 10),
            Text("Interval:"),
            Text("$_interval detik",
              style: TextStyle(fontSize: 16)
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _toggleService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _serviceStatus ? Colors.red : Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5), // ⬅️ lebih kotak
                      ),
                    ),
                    child: Text(_serviceStatus ? "Matikan" : "Aktifkan", 
                      style: TextStyle(color: Colors.white)
                    ),
                  ),
                ),
              ]
            ),
          ],
        ),
      ),
    );
  }
}
