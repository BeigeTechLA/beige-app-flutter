import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationHelper {
  static Future<String> getAddress(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        final parts = <String>[
          if (p.name != null && p.name!.isNotEmpty) p.name!,
          if (p.subLocality != null && p.subLocality!.isNotEmpty)
            p.subLocality!,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
          if (p.administrativeArea != null &&
              p.administrativeArea!.isNotEmpty)
            p.administrativeArea!,
        ];

        return parts.join(', ');
      }
    } catch (e) {
      // ignore error, fallback below
    }

    return "Selected Location";
  }
}
