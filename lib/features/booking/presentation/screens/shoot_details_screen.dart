import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../app/assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/shared/widgets/app_text_field.dart';
import 'package:beige/core/utils/google_config.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/core/location/app_map_defaults.dart';
import 'package:beige/features/booking/presentation/providers/shoot_details_notifier.dart';
import 'package:beige/shared/layouts/app_scaffold.dart';
import 'package:beige/shared/widgets/location_permission_dialog.dart';
import 'package:beige/shared/widgets/app_qty_counter.dart';

class ShootDetailsScreen extends ConsumerStatefulWidget {
  final int ShootTypeId;
  final int bookingId;
  final int contentTypeId;
  const ShootDetailsScreen({
    super.key,
    required this.contentTypeId,
    required this.ShootTypeId,
    required this.bookingId,
  });

  @override
  ConsumerState<ShootDetailsScreen> createState() => _ShootDetailsScreenState();
}

class _ShootDetailsScreenState extends ConsumerState<ShootDetailsScreen> {
  int currentStep = 1;
  bool loding = false;

  String? locationError;

  // Included (fixed)
  int includedPhotoQty = 1;
  int includedVideoQty = 1;

  // Additional
  final FocusNode locationFocusNode = FocusNode();

  bool addPhoto = false;
  bool addVideo = false;
  // 🔒 FIXED (always 1)

  int additionalPhotoQty = 0;
  int additionalVideoQty = 0;

  String? selectedStudio;
  bool showMap = false;

  GoogleMapController? mapController;
  LatLng? currentLatLng;
  bool _hasLocationPermission = false;

  String selectedAddress = "Search or select location";
  TextEditingController searchController = TextEditingController();
  final TextEditingController additionalDetailsController =
      TextEditingController();

  final TextEditingController referenceLinksController =
      TextEditingController();

  bool isSubmitting = false;
  bool _isPopping = false;

