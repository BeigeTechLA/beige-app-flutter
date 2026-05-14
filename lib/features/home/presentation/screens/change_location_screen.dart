import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../app/assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/core/utils/google_config.dart';
import 'package:beige/features/profile/presentation/providers/profile_providers.dart';

class ChangeLocationScreen extends ConsumerStatefulWidget {
  const ChangeLocationScreen({super.key});

  @override
  ConsumerState<ChangeLocationScreen> createState() =>
      _ChangeLocationScreenState();
}

class _ChangeLocationScreenState extends ConsumerState<ChangeLocationScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  GoogleMapController? mapController;

  LatLng? selectedLatLng;
  String selectedAddress = "select location";
  bool isManualSelection = false;

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    if (selectedLatLng == null) {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  // ================= CURRENT LOCATION =================
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        selectedLatLng = latLng;
      });

      await _getAddressFromLatLng(latLng);
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  // ================= ADDRESS FROM LAT LNG =================
  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        // 🔥 use Set to remove duplicates
        final addressParts = <String>{
          if (p.street != null && p.street!.isNotEmpty) p.street!,
          if (p.subLocality != null && p.subLocality!.isNotEmpty)
            p.subLocality!,
          if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
          if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty)
            p.administrativeArea!,
          if (p.postalCode != null && p.postalCode!.isNotEmpty) p.postalCode!,
          if (p.country != null && p.country!.isNotEmpty) p.country!,
        };

        String fullAddress = addressParts.join(', ');

        setState(() {
          selectedAddress = fullAddress;
          searchController.text = fullAddress;
        });
      }
    } catch (e) {
      debugPrint("Address error: $e");
    }
  }

  Future<void> _changeLocationApi() async {
    if (selectedLatLng == null) return;

    final payload = {
      "location": selectedAddress,
      "lat": selectedLatLng!.latitude,
      "lng": selectedLatLng!.longitude,
    };

    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.updateProfile(data: payload);

    if (!mounted) return;

    result.fold(
      (error) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message))),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location updated successfully")),
        );
        context.pop(payload);
      },
    );
  }

  // ================= DARK MAP STYLE =================
  static const String _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1d1d1d"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1d1d1d"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2c2c2c"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}
]
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ================= SEARCH (PLACES AUTOCOMPLETE) =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 70, // 👈 status bar spacing
              bottom: 20,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              border: Border.all(color: AppColors.transparent),

              /// ❌ REMOVE SHADOW
              boxShadow: const [],
              borderRadius: AppRadii.bottomPillSm,
            ),

            child: AnimatedBuilder(
              animation: Listenable.merge([searchFocusNode, searchController]),
              builder: (context, _) {
                final bool searchHighlight =
                    searchFocusNode.hasFocus ||
                    searchController.text.isNotEmpty;

                return IconTheme(
                  data: const IconThemeData(color: AppColors.white70, size: 20),
                  child: GooglePlaceAutoCompleteTextField(
                    textEditingController: searchController,
                    focusNode: searchFocusNode,
                    googleAPIKey: GoogleConfig.placesApiKey,
                    debounceTime: 800,
                    isLatLngRequired: true,
                    boxDecoration: BoxDecoration(
                      color: AppColors.transparent,
                      borderRadius: AppRadii.lgAll,
                      border: Border.all(
                        color: searchHighlight
                            ? AppColors.borderGold
                            : AppColors.white30,
                        width: 0.5,
                      ),
                    ),
                    textStyle: const TextStyle(
                      color: AppColors.white,
                      fontFamily: AppTextStyles.fontFamilyBody,
                      fontSize: 15,
                    ),
                    inputDecoration: InputDecoration(
                      hintText: "Search location",
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white70,
                      ),
                      filled: true,
                      fillColor: AppColors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: SvgPicture.asset(
                          AppAssets.search,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                          height: 20,
                          width: 20,
                        ),
                      ),
                      suffixIcon: searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                searchController.clear();
                                searchFocusNode.unfocus();
                                setState(() {});
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(AppSpacing.md),
                                child: Icon(
                                  Icons.close,
                                  color: AppColors.white70,
                                  size: 20,
                                ),
                              ),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.lg,
                      ),
                    ),
                    isCrossBtnShown: false,
                    getPlaceDetailWithLatLng: (prediction) async {
                      if (prediction.lat != null && prediction.lng != null) {
                        final latLng = LatLng(
                          double.parse(prediction.lat!),
                          double.parse(prediction.lng!),
                        );

                        /// 🔥 FIRST: close keyboard
                        searchFocusNode.unfocus();

                        /// 🔥 SECOND: delay (important)
                        await Future.delayed(const Duration(milliseconds: 200));

                        setState(() {
                          selectedLatLng = latLng;
                          selectedAddress = prediction.description ?? "";
                          searchController.text = selectedAddress;
                        });

                        /// 🔥 move map
                        mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(latLng, 16),
                        );
                      }
                    },

                    itemClick: (prediction) async {
                      searchController.text = prediction.description ?? "";

                      /// 🔥 important (cursor fix)
                      searchController.selection = TextSelection.fromPosition(
                        TextPosition(offset: searchController.text.length),
                      );

                      searchFocusNode.unfocus();
                    },
                  ),
                );
              },
            ),
          ),

          // ================= MAP =================
          Expanded(
            child: Stack(
              children: [
                /// ================= MAP =================
                selectedLatLng == null
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                        ),
                      )
                    : GoogleMap(
                        style: _darkMapStyle,
                        initialCameraPosition: CameraPosition(
                          target: selectedLatLng!,
                          zoom: 15,
                        ),
                        onMapCreated: (controller) {
                          mapController = controller;
                          _mapController.complete(controller);
                        },
                        zoomControlsEnabled: false, // ❗ ANDROID zoom +/- remove
                        // Android zoom buttons
                        mapToolbarEnabled: false, // 🔥 IMPORTANT (iOS fix)
                        myLocationButtonEnabled: false,
                        compassEnabled: false,
                        indoorViewEnabled: false,

                        /// gestures (keep ON)
                        zoomGesturesEnabled: true,
                        scrollGesturesEnabled: true,
                        tiltGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                        onTap: (latLng) async {
                          setState(() => selectedLatLng = latLng);
                          await _getAddressFromLatLng(latLng);
                        },
                        markers: {
                          Marker(
                            markerId: const MarkerId("selected"),
                            position: selectedLatLng!,
                          ),
                        },

                        // scrollGesturesEnabled: true,
                      ),

                /// ================= ZOOM BUTTONS =================
                Positioned(
                  right: AppSpacing.base,
                  bottom: AppSpacing.xl,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final controller = await _mapController.future;
                          controller.animateCamera(CameraUpdate.zoomIn());
                        },
                        child: Container(
                          height: 55,
                          width: 55,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.mld),
                            child: SvgPicture.asset(
                              AppAssets.zoomIn,
                              colorFilter: const ColorFilter.mode(
                                AppColors.black,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.verticalBase,
                      GestureDetector(
                        onTap: () async {
                          final controller = await _mapController.future;
                          controller.animateCamera(CameraUpdate.zoomOut());
                        },
                        child: Container(
                          height: 55,
                          width: 55,
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.mld),
                            child: SvgPicture.asset(
                              AppAssets.zoomOut,
                              colorFilter: const ColorFilter.mode(
                                AppColors.black,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: Stack(
          children: [
            /// 🔥 BACKGROUND BLUR (MAIN)
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 40, // 👈 side blur
                sigmaY: 60, // 👈 MORE vertical blur (bottom heavy 🔥)
              ),
            ),

            /// 🔥 TOP FADE (important for smooth merge)
            Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.transparent,
                    AppColors.black.withValues(alpha: 0.4),
                    AppColors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            /// 🔥 CONTENT (TEXT + BUTTON)
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// LOCATION TEXT
                  Padding(
                    padding: AppSpacing.insetsHXl,
                    child: Text(
                      selectedAddress,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  AppSpacing.verticalXl,

                  /// SAVE BUTTON
                  Padding(
                    padding: AppSpacing.insetsHXl,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 52),
                        elevation: 10,
                        shadowColor: AppColors.black.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.xxxlAll,
                        ),
                      ),
                      onPressed: () async {
                        if (selectedLatLng == null) return;
                        await _changeLocationApi();
                      },
                      child: Text(
                        "Save",
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.black,
                          fontFamily: AppAssets.fontUnbounded,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
