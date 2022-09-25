import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Data extends ChangeNotifier {
  int postCount = 0;
  Set<Marker> markers_ = {};

  setCounter(int count) {
    postCount = count;
    notifyListeners();
  }

  setMarker(Marker marker) {
    markers_.add(marker);
    notifyListeners();
  }
}
