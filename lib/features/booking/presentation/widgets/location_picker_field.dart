import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../core/location/app_map_defaults.dart';
import '../../../../core/utils/google_config.dart';
import '../../../../shared/widgets/location_permission_dialog.dart';

/// Resolved shoot location — address string plus coordinates.
@immutable
class PickedLocation {
  const PickedLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String address;
  final double latitude;
  final double longitude;
}

/// Google Places search field + dark map + "Use Current Location" button.
///
/// Extracted from the legacy `shoot_details_screen.dart` so the Book-a-Shoot
/// v2 When & Where screen can reuse the exact location UX (Places autocomplete,
/// reverse geocoding, current-location permission flow, tap-to-pin map).
///
/// Emits the chosen location via [onChanged]; `null` means the user cleared it.
class LocationPickerField extends StatefulWidget {
  const LocationPickerField({
    super.key,
    required this.onChanged,
    this.initial,
    this.errorText,
  });

  final ValueChanged<PickedLocation?> onChanged;
  final PickedLocation? initial;
  final String? errorText;

  @override
  State<LocationPickerField> createState() => _LocationPickerFieldState();
}

class _LocationPickerFieldState extends State<LocationPickerField> {
  static const String _darkMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}]},
  {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#757575"}]},
  {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#383838"}]},
  {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#8a8a8a"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}]}
]
''';

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  GoogleMapController? _mapController;
  LatLng? _latLng;
  String _address = '';
  bool _hasLocationPermission = false;
  bool _showMap = false;
  bool _isMapLoading = true;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _address = initial.address;
      _searchController.text = initial.address;
      _latLng = LatLng(initial.latitude, initial.longitude);
      _showMap = true;
    }
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !_showMap) {
        setState(() => _showMap = true);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.initial == null) _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  bool _isPlusCode(String value) =>
      RegExp(r'^[A-Z0-9]{4,}\+[A-Z0-9]{2,}$').hasMatch(value);

  void _emit() {
    final latLng = _latLng;
    if (latLng == null || _address.isEmpty) {
      widget.onChanged(null);
      return;
    }
    widget.onChanged(
      PickedLocation(
        address: _address,
        latitude: latLng.latitude,
        longitude: latLng.longitude,
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await ensureLocationPermission(context);
    if (!mounted || !hasPermission) {
      if (mounted && _hasLocationPermission) {
        setState(() => _hasLocationPermission = false);
      }
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    if (!mounted) return;

    final latLng = LatLng(position.latitude, position.longitude);
    setState(() {
      _hasLocationPermission = true;
      _showMap = true;
    });
    await _updateFromLatLng(latLng);
  }

  Future<void> _updateFromLatLng(LatLng latLng) async {
    setState(() => _latLng = latLng);
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));

    try {
      final placemarks =
          await Geocoding().placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[
          if (p.name != null && !_isPlusCode(p.name!)) p.name!,
          if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality!,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty)
            p.administrativeArea!,
        ];
        _address = parts.join(', ');
        _searchController.text = _address;
        _searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: _searchController.text.length),
        );
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    }
    if (mounted) setState(() {});
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _locationField(),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              widget.errorText!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        if (_showMap) ...[
          const SizedBox(height: AppSpacing.md),
          _map(),
        ],
      ],
    );
  }

  Widget _locationField() {
    return AnimatedBuilder(
      animation: Listenable.merge([_focusNode, _searchController]),
      builder: (context, _) {
        final highlight =
            _focusNode.hasFocus || _searchController.text.isNotEmpty;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconTheme(
              data: const IconThemeData(color: AppColors.white70, size: 20),
              child: GooglePlaceAutoCompleteTextField(
                boxDecoration: BoxDecoration(
                  color: AppColors.transparent,
                  borderRadius: AppRadii.lgAll,
                  border: Border.all(
                    color: highlight ? AppColors.borderGold : AppColors.white30,
                    width: 0.5,
                  ),
                ),
                textEditingController: _searchController,
                focusNode: _focusNode,
                googleAPIKey: GoogleConfig.placesApiKey,
                debounceTime: 600,
                isLatLngRequired: true,
                textStyle: const TextStyle(
                  color: AppColors.white,
                  fontFamily: AppTextStyles.fontFamilyBody,
                  fontSize: 15,
                ),
                inputDecoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.only(
                    left: AppSpacing.inputHorizontal,
                    right: AppSpacing.xs,
                    top: AppSpacing.inputVertical,
                    bottom: AppSpacing.inputVertical,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _address = '';
                              _latLng = null;
                            });
                            _emit();
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: AppSpacing.md),
                            child: Icon(Icons.close,
                                size: 18, color: AppColors.white70),
                          ),
                        )
                      : null,
                  suffixIconConstraints:
                      const BoxConstraints(minWidth: 32, minHeight: 24),
                ),
                getPlaceDetailWithLatLng: (prediction) async {
                  final latLng = LatLng(
                    double.parse(prediction.lat!),
                    double.parse(prediction.lng!),
                  );
                  _focusNode.unfocus();
                  setState(() {
                    _latLng = latLng;
                    _address = prediction.description ?? '';
                    _showMap = true;
                  });
                  _searchController.text = _address;
                  _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _searchController.text.length),
                  );
                  _mapController
                      ?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));
                  _emit();
                },
                itemClick: (prediction) {
                  _searchController.text = prediction.description ?? '';
                  _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _searchController.text.length),
                  );
                },
                isCrossBtnShown: false,
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              top: -8,
              child: Container(
                color: AppColors.background,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                child: Text(
                  'Select Location*',
                  style: TextStyle(
                    fontSize: 12,
                    color: highlight ? AppColors.primary : AppColors.white60,
                    fontFamily: AppTextStyles.fontFamilyBody,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _map() {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadii.xlAll,
      ),
      child: ClipRRect(
        borderRadius: AppRadii.xlAll,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _latLng ?? AppMapDefaults.fallbackCenter,
                zoom: _latLng == null ? AppMapDefaults.fallbackZoom : 14,
              ),
              style: _darkMapStyle,
              myLocationEnabled: _hasLocationPermission,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
              onMapCreated: (controller) {
                _mapController = controller;
                if (mounted) setState(() => _isMapLoading = false);
              },
              markers: _latLng == null
                  ? const <Marker>{}
                  : {
                      Marker(
                        markerId: const MarkerId('selected'),
                        position: _latLng!,
                      ),
                    },
              onTap: _updateFromLatLng,
            ),
            if (_isMapLoading)
              IgnorePointer(
                child: Container(
                  color: AppColors.surfaceVariant,
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: AppSpacing.base,
              left: 0,
              right: 0,
              child: Center(child: _useCurrentLocationButton()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _useCurrentLocationButton() {
    return Material(
      color: AppColors.white,
      borderRadius: AppRadii.roundAll,
      child: InkWell(
        borderRadius: AppRadii.roundAll,
        onTap: _getCurrentLocation,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.near_me_outlined,
                  size: 16, color: AppColors.black),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Use Current Location',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
