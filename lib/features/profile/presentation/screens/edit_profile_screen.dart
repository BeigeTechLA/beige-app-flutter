import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../app/assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/radii.dart';
import 'package:beige/app/route_names.dart';
import 'package:beige/app/spacing.dart';
import 'package:beige/app/text_styles.dart';
import 'package:beige/core/location/app_map_defaults.dart';
import 'package:beige/core/utils/google_config.dart';
import 'package:beige/features/profile/presentation/providers/edit_profile_notifier.dart';
import 'package:beige/shared/widgets/app_text_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? _profileImage;

  GoogleMapController? mapController;
  LatLng? currentLatLng;
  String selectedAddress = "Search or select location";
  bool isSaving = false;

  final ImagePicker _picker = ImagePicker();

  double scale = 1.0;
  double startScale = 1.0;
  Offset offset = Offset.zero;
  Offset startOffset = Offset.zero;

  final FocusNode locationFocusNode = FocusNode();
  Set<Marker> markers = {};
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  bool _controllersInitialized = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    locationController.dispose();
    locationFocusNode.dispose();
    super.dispose();
  }

  void _initControllersFromProfile(Map<String, dynamic> user) {
    if (_controllersInitialized) return;
    _controllersInitialized = true;

    nameController.text = user['name'] ?? '';
    emailController.text = user['email'] ?? '';
    locationController.text = user['location'] ?? '';

    if (user['latitude'] != null && user['longitude'] != null) {
      final latLng = LatLng(
        double.parse(user['latitude'].toString()),
        double.parse(user['longitude'].toString()),
      );
      _updateMarker(latLng);
    }
  }

  void _updateMarker(LatLng latLng) {
    setState(() {
      currentLatLng = latLng;
      markers = {
        Marker(
          markerId: const MarkerId("selected_location"),
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
    });
  }

  Future<void> searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final latLng = LatLng(loc.latitude, loc.longitude);
        _updateMarker(latLng);
        mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
        await getAddressFromLatLng(latLng);
      }
    } catch (e) {
      if (!mounted) return;
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

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (pickedFile != null) {
      openCustomCropSheet(File(pickedFile.path));
    }
  }

  ImageProvider? getProfileImage() {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    }
    final editState = ref.read(editProfileNotifierProvider);
    final url = editState.fullImageUrl;
    if (url != null && url.isNotEmpty) {
      return NetworkImage(url);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(editProfileNotifierProvider);

    // Initialize controllers once when profile loads
    if (editState.status == EditProfileStatus.loaded &&
        editState.profile != null) {
      _initControllersFromProfile(editState.profile!);
    }

    ref.listen<EditProfileState>(editProfileNotifierProvider, (prev, next) {
      if (next.status == EditProfileStatus.saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
        context.pop(true);
      } else if (next.status == EditProfileStatus.error &&
          next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    const String darkMapStyle = '''
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

    final myProfile = editState.profile;
    final isLoading = editState.status == EditProfileStatus.loading;
    final isSavingProfile = editState.status == EditProfileStatus.saving;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 248,
                      width: double.infinity,
                      color: AppColors.transparent,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: ClipRRect(
                        borderRadius: AppRadii.bottomHeader,
                        child: Image.asset(
                          AppAssets.profilePlaceholder,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    /// BACK BUTTON
                    Positioned(
                      top: 90,
                      left: AppSpacing.base,
                      child: InkWell(
                        onTap: () => context.pop(true),
                        child: SvgPicture.asset(
                          AppAssets.back,
                          colorFilter: const ColorFilter.mode(
                            AppColors.black,
                            BlendMode.srcIn,
                          ),
                          height: 24,
                        ),
                      ),
                    ),

                    /// TITLE
                    Positioned(
                      top: 90,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          "Edit Profile",
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.textHeading,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    /// PROFILE IMAGE
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xxs),
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: AppColors.greyShade200,
                                backgroundImage: getProfileImage(),
                                child: getProfileImage() == null
                                    ? SvgPicture.asset(
                                        AppAssets.person,
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.xs),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.black12),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalSmd,

                /// USER INFO
                Text(
                  myProfile?['name'] ?? '',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontFamily: AppAssets.fontOutfit,
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AppSpacing.verticalXxs,
                Text(
                  "${myProfile?['email'] ?? ''}",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white60,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.dividerGradientEdge,
                      AppColors.dividerGradientCenter,
                      AppColors.dividerGradientEdge,
                    ],
                    stops: [0.0, 0.49, 1.0],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.mld),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  AppTextField(label: "Name*", controller: nameController),
                  AppSpacing.verticalXl,
                  AppTextField(
                    label: "Email ID*",
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                  ),
                  AppSpacing.verticalXl,
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      locationFocusNode,
                      locationController,
                    ]),
                    builder: (context, _) {
                      final bool locationHighlight =
                          locationFocusNode.hasFocus ||
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
                              textEditingController: locationController,
                              focusNode: locationFocusNode,
                              googleAPIKey: GoogleConfig.placesApiKey,
                              debounceTime: 600,
                              isLatLngRequired: true,
                              textStyle: const TextStyle(
                                color: AppColors.white,
                                fontFamily: AppTextStyles.fontFamilyBody,
                                fontSize: 15,
                              ),
                              inputDecoration: const InputDecoration(
                                filled: true,
                                fillColor: AppColors.transparent,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.lg,
                                ),
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
                              getPlaceDetailWithLatLng: (prediction) async {
                                final latLng = LatLng(
                                  double.parse(prediction.lat!),
                                  double.parse(prediction.lng!),
                                );
                                _updateMarker(latLng);
                                setState(() {
                                  selectedAddress =
                                      prediction.description ?? "";
                                });
                                locationController.text = selectedAddress;
                                locationController.selection =
                                    TextSelection.fromPosition(
                                      TextPosition(
                                        offset: locationController.text.length,
                                      ),
                                    );
                                locationFocusNode.unfocus();
                                mapController?.animateCamera(
                                  CameraUpdate.newLatLngZoom(latLng, 14),
                                );
                              },
                              itemClick: (prediction) {
                                locationController.text =
                                    prediction.description ?? "";
                                locationController.selection =
                                    TextSelection.fromPosition(
                                      TextPosition(
                                        offset: locationController.text.length,
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
                                "Location*",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: locationHighlight
                                      ? AppColors.primary
                                      : AppColors.white60,
                                  fontFamily: AppTextStyles.fontFamilyBody,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  AppSpacing.verticalXl,
                  ClipRRect(
                    borderRadius: AppRadii.xxlAll,
                    child: SizedBox(
                      height: 250,
                      child: GoogleMap(
                        style: darkMapStyle,
                        initialCameraPosition: CameraPosition(
                          target:
                              currentLatLng ?? AppMapDefaults.fallbackCenter,
                          zoom: currentLatLng == null
                              ? AppMapDefaults.fallbackZoom
                              : 14,
                        ),
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: true,
                        compassEnabled: true,
                        markers: markers,
                        gestureRecognizers:
                            <Factory<OneSequenceGestureRecognizer>>{
                              Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            },
                        onMapCreated: (controller) {
                          mapController = controller;
                          if (currentLatLng != null) {
                            mapController!.animateCamera(
                              CameraUpdate.newLatLngZoom(currentLatLng!, 14),
                            );
                          }
                        },
                        onTap: (latLng) async {
                          _updateMarker(latLng);
                          await getAddressFromLatLng(latLng);
                          locationController.text = selectedAddress;
                          mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(latLng, 14),
                          );
                        },
                      ),
                    ),
                  ),
                  AppSpacing.verticalXl,
                  AppTextField(
                    label: "Change Password*",
                    controller: TextEditingController(text: "********"),
                    readOnly: true,
                    suffix: GestureDetector(
                      onTap: () async {
                        await context.pushNamed(
                          RouteNames.changePassword,
                          extra: emailController.text,
                        );
                      },
                      child: SizedBox(
                        height: 15,
                        width: 15,
                        child: SvgPicture.asset(
                          AppAssets.profileEdit,
                          fit: BoxFit.none,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.verticalXl,
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: (isLoading || isSavingProfile)
                ? null
                : () {
                    ref
                        .read(editProfileNotifierProvider.notifier)
                        .updateProfile(
                          data: {
                            "name": nameController.text.trim(),
                            "location": locationController.text.trim(),
                          },
                        );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
            ),
            child: Text(
              "Update Profile",
              style: AppTextStyles.labelLarge.copyWith(
                fontFamily: AppAssets.fontUnbounded,
                fontWeight: FontWeight.w500,
                color: AppColors.textHeading,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void openCustomCropSheet(File imageFile) {
    Offset cropOffset = Offset.zero;
    double cropScale = 1.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: AppColors.surfaceCropSheet,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadii.round),
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 35,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.white70,
                        borderRadius: AppRadii.xxxlAll,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Crop your Profile",
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.white,
                          fontFamily: AppAssets.fontOutfit,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      InkWell(
                        onTap: () => context.pop(),
                        borderRadius: AppRadii.hugeAll,
                        child: const Padding(
                          padding: EdgeInsets.all(AppSpacing.xs),
                          child: Icon(
                            Icons.close,
                            color: AppColors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.verticalXl,
                  const Divider(color: AppColors.dividerDark),

                  /// CIRCULAR PREVIEW
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onScaleStart: (details) {
                          startScale = cropScale;
                          startOffset = cropOffset;
                        },
                        onScaleUpdate: (details) {
                          setSheetState(() {
                            cropScale = (startScale * details.scale).clamp(
                              1.0,
                              4.0,
                            );
                            cropOffset += details.focalPointDelta;
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRect(
                              child: SizedBox(
                                width: 320,
                                height: 320,
                                child: ClipRect(
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..translateByDouble(
                                        cropOffset.dx,
                                        cropOffset.dy,
                                        0,
                                        1,
                                      )
                                      ..scaleByDouble(
                                        cropScale,
                                        cropScale,
                                        cropScale,
                                        1,
                                      ),
                                    child: Image.file(
                                      imageFile,
                                      width: 340,
                                      height: 340,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IgnorePointer(
                              child: CustomPaint(
                                size: const Size(320, 320),
                                painter: CircleHolePainter(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.verticalBase,

                  /// ZOOM SLIDER
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppAssets.cropImage,
                          height: 20,
                          width: 20,
                        ),
                        AppSpacing.gapHSmd,
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14,
                              ),
                              activeTrackColor: AppColors.primary,
                              inactiveTrackColor: AppColors.white.withValues(
                                alpha: 0.3,
                              ),
                              thumbColor: AppColors.primary,
                            ),
                            child: Slider(
                              min: 1,
                              max: 5,
                              value: cropScale,
                              onChanged: (v) {
                                setSheetState(() => cropScale = v);
                              },
                            ),
                          ),
                        ),
                        AppSpacing.gapHSmd,
                        SvgPicture.asset(
                          AppAssets.cropImage,
                          height: 26,
                          width: 26,
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.verticalSmd,

                  /// SAVE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.lgAll,
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        setSheetState(() => isSaving = true);

                        final cropped = await _cropImage(
                          imageFile,
                          cropScale,
                          cropOffset,
                        );

                        if (cropped != null) {
                          setState(() => _profileImage = cropped);
                          ref
                              .read(editProfileNotifierProvider.notifier)
                              .uploadPhoto(cropped);
                        }

                        setSheetState(() => isSaving = false);
                        if (context.mounted) context.pop();
                      },
                      child: Text(
                        "Save",
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.black,
                          fontFamily: AppAssets.fontUnbounded,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<File?> _cropImage(
    File imageFile,
    double cropScale,
    Offset cropOffset,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final ui.Image image = frame.image;

      const double uiSize = 360;
      const double cropUI = 260;

      final imgW = image.width.toDouble();
      final imgH = image.height.toDouble();

      final ratioX = imgW / uiSize;
      final ratioY = imgH / uiSize;
      final ratio = ratioX < ratioY ? ratioX : ratioY;

      final cropSize = (cropUI * ratio) / cropScale;

      double dx = (imgW / 2) - (cropSize / 2) - (cropOffset.dx * ratio);
      double dy = (imgH / 2) - (cropSize / 2) - (cropOffset.dy * ratio);

      dx = dx.clamp(0.0, imgW - cropSize);
      dy = dy.clamp(0.0, imgH - cropSize);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final paint = Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high;

      canvas.drawImageRect(
        image,
        Rect.fromLTWH(dx, dy, cropSize, cropSize),
        Rect.fromLTWH(0, 0, cropSize, cropSize),
        paint,
      );

      final pic = recorder.endRecording();
      final cropped = await pic.toImage(cropSize.toInt(), cropSize.toInt());

      final data = await cropped.toByteData(format: ui.ImageByteFormat.png);

      final dir = await getTemporaryDirectory();
      final file = File(
        "${dir.path}/crop_${DateTime.now().millisecondsSinceEpoch}.png",
      );

      await file.writeAsBytes(data!.buffer.asUint8List());
      return file;
    } catch (e) {
      debugPrint("Crop failed: $e");
      return null;
    }
  }
}

class CircleHolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.black.withValues(alpha: 0.6),
    );

    final center = Offset(size.width / 2, size.height / 2);
    const radius = 120.0;

    canvas.drawCircle(center, radius, Paint()..blendMode = BlendMode.clear);

    canvas.restore();

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
