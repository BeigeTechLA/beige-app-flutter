import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../app/assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/core/location/app_map_defaults.dart';
import 'package:beige/shared/widgets/app_text_field.dart';
import 'package:beige/features/auth/presentation/providers/signup_notifier.dart';
import 'package:beige/features/auth/presentation/providers/signup_state.dart';
import 'package:beige/core/utils/google_config.dart';
import 'package:beige/shared/widgets/app_image_cropper_sheet.dart';
import 'package:beige/shared/widgets/location_permission_dialog.dart';
import 'package:beige/shared/widgets/top_message.dart';
import 'package:beige/shared/widgets/loading.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  bool isLocationSelected = false;
  bool isProgrammaticChange = false;
  File? profileImage;
  final ImagePicker _picker = ImagePicker();
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool savePassword = false;

  double? selectedLat;
  double? selectedLng;
  GoogleMapController? mapController;
  LatLng? currentLatLng;
  bool _hasLocationPermission = false;
  final FocusNode locationFocusNode = FocusNode();
  bool showMap = false;
  String selectedAddress = "Search or select location";
  bool isMapOpen = false; // 👈 map show / hide
  List<Location> searchResults = [];
  FocusNode locationFocus = FocusNode();
  bool _isPlusCode(String value) {
    return RegExp(r'^[A-Z0-9]{4,}\+[A-Z0-9]{2,}$').hasMatch(value);
  }

  bool get isFormValid {
    return nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        locationController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        savePassword; // ✅ checkbox must be checked
  }

  bool isLoading = false;

  bool isCropping = false;
  File? tempImage;
  double cropScale = 1.0;

  double scale = 1.0;
  double startScale = 1.0;

  Offset offset = Offset.zero;
  Offset startOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    locationController.addListener(() {
      if (isProgrammaticChange) return; // 👈 skip

      if (isLocationSelected) {
        setState(() {
          isLocationSelected = false;
        });
      }
    }); //

    nameController.addListener(() => setState(() {}));
    emailController.addListener(() => setState(() {}));
    // locationController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
    confirmPasswordController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _getCurrentLocation();
      }
    });
    /*   _getCurrentLocation();
    nameController.addListener(() {
      setState(() {});
    });

    emailController.addListener(() {
      setState(() {});
    });*/
    locationFocus.addListener(() {
      if (locationFocus.hasFocus) {
        setState(() {
          showMap = true; //
        });
      }
    });
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (picked == null || !mounted) return;

    final cropped = await AppImageCropperSheet.show(
      context,
      imageFile: File(picked.path),
    );

    if (cropped != null && mounted) {
      setState(() {
        profileImage = cropped;
      });
    }
  }

  Future<void> searchLocation(String query) async {
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);

      setState(() {
        searchResults = locations; // 👈 dropdown data
      });
    } catch (e) {
      debugPrint("Search error: $e");
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

        final address =
            "${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}";

        setState(() {
          selectedAddress = address;

          /// 🔥 IMPORTANT: TextField ko bhi update karo
          locationController.text = address;
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
      selectedLat = latLng.latitude;
      selectedLng = latLng.longitude;
      isLocationSelected = true;
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

        locationController.text = selectedAddress;
        isProgrammaticChange = true;
        locationController.text = selectedAddress;
        isProgrammaticChange = false;
        locationController.selection = TextSelection.fromPosition(
          TextPosition(offset: locationController.text.length),
        );
      }
    } catch (e) {
      debugPrint("Reverse geocode error: $e");
    }
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> _fetchSignup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final location = locationController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    /// 🔴 NAME
    if (name.isEmpty) {
      TopMessage.show(context, "Please enter your name");
      return;
    }

    /// 🔴 EMAIL
    if (email.isEmpty) {
      TopMessage.show(context, "Please enter your email address");
      return;
    }

    if (!isValidEmail(email)) {
      TopMessage.show(context, "Please enter a valid email address");
      return;
    }

    /// 🔴 LOCATION
    if (location.isEmpty) {
      TopMessage.show(context, "Please select your location");
      return;
    }

    /// 🔴 PROFILE IMAGE
    if (profileImage == null) {
      TopMessage.show(context, "Please upload profile picture");
      return;
    }

    /// 🔴 PASSWORD
    if (password.isEmpty) {
      TopMessage.show(context, "Please enter password");
      return;
    }

    if (password.length < 6) {
      TopMessage.show(context, "Password must be at least 6 characters");
      return;
    }

    /// 🔴 CONFIRM PASSWORD
    if (confirmPassword.isEmpty) {
      TopMessage.show(context, "Please confirm your password");
      return;
    }

    if (password != confirmPassword) {
      TopMessage.show(context, "Passwords do not match");
      return;
    }

    /// 🔴 TERMS CHECKBOX
    if (!savePassword) {
      TopMessage.show(context, "Please accept Terms & Conditions");
      return;
    }

    ref
        .read(signupNotifierProvider.notifier)
        .signUp(
          name: name,
          email: email,
          password: password,
          confirmPassword: confirmPassword,
          location: location,
          latitude: selectedLat!,
          longitude: selectedLng!,
          profileImage: profileImage,
        );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    locationController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    locationFocusNode.dispose();

    super.dispose();
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupNotifierProvider);
    final isLoggingIn = signupState.status == SignupStatus.loading;

    ref.listen(signupNotifierProvider, (prev, next) {
      if (next.status == SignupStatus.success) {
        context.goNamed(RouteNames.login);
      }
      if (next.status == SignupStatus.error && next.errorMessage != null) {
        TopMessage.show(context, next.errorMessage!);
      }
    });

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

    return Scaffold(
      // backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                /// 🔝 TOP IMAGE + TITLE SECTION
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: Stack(
                    children: [
                      /// 🖼️ BACKGROUND
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMid,
                            borderRadius: AppRadii.bottomHeader,
                          ),
                        ),
                      ),

                      /// 🔙 BACK BUTTON
                      Positioned(
                        top: 50, // 🔥 yaha value adjust kar sakte ho (30–50)
                        left: 16,
                        child: InkWell(
                          onTap: () {
                            context.pop();
                          },
                          child: SvgPicture.asset(AppAssets.back, height: 24),
                        ),
                      ),

                      /// 🏷️ TITLE + SUBTITLE (CENTER)
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Sign Up Now",
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamilyDisplay,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "Join Beige to book talented photographers\nand videographers for your projects.",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                /// 📦 FORM CONTAINER (NICHE)
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      /// 🧱 MAIN FORM CONTAINER
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          36,
                          20,
                          20,
                        ), // 👈 top extra
                        margin: AppSpacing.authCardMargin,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.06),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 22),

                            /*    _buildField("Name", nameController),
                            const SizedBox(height: 16),
                            _buildField("Email ID", emailController),
                            const SizedBox(height: 16),*/
                            AppTextField(
                              label: "Name*",
                              controller: nameController,
                              keyboardType: TextInputType.name,
                            ),

                            const SizedBox(height: 16),

                            AppTextField(
                              label: "Email ID*",
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              // autofillHints: const [AutofillHints.email],
                            ),
                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// LABEL

                                /// FIELD
                                AnimatedBuilder(
                                  animation: Listenable.merge([
                                    locationFocus,
                                    locationController,
                                  ]),
                                  builder: (context, _) {
                                    final bool locationHighlight =
                                        locationFocus.hasFocus ||
                                        locationController.text.isNotEmpty;

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
                                            textEditingController:
                                                locationController,
                                            focusNode: locationFocus,
                                            googleAPIKey:
                                                GoogleConfig.placesApiKey,
                                            debounceTime: 600,
                                            isLatLngRequired: true,
                                            textStyle: const TextStyle(
                                              color: AppColors.white,
                                              fontFamily:
                                                  AppTextStyles.fontFamilyBody,
                                              fontSize: 14,
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

                                              /// 📍 LOCATION SVG
                                              suffixIcon: Padding(
                                                padding: EdgeInsets.only(
                                                  right: AppSpacing.sm,
                                                ),
                                                child: Icon(
                                                  Icons.location_on_outlined,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            ),
                                            getPlaceDetailWithLatLng:
                                                (prediction) async {
                                                  final latLng = LatLng(
                                                    double.parse(
                                                      prediction.lat!,
                                                    ),
                                                    double.parse(
                                                      prediction.lng!,
                                                    ),
                                                  );

                                                  locationFocus.unfocus();

                                                  await _updateLocationFromLatLng(
                                                    latLng,
                                                  );

                                                  setState(() {
                                                    currentLatLng = latLng;
                                                    selectedLat =
                                                        latLng.latitude;
                                                    selectedLng =
                                                        latLng.longitude;
                                                    selectedAddress =
                                                        prediction
                                                            .description ??
                                                        "";
                                                    showMap = true;
                                                    isLocationSelected = true;
                                                  });

                                                  // 👇 YAHAA ADD KARO
                                                  isProgrammaticChange = true;

                                                  locationController.text =
                                                      selectedAddress;

                                                  isProgrammaticChange = false;
                                                },
                                            itemClick: (prediction) {
                                              locationController.text =
                                                  prediction.description ?? "";
                                            },
                                            isCrossBtnShown:
                                                !isLocationSelected,
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
                                              "Location*",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: locationHighlight
                                                    ? AppColors.primary
                                                    : AppColors.white60,
                                                fontFamily: AppTextStyles
                                                    .fontFamilyBody,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),

                            SizedBox(height: 16),

                            /// 🗺️ MAP WITH FIXED HEIGHT
                            if (showMap)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: SizedBox(
                                  height: 280,
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
                                      myLocationButtonEnabled:
                                          _hasLocationPermission,
                                      zoomControlsEnabled: true,
                                      compassEnabled: false,

                                      // 🔥 IMPORTANT FIX (touch enable)
                                      gestureRecognizers:
                                          <
                                            Factory<
                                              OneSequenceGestureRecognizer
                                            >
                                          >{
                                            Factory<
                                              OneSequenceGestureRecognizer
                                            >(() => EagerGestureRecognizer()),
                                          },

                                      onMapCreated: (controller) {
                                        mapController = controller;
                                        controller.setMapStyle(darkMapStyle);
                                      },

                                      markers: currentLatLng == null
                                          ? const <Marker>{}
                                          : {
                                              Marker(
                                                markerId: const MarkerId(
                                                  "selected",
                                                ),
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

                            const SizedBox(height: 16),

                            /*     _buildPasswordField(
                              "Create Password",
                              showPassword,
                                  () => setState(() => showPassword = !showPassword),
                              passwordController,
                            ),
                            const SizedBox(height: 16),

                            _buildPasswordField(
                              "Confirm Password",
                              showConfirmPassword,
                                  () => setState(() => showConfirmPassword = !showConfirmPassword),
                              confirmPasswordController,
                            ),*/
                            AppTextField(
                              label: "Create Password*",
                              controller: passwordController,
                              obscureText: !showPassword,
                              suffix: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showPassword =
                                        !showPassword; // ✅ correct variable
                                  });
                                },
                                icon: SvgPicture.asset(
                                  showPassword
                                      ? AppAssets.eyeOpen
                                      : AppAssets.eyeClosed,
                                  height: 22,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            AppTextField(
                              label: "Confirm Password*",
                              controller: confirmPasswordController,
                              obscureText: !showConfirmPassword,
                              suffix: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showConfirmPassword =
                                        !showConfirmPassword; // ✅ correct
                                  });
                                },
                                icon: SvgPicture.asset(
                                  showConfirmPassword
                                      ? AppAssets.eyeOpen
                                      : AppAssets.eyeClosed,
                                  height: 22,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            _profilePictureCard(),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start, // 🔥 important
                              children: [
                                /// CHECKBOX
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 3,
                                  ), // align with first text line
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        savePassword = !savePassword;
                                      });
                                    },
                                    child: Container(
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                        color: savePassword
                                            ? AppColors.primary
                                            : AppColors.transparent,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: AppColors.white70,
                                        ),
                                      ),
                                      child: savePassword
                                          ? const Icon(
                                              Icons.check,
                                              size: 14,
                                              color: AppColors.black,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                /// TEXT
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: "I agree to the ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.white70,
                                            fontSize: 13,
                                            fontFamily:
                                                AppTextStyles.fontFamilyBody,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "Terms & Conditions",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.white,
                                            fontSize: 13,
                                            fontFamily:
                                                AppTextStyles.fontFamilyBody,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              final uri = Uri.parse(
                                                "https://beige.app/terms-and-conditions",
                                              );
                                              if (await canLaunchUrl(uri))
                                                launchUrl(
                                                  uri,
                                                  mode: LaunchMode
                                                      .externalApplication,
                                                );
                                            },
                                        ),
                                        const TextSpan(
                                          text: " and ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.white70,
                                            fontSize: 13,
                                            fontFamily:
                                                AppTextStyles.fontFamilyBody,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "Privacy Policy",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.white,
                                            fontSize: 13,
                                            fontFamily:
                                                AppTextStyles.fontFamilyBody,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              final uri = Uri.parse(
                                                "https://beige.app/privacy-policy",
                                              );
                                              if (await canLaunchUrl(uri))
                                                launchUrl(
                                                  uri,
                                                  mode: LaunchMode
                                                      .externalApplication,
                                                );
                                            },
                                        ),
                                        const TextSpan(
                                          text: " set out of this site",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.white70,
                                            fontSize: 13,
                                            fontFamily:
                                                AppTextStyles.fontFamilyBody,
                                          ),
                                        ),
                                      ],
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isFormValid ? _fetchSignup : null,

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  disabledBackgroundColor: AppColors.primary50,
                                  disabledForegroundColor: AppColors.onPrimary,

                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadii.xlAll,
                                  ),
                                ),

                                child: Text(
                                  "Create Account",
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamilyDisplay,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isFormValid
                                        ? AppColors.textHeading
                                        : AppColors.surfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      /*    /// 🏷️ FLOATING CHIP (BORDER PE STUCK)
                    Positioned(
                      top: -24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: AppRadii.lgAll,
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.12),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 28,
                                width: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_outline,
                                  size: 16,
                                  color: AppColors.white70,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Tell Us About Yourself & Add Details",
                                style: TextStyle(
                                  fontFamily: AppAssets.fontOutfit,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white70,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),*/
                      Positioned(
                        top: -30,
                        left: 20,
                        right: 20,
                        child: ifUserDataCard(),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: AppColors.white60,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        context.goNamed(RouteNames.login);
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          if (isLoggingIn) const AppLoader(),
        ],
      ),
    );
  }

  Widget _profilePictureCard() {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          const Text(
            "Profile Picture",
            style: TextStyle(
              fontSize: 16,
              fontFamily: AppTextStyles.fontFamilyBody,
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),

          const SizedBox(height: 4),

          /// SUB TITLE
          Text(
            "Add photo to build connection and trust",
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.white70),
          ),

          const SizedBox(height: 16),

          /// IMAGE + BUTTON ROW
          Row(
            children: [
              /// 👤 PROFILE IMAGE
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.greyShade800,
                backgroundImage: profileImage != null
                    ? FileImage(profileImage!)
                    : null,
                child: profileImage == null
                    ? SvgPicture.asset(AppAssets.person)
                    : null,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: AppRadii.roundAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadii.roundAll,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          profileImage == null
                              ? Icons
                                    .camera_alt_outlined // image nahi hai
                              : Icons.refresh, // image hai → re-upload
                          size: 18,
                          color: AppColors.black,
                        ),
                        // Icon(Icons.camera_alt_outlined, size: 18, color: AppColors.black),
                        SizedBox(width: 8),
                        Text(
                          profileImage == null
                              ? "Upload Profile Picture"
                              : "ReUpload Profile Picture",
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget ifUserDataCard() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty && email.isEmpty && profileImage == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        margin: EdgeInsets.symmetric(horizontal: 22), //
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.background, //
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.10),
            width: 0.50,
          ),
          borderRadius: AppRadii.lgAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 33,
              width: 33,
              decoration: BoxDecoration(
                //
                shape: BoxShape.circle,
                color: AppColors.backgroundOpacity70,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.06),
                  width: 1,
                ),
              ),
              child: Center(child: SvgPicture.asset(AppAssets.person)),
            ),

            const SizedBox(width: 10),

            Text(
              "Tell Us About Yourself & Add Details",
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.disabled,
              ),
            ),
          ],
        ),
      );
    }

    // 🔥 Dynamic Card (jab data fill ho)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: EdgeInsets.symmetric(horizontal: 22), //

      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.xlAll,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          /// 🔵 PROFILE IMAGE OR ICON
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.greyShade200,
            backgroundImage: profileImage != null
                ? FileImage(profileImage!)
                : null,
            child: profileImage == null
                ? const Icon(
                    Icons.person,
                    size: 26,
                    color: AppColors.neutralGrey,
                  )
                : null,
          ),

          const SizedBox(width: 10),

          /// 📝 NAME + EMAIL
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔹 NAME
                Row(
                  children: [
                    const Text(
                      "Name: ",
                      style: TextStyle(
                        fontFamily: AppAssets.fontOutfit,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black87,
                      ),
                    ),
                    Text(
                      name.isEmpty ? "Your Name" : name,
                      style: const TextStyle(
                        fontFamily: AppAssets.fontOutfit,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                /// 🔹 EMAIL WITH LABEL
                Row(
                  children: [
                    Text(
                      "Email ID: ",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.black54,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        email.isEmpty ? "Your Email" : email,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppAssets.fontOutfit,
                          fontSize: 12,
                          color: AppColors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CircleHolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    /// dark overlay
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.black.withValues(alpha: 0.6),
    );

    /// clear circle
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 130.0;

    canvas.drawCircle(center, radius, Paint()..blendMode = BlendMode.clear);

    canvas.restore();

    /// white border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
