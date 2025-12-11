import 'package:flutter/material.dart';

class LocationProvider with ChangeNotifier {
  String? latitude;
  String? longitude;
  String? timestamp;

  void updateLocation(String lat, String lng, String time) {
    latitude = lat;
    longitude = lng;
    timestamp = time;
    notifyListeners();
  }

  void reset() {
    latitude = null;
    longitude = null;
    timestamp = null;
    notifyListeners();
  }
}