  void _handleBack() {
    if (_isPopping) return;
    if (!context.canPop()) return;
    _isPopping = true;
    context.pop();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _isPopping = false;
    });
  }

  bool get isFormValid {
    return currentLatLng != null && searchController.text.isNotEmpty;
  }

  Future<void> _More_Details() async {
    if (isSubmitting) return;

    // 🔴 LOCATION VALIDATION
    if (currentLatLng == null || searchController.text.trim().isEmpty) {
      setState(() {
        locationError = "Please enter location";
      });
      return;
    }

    // ✅ Clear error if valid
    setState(() {
      locationError = null;
      isSubmitting = true;
    });

    final payload = {
      "crew_requirements": _buildCrewRequirements(),

      "event_location": selectedAddress,
      "event_latitude": currentLatLng!.latitude,
      "event_longitude": currentLatLng!.longitude,

      "additional_details": additionalDetailsController.text.trim(),

      "reference_links": referenceLinksController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    };
    print(" UPDATE BOOKING DETAILS API");
    print(" PAYLOAD = $payload");

    await ref
        .read(shootDetailsNotifierProvider(widget.bookingId).notifier)
        .saveDetails(bookingId: widget.bookingId, payload: payload);

    if (!mounted) return;

    final detailsState = ref.read(
      shootDetailsNotifierProvider(widget.bookingId),
    );

    if (detailsState.status == ShootDetailsStatus.success) {
      setState(() {
        isSubmitting = false;
      });
      context.pushNamed(
        RouteNames.crewSizeMatching,
        extra: {
          'bookingId': widget.bookingId,
          'contentTypeId': widget.contentTypeId,
          'ShootTypeId': widget.ShootTypeId,
        },
      );
    } else if (detailsState.status == ShootDetailsStatus.error) {
      setState(() {
        isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(detailsState.errorMessage ?? "Error saving details"),
        ),
      );
    } else {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Map<String, int> _buildCrewRequirements() {
    final Map<String, int> crew = {};

    // ❌ Agar user ne "No" select kiya
    if (!loding) return crew;

    // 🎥 Videography
    if ((widget.contentTypeId == 1 || widget.contentTypeId == 3) &&
        additionalVideoQty > 0) {
      crew["videographer"] = additionalVideoQty;
    }

    // 📸 Photography
    if ((widget.contentTypeId == 2 || widget.contentTypeId == 3) &&
        additionalPhotoQty > 0) {
      crew["photographer"] = additionalPhotoQty;
    }

    return crew;
  }

  bool _isPlusCode(String value) {
    return RegExp(r'^[A-Z0-9]{4,}\+[A-Z0-9]{2,}$').hasMatch(value);
  }

  String getTopSummaryText() {
    List<String> parts = [];

    if (widget.contentTypeId == 1 || widget.contentTypeId == 3) {
      final videoTotal = includedVideoQty + additionalVideoQty;
      if (videoTotal > 0) {
        parts.add("Videography x $videoTotal");
      }
    }

    if (widget.contentTypeId == 2 || widget.contentTypeId == 3) {
      final photoTotal = includedPhotoQty + additionalPhotoQty;
      if (photoTotal > 0) {
        parts.add("Photography x $photoTotal");
      }
    }

    return parts.join("  |  ");
  }

  String getContentTypeTitle(int contentTypeId) {
    switch (contentTypeId) {
      case 1:
        return "Videography";
      case 2:
        return "Photography";
      case 3:
        return "Photography & Videography";
      default:
        return "Shoot Type";
    }
  }

  /*IconData getContentTypeIcon(int contentTypeId) {
    switch (contentTypeId) {
      case 1:
        return Icons.videocam;
      case 2:
        return Icons.camera_alt;
      case 3:
        return Icons.video_camera_back; // or Icons.photo_camera
      default:
        return Icons.work_outline;
    }
  }*/

  /*
  String getContentTypeIcon(int contentTypeId) {
    switch (contentTypeId) {
      case 1:
        return AppAssets.video;   // Videography
      case 2:
        return AppAssets.photo;   // Photography
      case 3:
        return AppAssets.video; // Both
      default:
        return AppAssets.photo;
    }
  }
*/

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _getCurrentLocation();
      }
    });
    locationFocusNode.addListener(() {
      setState(() {
        if (locationFocusNode.hasFocus) {
          showMap = true;
        }
      });
    });
  }

  Future<void> searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        final loc = locations.first;

        final latLng = LatLng(loc.latitude, loc.longitude);

        setState(() {
          currentLatLng = latLng;
        });

        mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));

        await getAddressFromLatLng(latLng);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Location not found")));
    }
  }

  Future<void> getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        setState(() {
          selectedAddress =
              "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";
        });
      }
    } catch (e) {
      debugPrint("Reverse geocode error: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await ensureLocationPermission(context);
    if (!mounted || !hasPermission) {
      if (mounted && _hasLocationPermission) {
        setState(() => _hasLocationPermission = false);
      }
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!mounted) return;

    setState(() {
      _hasLocationPermission = true;
      currentLatLng = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _updateLocationFromLatLng(LatLng latLng) async {
    setState(() {
      currentLatLng = latLng;
    });

    mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 14));

    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        // 🔥 BUILD CLEAN ADDRESS (NO PLUS CODE)
        final parts = <String>[
          if (p.name != null && !_isPlusCode(p.name!)) p.name!,
          if (p.subLocality != null) p.subLocality!,
          if (p.locality != null) p.locality!,
          if (p.administrativeArea != null) p.administrativeArea!,
        ];

        selectedAddress = parts.join(', ');

        searchController.text = selectedAddress;
        searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: searchController.text.length),
        );
      }
    } catch (e) {
      debugPrint("Reverse geocode error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep provider alive during async saveDetails call
    ref.watch(shootDetailsNotifierProvider(widget.bookingId));

    String darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#212121"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#212121"}]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#383838"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#8a8a8a"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#000000"}]
  }
]
''';

    return AppScaffold(
      hasAppBar: true,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: _handleBack,
                child: SvgPicture.asset(AppAssets.back, height: 24),
              ),
            ),
            Text(
              "More Details",
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
            ),
            // 🔹 Step Text (Right)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "2/3",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontFamily: AppAssets.fontOutfit,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          children: [
            Row(
              children: List.generate(3, (index) {
                double fillWidth = 0;

                if (index < currentStep) {
                  // ✅ Completed step (FULL)
                  fillWidth = double.infinity;
                } else if (index == currentStep) {
                  // 🟡 Current step (HALF)
                  fillWidth = 35.44;
                } else {
                  // ⭕ Upcoming step (EMPTY)
                  fillWidth = 0;
                }

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary, // grey background
                      borderRadius: BorderRadius.circular(64),
                    ),
                    child: fillWidth > 0
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 5,
                              width: fillWidth == double.infinity
                                  ? null
                                  : fillWidth,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(64),
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                );
              }),
            ),

            SizedBox(height: 20),

            Row(
              children: [
                Text(
                  "More Details",
                  style: TextStyle(
                    fontFamily: AppAssets.fontUnbounded,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    /// 🔹 INCLUDED CARD
                    const SizedBox(height: 12),

                    /// 🎥 VIDEOGRAPHY CARD
                    if (widget.contentTypeId == 1 || widget.contentTypeId == 3)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppRadii.xlAll,
                        ),
                        child: Row(
                          children: [
                            /// ICON BOX
                            SizedBox(
                              height: 40,
                              width: 40,
                              /* decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),*/
                              child: Center(
                                child: SvgPicture.asset(AppAssets.video),
                              ),
                            ),

                            const SizedBox(width: 12),

                            /// TITLE
                            Expanded(
                              child: Text(
                                "Videographer X${includedVideoQty + additionalVideoQty}",
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            /// INCLUDED BADGE
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: AppRadii.hugeAll,
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: const Text(
                                "Included",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    /// 📷 PHOTOGRAPHY CARD
                    if (widget.contentTypeId == 2 || widget.contentTypeId == 3)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppRadii.xlAll,
                        ),
                        child: Row(
                          children: [
                            /// ICON BOX
                            SizedBox(
                              height: 40,
                              width: 40,
                              /*   decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),*/
                              child: Center(
                                child: SvgPicture.asset(
                                  AppAssets.photo,
                                  // height: 20,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            /// TITLE
                            Expanded(
                              child: Text(
                                "Photographer X${includedPhotoQty + additionalPhotoQty}",
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            /// INCLUDED BADGE
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: AppRadii.hugeAll,
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: const Text(
                                "Included",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    /// 🔹 QUESTION
                    Text(
                      "Would you like to Add Additional creatives?",
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _radioOption("Yes", true),
                        const SizedBox(width: 24),
                        _radioOption("No", false),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// 🔹 ADDITIONAL SHOOTER CARD
                    if (loding)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppRadii.xlAll,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            /// 📸 Photography (only if allowed)
                            if (widget.contentTypeId == 2 ||
                                widget.contentTypeId == 3)
                              _buildQtyRow(
                                title: "Photographer",
                                value: additionalPhotoQty,
                                onAdd: () =>
                                    setState(() => additionalPhotoQty++),
                                onRemove: () {
                                  if (additionalPhotoQty > 0) {
                                    setState(() => additionalPhotoQty--);
                                  }
                                },
                              ),

                            /// 🎥 Videography (only if allowed)
                            if (widget.contentTypeId == 1 ||
                                widget.contentTypeId == 3)
                              _buildQtyRow(
                                title: "Videographer",
                                value: additionalVideoQty,
                                onAdd: () =>
                                    setState(() => additionalVideoQty++),
                                onRemove: () {
                                  if (additionalVideoQty > 0) {
                                    setState(() => additionalVideoQty--);
                                  }
                                },
                              ),
                          ],
                        ),
                      ),

                    SizedBox(height: 20),

                    /* TextField(
                  controller: searchController,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      searchLocation(value);
                    }
                  },
                  decoration: InputDecoration(
                    labelText:"Select Location*",
                    suffixIcon:
                     Icon(Icons.location_on_outlined, color: AppColors.white),


                    floatingLabelBehavior: FloatingLabelBehavior.always,

                    labelStyle: const TextStyle(
                      color: AppColors.white70, // #1D1D1B 60% opacity
                    ),

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),

                    /// ⭐ 0.5px BORDER + OPACITY COLOR
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadii.lgAll,
                      borderSide: const BorderSide(
                        color: AppColors.white70, // #1D1D1B99 (60% opacity)
                        width: 0.5,                       // 🔥 exact 0.5px
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadii.lgAll,
                      borderSide: const BorderSide(
                        color: AppColors.white70, // #1D1D1B99 (60% opacity)
                        width: 0.5,                          // focus border thicker
                      ),
                    ),

                    floatingLabelStyle: const TextStyle(
                      color: AppColors.white70,

                    ),
                  ),
                ),*/
                    // GooglePlaceAutoCompleteTextField(
                    //   textEditingController: searchController,
                    //   googleAPIKey: GoogleConfig.placesApiKey,
                    //   debounceTime: 600,
                    //   isLatLngRequired: true,
                    //
                    //   textStyle: const TextStyle(
                    //     color: AppColors.white,
                    //     fontFamily: AppAssets.fontOutfit,
                    //   ),
                    //
                    //   inputDecoration: InputDecoration(
                    //     // labelText: "Select Location*",
                    //     floatingLabelBehavior: FloatingLabelBehavior.always,
                    //
                    //     labelStyle: const TextStyle(
                    //       color: AppColors.white70,
                    //       fontFamily: AppAssets.fontOutfit,
                    //     ),
                    //
                    //     hintText: "Search or select location",
                    //     hintStyle: const TextStyle(
                    //       color: AppColors.white70,
                    //     ),
                    //
                    //     suffixIcon: const Icon(
                    //       Icons.location_on_outlined,
                    //       color: AppColors.white70,
                    //     ),
                    //
                    //     contentPadding: const EdgeInsets.symmetric(
                    //       horizontal: 20,
                    //       vertical: 18,
                    //     ),
                    //
                    //     enabledBorder: OutlineInputBorder(
                    //       borderRadius: AppRadii.lgAll,
                    //       borderSide: const BorderSide(
                    //         color: AppColors.white70,
                    //         width: 0.5,
                    //       ),
                    //     ),
                    //
                    //     focusedBorder: OutlineInputBorder(
                    //       borderRadius: AppRadii.lgAll,
                    //       borderSide: const BorderSide(
                    //         color: AppColors.primary,
                    //         width: 1,
                    //       ),
                    //     ),
                    //   ),
                    //
                    //   getPlaceDetailWithLatLng: (prediction) async {
                    //     final latLng = LatLng(
                    //       double.parse(prediction.lat!),
                    //       double.parse(prediction.lng!),
                    //     );
                    //
                    //     setState(() {
                    //       currentLatLng = latLng;
                    //       selectedAddress = prediction.description ?? "";
                    //       searchController.text = selectedAddress;
                    //     });
                    //
                    //     mapController?.animateCamera(
                    //       CameraUpdate.newLatLngZoom(latLng, 14),
                    //     );
                    //   },
                    //
                    //   itemClick: (prediction) {
                    //     searchController.text = prediction.description ?? "";
                    //     searchController.selection = TextSelection.fromPosition(
                    //       TextPosition(offset: searchController.text.length),
                    //     );
                    //   },
                    //
                    //   isCrossBtnShown: true,
                    // ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 🔹 LOCATION FIELD
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            locationFocusNode,
                            searchController,
                          ]),
                          builder: (context, _) {
                            final bool locationHighlight =
                                locationFocusNode.hasFocus ||
                                searchController.text.isNotEmpty;

                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconTheme(
                                  data: const IconThemeData(
                                    color: AppColors.white70,
                                    size: 20,
                                  ),
                                  child: GooglePlaceAutoCompleteTextField(
                                    boxDecoration: BoxDecoration(
                                      color: AppColors.transparent,
                                      borderRadius: AppRadii.lgAll,
                                      border: Border.all(
                                        color: locationHighlight
                                            ? AppColors.borderGold
                                            : AppColors.white30,
                                        width: 0.5,
                                      ),
                                    ),
                                    textEditingController: searchController,
                                    focusNode: locationFocusNode,
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.lg,
                                            vertical: AppSpacing.lg,
                                          ),
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.only(
                                          right: AppSpacing.sm,
                                        ),
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: SvgPicture.asset(
                                            AppAssets.locationPin,
                                            colorFilter: const ColorFilter.mode(
                                              AppColors.white,
                                              BlendMode.srcIn,
                                            ),
                                            fit: BoxFit.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    getPlaceDetailWithLatLng:
                                        (prediction) async {
                                          final latLng = LatLng(
                                            double.parse(prediction.lat!),
                                            double.parse(prediction.lng!),
                                          );

                                          locationFocusNode.unfocus();

                                          await _updateLocationFromLatLng(
                                            latLng,
                                          );

                                          setState(() {
                                            currentLatLng = latLng;
                                            selectedAddress =
                                                prediction.description ?? "";
                                            locationError =
                                                null; // ✅ REMOVE ERROR HERE
                                          });

                                          searchController.text =
                                              selectedAddress;
                                          searchController.selection =
                                              TextSelection.fromPosition(
                                                TextPosition(
                                                  offset: searchController
                                                      .text
                                                      .length,
                                                ),
                                              );

                                          mapController?.animateCamera(
                                            CameraUpdate.newLatLngZoom(
                                              latLng,
                                              14,
                                            ),
                                          );
                                        },
                                    itemClick: (prediction) {
                                      searchController.text =
                                          prediction.description ?? "";
                                      searchController.selection =
                                          TextSelection.fromPosition(
                                            TextPosition(
                                              offset:
                                                  searchController.text.length,
                                            ),
                                          );
                                    },
                                    isCrossBtnShown: true,
                                  ),
                                ),
                                Positioned(
                                  left: AppSpacing.md,
                                  top: -8,
                                  child: Container(
                                    color: AppColors.background,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xxs,
                                    ),
                                    child: Text(
                                      "Select Location*",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: locationHighlight
                                            ? AppColors.primary
                                            : AppColors.white60,
                                        fontFamily:
                                            AppTextStyles.fontFamilyBody,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        /// 🔴 ERROR TEXT
                        if (locationError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              locationError!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 10),

                    /// 🗺️ MAP WITH FIXED HEIGHT
                    if (showMap)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SizedBox(
                          height: 350,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target:
                                    currentLatLng ??
                                    AppMapDefaults.fallbackCenter,
                                zoom: currentLatLng == null
                                    ? AppMapDefaults.fallbackZoom
                                    : 14,
                              ),

                              myLocationEnabled: _hasLocationPermission,
                              myLocationButtonEnabled: _hasLocationPermission,
                              zoomControlsEnabled: true,
                              compassEnabled: false,

                              // 🔥 IMPORTANT FIX (touch enable)
                              gestureRecognizers:
                                  <Factory<OneSequenceGestureRecognizer>>{
                                    Factory<OneSequenceGestureRecognizer>(
                                      () => EagerGestureRecognizer(),
                                    ),
                                  },

                              onMapCreated: (controller) {
                                mapController = controller;
                                controller.setMapStyle(darkMapStyle);
                              },

                              markers: currentLatLng == null
                                  ? const <Marker>{}
                                  : {
                                      Marker(
                                        markerId: const MarkerId("selected"),
                                        position: currentLatLng!,
                                      ),
                                    },

                              onTap: (latLng) async {
                                await _updateLocationFromLatLng(latLng);
                              },
                            ),
                          ),
                        ),
                      ),

                    SizedBox(height: 20),
                    /*        TextField(
                  controller: additionalDetailsController,
                  maxLines: 5,

                  decoration: InputDecoration(
                    labelText:"Additional Details",

                    floatingLabelBehavior: FloatingLabelBehavior.always,

                    labelStyle: const TextStyle(
                      color: AppColors.white70, // #1D1D1B 60% opacity
                    ),

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),

                    /// ⭐ 0.5px BORDER + OPACITY COLOR
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadii.lgAll,
                      borderSide: const BorderSide(
                        color: AppColors.white70, // #1D1D1B99 (60% opacity)
                        width: 0.5,                       // 🔥 exact 0.5px
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadii.lgAll,
                      borderSide: const BorderSide(
                        color: AppColors.white70, // #1D1D1B99 (60% opacity)
                        width: 0.5,                          // focus border thicker
                      ),
                    ),

                    floatingLabelStyle: const TextStyle(
                      color: AppColors.white70,

                    ),
                  ),
                ),
                SizedBox(height: 20),*/
                    AppTextField(
                      label: "Additional Details",
                      controller: additionalDetailsController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                    ),
                    /*TextField(

                  controller: referenceLinksController,
                  decoration: InputDecoration(
                    labelText:"Supporting Links",

                    floatingLabelBehavior: FloatingLabelBehavior.always,

                    labelStyle: const TextStyle(
                      color: AppColors.white70, // #1D1D1B 60% opacity
                    ),

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),

                    /// ⭐ 0.5px BORDER + OPACITY COLOR
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadii.lgAll,
                      borderSide: const BorderSide(
                        color: AppColors.white70, // #1D1D1B99 (60% opacity)
                        width: 0.5,                       // 🔥 exact 0.5px
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadii.lgAll,
                      borderSide: const BorderSide(
                        color: AppColors.white70, // #1D1D1B99 (60% opacity)
                        width: 0.5,                          // focus border thicker
                      ),
                    ),

                    floatingLabelStyle: const TextStyle(
                      color: AppColors.white70,

                    ),
                  ),
                ),*/
                    SizedBox(height: 20),
                    AppTextField(
                      label: "Supporting Links",
                      controller: referenceLinksController,
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: AppSpacing.cardInsets,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _handleBack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    side: const BorderSide(color: AppColors.neutralGrey),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
                  ),
                  child: Text(
                    "Back",
                    style: AppTextStyles.labelLarge.copyWith(
                      fontFamily: AppAssets.fontUnbounded,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _More_Details,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    /* backgroundColor: selectedIndex == -1
                        ? AppColors.goldGradientLight // disabled
                        : AppColors.primary, // enabled
                    foregroundColor: selectedIndex == -1
                        ? AppColors.neutralGrey.shade400
                        : AppColors.black,*/
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
                  ),
                  child: Text(
                    "Continue",
                    style: AppTextStyles.labelLarge.copyWith(
                      fontFamily: AppAssets.fontUnbounded,
                      color: AppColors.textHeading,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _radioOption(String title, bool value) {
    final bool isSelected = loding == value;

    return InkWell(
      onTap: () {
        setState(() {
          loding = value;

          // 🔥 If user selects NO → reset quantities
          if (!loding) {
            additionalPhotoQty = 0;
            additionalVideoQty = 0;
          }
        });
      },
      borderRadius: AppRadii.roundAll,
      child: Row(
        children: [
          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    )
                  : null,
              border: Border.all(color: AppColors.white70, width: 1),
            ),
            child: isSelected
                ? const Center(
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: AppColors.black,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(color: AppColors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyRow({
    required String title,
    required int value,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: AppColors.white, fontSize: 14),
            ),
          ),
          AppQtyCounter(
            value: value,
            onIncrement: onAdd,
            onDecrement: onRemove,
          ),
        ],
      ),
    );
  }
}
