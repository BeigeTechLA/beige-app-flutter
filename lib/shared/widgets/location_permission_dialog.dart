import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../app/colors.dart';
import '../../app/radii.dart';
import '../../app/spacing.dart';
import '../../app/text_styles.dart';

const String locationPermissionDialogRouteName =
    '__location_permission_dialog__';

Future<bool> ensureLocationPermission(BuildContext context) async {
  final platform = Theme.of(context).platform;
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!context.mounted) return false;

  if (!serviceEnabled) {
    final shouldOpenSettings = await _showLocationPermissionDialog(
      context,
      title: 'Turn on location',
      message:
          'Location services are off. Turn them on to use your current location in Beige.',
      primaryLabel: 'Open Settings',
      secondaryLabel: 'Not Now',
    );

    if (shouldOpenSettings) {
      await Geolocator.openLocationSettings();
    }

    return false;
  }

  var permission = await Geolocator.checkPermission();
  if (!context.mounted) return false;

  if (_isGranted(permission)) return true;

  if (permission == LocationPermission.deniedForever) {
    return _handleBlockedPermission(context);
  }

  if (permission == LocationPermission.denied) {
    final shouldRequest = await _showLocationPermissionDialog(
      context,
      title: 'Allow location access',
      message:
          'Beige uses your location to find nearby creators and set shoot locations faster.',
      primaryLabel: 'Allow',
      secondaryLabel: 'Not Now',
    );

    if (!shouldRequest) return false;

    permission = await Geolocator.requestPermission();
    if (!context.mounted) return false;

    return _handleRequestedPermission(context, permission, platform);
  }

  await _showLocationUnavailableDialog(context);
  return false;
}

Future<bool> _handleRequestedPermission(
  BuildContext context,
  LocationPermission permission,
  TargetPlatform platform,
) async {
  if (_isGranted(permission)) return true;

  if (!context.mounted) return false;

  // iOS reports the first native "Don't Allow" response as deniedForever.
  // Keep that first denial in-app; the next attempt starts in deniedForever
  // and can offer Settings because the OS sheet will not appear again.
  if (permission == LocationPermission.deniedForever &&
      platform != TargetPlatform.iOS &&
      platform != TargetPlatform.macOS) {
    return _handleBlockedPermission(context);
  }

  await _showPermissionDeniedDialog(context);
  return false;
}

Future<bool> _handleBlockedPermission(BuildContext context) async {
  final shouldOpenSettings = await _showLocationPermissionDialog(
    context,
    title: 'Location is blocked',
    message:
        'Location permission is blocked for Beige. Enable it in app settings to use your current location.',
    primaryLabel: 'Open Settings',
    secondaryLabel: 'Not Now',
  );

  if (shouldOpenSettings) {
    await Geolocator.openAppSettings();
  }

  return false;
}

Future<void> _showPermissionDeniedDialog(BuildContext context) {
  return _showLocationPermissionDialog(
    context,
    title: 'Location not allowed',
    message:
        'You can still search for a location manually, or allow location later from settings.',
    primaryLabel: 'Got It',
  );
}

Future<void> _showLocationUnavailableDialog(BuildContext context) {
  return _showLocationPermissionDialog(
    context,
    title: 'Location unavailable',
    message:
        'Location permission could not be determined right now. You can still search for a location manually.',
    primaryLabel: 'Got It',
  );
}

bool _isGranted(LocationPermission permission) {
  return permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse;
}

Future<bool> _showLocationPermissionDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String primaryLabel,
  String? secondaryLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.black.withValues(alpha: 0.65),
    routeSettings: const RouteSettings(name: locationPermissionDialogRouteName),
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: AppColors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.xxlAll,
            border: Border.all(color: AppColors.white10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.onPrimary,
                    size: 30,
                  ),
                ),
                AppSpacing.verticalXl,
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.verticalMd,
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white70,
                  ),
                ),
                AppSpacing.verticalXxl,
                if (secondaryLabel == null)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.lgAll,
                        ),
                      ),
                      child: Text(
                        primaryLabel,
                        style: AppTextStyles.buttonMedium,
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.white70,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadii.lgAll,
                              ),
                            ),
                            child: Text(
                              secondaryLabel,
                              style: AppTextStyles.buttonMedium,
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.gapHSm,
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadii.lgAll,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                primaryLabel,
                                style: AppTextStyles.buttonMedium,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );

  return result ?? false;
}
