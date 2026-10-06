import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/core/location/app_map_defaults.dart';
import 'package:beige/core/utils/google_config.dart';
import 'package:beige/shared/widgets/location_permission_dialog.dart';

/// Resolved location selection passed up to the parent.
class BookingLocation {
  const BookingLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String address;
  final double latitude;
  final double longitude;
}

/// Reusable venue picker for the v4 schedule screen: a Google Places
/// autocomplete field, a dark map preview, and a "Use Current Location"
/// action. Reports selections via [onChanged]. Mirrors the legacy
/// shoot-details location UX without pulling in its 1300-line screen.
class BookingLocationField extends StatefulWidget {
  const BookingLocationField({
    super.key,
    required this.onChanged,
    this.initial,
    this.label = 'Select Location*',
  });

  final ValueChanged<BookingLocation> onChanged;
  final BookingLocation? initial;
  final String label;

  @override
  State<BookingLocationField> createState() => _BookingLocationFieldState();
}

class _BookingLocationFieldState extends State<BookingLocationField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  GoogleMapController? _mapController;
  LatLng? _latLng;
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _controller.text = initial.address;
      _latLng = LatLng(initial.latitude, initial.longitude);
      _showMap = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  bool _isPlusCode(String s) => GoogleConfig.plusCodeRegex.hasMatch(s);

  void _emit(String address) {
    final latLng = _latLng;
    if (latLng == null || address.isEmpty) return;
    widget.onChanged(
      BookingLocation(
        address: address,
        latitude: latLng.latitude,
        longitude: latLng.longitude,
      ),
    );
  }

  Future<void> _applyLatLng(LatLng latLng, {String? knownAddress}) async {
    setState(() {
      _latLng = latLng;
      _showMap = true;
    });
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));

    var address = knownAddress ?? '';
    if (address.isEmpty) {
      try {
        final placemarks = await placemarkFromCoordinates(
          latLng.latitude,
          latLng.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          address = <String>[
            if (p.name != null && !_isPlusCode(p.name!)) p.name!,
            if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality!,
            if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
            if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty)
              p.administrativeArea!,
          ].join(', ');
        }
      } catch (_) {
        // Reverse geocode is best-effort; keep any typed address.
        address = _controller.text;
      }
    }

    if (!mounted) return;
    _controller
      ..text = address
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: address.length),
      );
    _emit(address);
  }

  Future<void> _useCurrentLocation() async {
    final granted = await ensureLocationPermission(context);
    if (!mounted || !granted) return;
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (!mounted) return;
    await _applyLatLng(LatLng(position.latitude, position.longitude));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField(),
        AppSpacing.verticalMd,
        if (_showMap && _latLng != null) _buildMap(),
      ],
    );
  }

  Widget _buildField() {
    return AnimatedBuilder(
      animation: Listenable.merge([_focusNode, _controller]),
      builder: (context, _) {
        final highlight = _focusNode.hasFocus || _controller.text.isNotEmpty;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconTheme(
              data: const IconThemeData(color: AppColors.white70, size: 20),
              child: GooglePlaceAutoCompleteTextField(
                textEditingController: _controller,
                focusNode: _focusNode,
                googleAPIKey: GoogleConfig.placesApiKey,
                debounceTime: 600,
                isLatLngRequired: true,
                boxDecoration: BoxDecoration(
                  color: AppColors.transparent,
                  borderRadius: AppRadii.lgAll,
                  border: Border.all(
                    color: highlight ? AppColors.borderGold : AppColors.white30,
                    width: 0.5,
                  ),
                ),
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
                  suffixIcon: _controller.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _controller.clear();
                            setState(() {
                              _latLng = null;
                              _showMap = false;
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: AppSpacing.md),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: AppColors.white70,
                            ),
                          ),
                        )
                      : null,
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 24,
                  ),
                ),
                getPlaceDetailWithLatLng: (prediction) async {
                  if (prediction.lat == null || prediction.lng == null) return;
                  _focusNode.unfocus();
                  await _applyLatLng(
                    LatLng(
                      double.parse(prediction.lat!),
                      double.parse(prediction.lng!),
                    ),
                    knownAddress: prediction.description ?? '',
                  );
                },
                itemClick: (prediction) {
                  final text = prediction.description ?? '';
                  _controller
                    ..text = text
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: text.length),
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
                  widget.label,
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

  Widget _buildMap() {
    return ClipRRect(
      borderRadius: AppRadii.lgAll,
      child: SizedBox(
        height: 260,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _latLng ?? AppMapDefaults.fallbackCenter,
                zoom: GoogleConfig.defaultZoom,
              ),
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: {
                if (_latLng != null)
                  Marker(markerId: const MarkerId('venue'), position: _latLng!),
              },
              onMapCreated: (c) {
                _mapController = c;
                c.setMapStyle(GoogleConfig.darkMapStyle);
              },
              onTap: (latLng) => _applyLatLng(latLng),
            ),
            Positioned(
              bottom: AppSpacing.base,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _useCurrentLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadii.lgAll,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.map_outlined,
                          size: 18,
                          color: AppColors.black,
                        ),
                        AppSpacing.gapHSm,
                        Text(
                          'Use Current Location',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
