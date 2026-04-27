import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

import 'package:beige/app/route_names.dart';
import 'package:beige/shared/widgets/custom_input_field.dart';
import 'package:beige/core/utils/google_config.dart';
import 'package:beige/app/colors.dart';
import 'package:beige/features/booking/presentation/providers/shoot_details_notifier.dart';

class ShootDetailsScreen extends ConsumerStatefulWidget {
  final int specialtyId;
  final int ShootTypeId;
  final int bookingId;
  final int contentTypeId;
  const ShootDetailsScreen({super.key, required this.contentTypeId, required this.specialtyId, required this.ShootTypeId, required this.bookingId});

  @override
  ConsumerState<ShootDetailsScreen> createState() => _ShootDetailsScreenState();
}

class _ShootDetailsScreenState extends ConsumerState<ShootDetailsScreen> {

  int currentStep = 1;
  bool loding   = false;


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

  String selectedAddress = "Search or select location";
  TextEditingController searchController = TextEditingController();
  final TextEditingController additionalDetailsController =
  TextEditingController();

  final TextEditingController referenceLinksController = TextEditingController();


  bool isSubmitting = false;

  bool get isFormValid {
    return currentLatLng != null &&
        searchController.text.isNotEmpty;
  }

  Future<void> _More_Details() async {

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

    await ref
        .read(shootDetailsNotifierProvider(widget.bookingId).notifier)
        .saveDetails(bookingId: widget.bookingId, payload: payload);

    if (!mounted) return;

    final detailsState = ref.read(shootDetailsNotifierProvider(widget.bookingId));

    if (detailsState.status == ShootDetailsStatus.success) {
      context.pushNamed(RouteNames.crewSizeMatching, extra: {
        'bookingId': widget.bookingId,
        'contentTypeId': widget.contentTypeId,
        'specialtyId': widget.specialtyId,
        'ShootTypeId': widget.ShootTypeId,
      });
    } else if (detailsState.status == ShootDetailsStatus.error) {
      setState(() {
        isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(detailsState.errorMessage ?? "Error saving details")),
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
        return "assets/svg/video.svg";   // Videography
      case 2:
        return "assets/svg/Photo.svg";   // Photography
      case 3:
        return "assets/svg/video_photo.svg"; // Both
      default:
        return "assets/svg/default.svg";
    }
  }
*/


  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    locationFocusNode.addListener(() {
      if (locationFocusNode.hasFocus) {
        setState(() {
          showMap = true; // 🔥 TextField click → map show
        });
      }
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

        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 15),
        );

        await getAddressFromLatLng(latLng);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not found")),
      );
    }
  }

  Future<void> getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

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
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location permission permanently denied. Enable from settings."),
        ),
      );
      await Geolocator.openAppSettings(); // 👈 Open app settings
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLatLng = LatLng(position.latitude, position.longitude);
    });
  }


  Future<void> _updateLocationFromLatLng(LatLng latLng) async {
    setState(() {
      currentLatLng = latLng;
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(latLng, 14),
    );

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
    String _darkMapStyle = '''
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


    return Scaffold(

      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => context.pop(),
                child: SvgPicture.asset(
                  "assets/svg/back.svg",
                  height: 24,
                ),
              ),
            ),
            Text(
              "More Details",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontFamily: "Outfit",
                fontWeight: FontWeight.w400,
              ),
            ),
            // 🔹 Step Text (Right)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "2/3",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(child:Padding(padding:  EdgeInsets.all(16.0),
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
                width: fillWidth == double.infinity ? null : fillWidth,
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
      
      
          SizedBox(
            height: 20,
          ),
      
          Row(
            children: [
              Text(
                "More Details",
                style: TextStyle(
                  fontFamily: "Unbounded",
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
                      color: const Color(0xFF2B2B2B),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [

                        /// ICON BOX
                        Container(
                          height: 40,
                          width: 40,
                         /* decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),*/
                          child: Center(
                            child: SvgPicture.asset(
                              "assets/svg/video.svg",
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// TITLE
                        Expanded(
                          child: Text(
                            "Videographer X${includedVideoQty + additionalVideoQty}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        /// INCLUDED BADGE
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
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
                      color: const Color(0xFF2B2B2B),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [

                        /// ICON BOX
                        Container(
                          height: 40,
                          width: 40,
                       /*   decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),*/
                          child: Center(
                            child: SvgPicture.asset(
                              "assets/svg/Photo.svg",
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
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        /// INCLUDED BADGE
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
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
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Unbounded",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B2B2B),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// 📸 Photography (only if allowed)
                        if (widget.contentTypeId == 2 || widget.contentTypeId == 3)
                          _buildQtyRow(
                            title: "Photography",
                            value: additionalPhotoQty,
                            onAdd: () => setState(() => additionalPhotoQty++),
                            onRemove: () {
                              if (additionalPhotoQty > 0) {
                                setState(() => additionalPhotoQty--);
                              }
                            },
                          ),

                        /// 🎥 Videography (only if allowed)
                        if (widget.contentTypeId == 1 || widget.contentTypeId == 3)
                          _buildQtyRow(
                            title: "Videography",
                            value: additionalVideoQty,
                            onAdd: () => setState(() => additionalVideoQty++),
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
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.white70, // #1D1D1B99 (60% opacity)
                        width: 0.5,                       // 🔥 exact 0.5px
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                //     fontFamily: "Outfit",
                //   ),
                //
                //   inputDecoration: InputDecoration(
                //     // labelText: "Select Location*",
                //     floatingLabelBehavior: FloatingLabelBehavior.always,
                //
                //     labelStyle: const TextStyle(
                //       color: AppColors.white70,
                //       fontFamily: "Outfit",
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
                //       borderRadius: BorderRadius.circular(12),
                //       borderSide: const BorderSide(
                //         color: AppColors.white70,
                //         width: 0.5,
                //       ),
                //     ),
                //
                //     focusedBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(12),
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
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderGold,
                            width: 0.5,
                          ),

                        ),
                        child: GooglePlaceAutoCompleteTextField(
                          textEditingController: searchController,
                          focusNode: locationFocusNode,
                          googleAPIKey: GoogleConfig.placesApiKey,
                          debounceTime: 600,
                          isLatLngRequired: true,

                          textStyle: const TextStyle(
                            color: AppColors.white,
                            fontFamily: "Outfit",
                            fontSize: 14,
                          ),

                          inputDecoration:  InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: "Search or select location",
                            hintStyle: TextStyle(
                              color: AppColors.white70,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: SizedBox(
                                width: 16,   // 👈 control size here
                                height: 16,
                                child: SvgPicture.asset(
                                  "assets/svg/LocationPin.svg",
                                  fit: BoxFit.none,
                                ),
                              ),
                            ),),

                          getPlaceDetailWithLatLng: (prediction) async {
                            final latLng = LatLng(
                              double.parse(prediction.lat!),
                              double.parse(prediction.lng!),
                            );

                            locationFocusNode.unfocus();

                            await _updateLocationFromLatLng(latLng);

                            setState(() {
                              currentLatLng = latLng;
                              selectedAddress = prediction.description ?? "";
                              locationError = null; // ✅ REMOVE ERROR HERE
                            });

                            searchController.text = selectedAddress;
                            searchController.selection = TextSelection.fromPosition(
                              TextPosition(offset: searchController.text.length),
                            );

                            mapController?.animateCamera(
                              CameraUpdate.newLatLngZoom(latLng, 14),
                            );
                          },

                          itemClick: (prediction) {
                            searchController.text = prediction.description ?? "";
                            searchController.selection = TextSelection.fromPosition(
                              TextPosition(offset: searchController.text.length),
                            );
                          },

                          isCrossBtnShown: true,
                        ),
                      ),

                    /// 🔴 ERROR TEXT
                    if (locationError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          locationError!,
                          style: const TextStyle(
                            color: Colors.red,
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
                      child: currentLatLng == null
                          ? const Center(child: CircularProgressIndicator())
                          :GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: currentLatLng!,
                          zoom: 14,
                        ),

                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                        compassEnabled: false,

                        // 🔥 IMPORTANT FIX (touch enable)
                        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                          Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                          ),
                        },

                        onMapCreated: (controller) {
                          mapController = controller;
                          controller.setMapStyle(_darkMapStyle);
                        },

                        markers: {
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
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.white70, // #1D1D1B99 (60% opacity)
                        width: 0.5,                       // 🔥 exact 0.5px
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                CustomInputField(
                  title: "Additional Details",
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
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.white70, // #1D1D1B99 (60% opacity)
                        width: 0.5,                       // 🔥 exact 0.5px
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                CustomInputField(
                  title: "Supporting Links",
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
      
      )
      ) ,

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child:  OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:  Text("Back",style: TextStyle(fontFamily: "Unbounded",fontWeight: FontWeight.w500,fontSize: 14),),
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
                      ? Colors.grey.shade400
                      : Colors.black,*/
                  padding:  EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontFamily: "Unbounded",
                    color: AppColors.textHeading,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

          ],
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
      borderRadius: BorderRadius.circular(30),
      child: Row(
        children: [
          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isSelected
                  ? const LinearGradient(
                colors: [
                  Color(0xFFE8D1AB),
                  Color(0xFFD4A14D),
                ],
              )
                  : null,
              border: Border.all(
                color: AppColors.white70,
                width: 1,
              ),
            ),
            child: isSelected
                ? const Center(
              child: CircleAvatar(
                radius: 4,
                backgroundColor: Colors.black,
              ),
            )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: onRemove,
                  child: const Icon(Icons.remove, size: 18, color: Colors.black),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    value.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onAdd,
                  child: const Icon(Icons.add, size: 18, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
