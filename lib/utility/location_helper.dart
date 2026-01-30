import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class LocationHelper {
  /// Prediction → LatLng
  static LatLng? latLngFromPrediction(Prediction p) {
    if (p.lat == null || p.lng == null) return null;
    return LatLng(double.parse(p.lat!), double.parse(p.lng!));
  }

  /// Prediction → Address
  static String addressFromPrediction(Prediction p) {
    return p.description ?? "";
  }
}
