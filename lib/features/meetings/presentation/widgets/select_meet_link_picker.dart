import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/spacing.dart';
import '../../domain/models/meeting_platform.dart';

/// Radio-style platform picker — zoom / meet / teams.
/// Renders as three fixed-size square buttons with mockup-matched brand icons.
class SelectMeetLinkPicker extends StatelessWidget {
  const SelectMeetLinkPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final MeetingPlatform selected;
  final ValueChanged<MeetingPlatform> onChanged;

  @override
  Widget build(BuildContext context) {
    const visiblePlatforms = [MeetingPlatform.meet];
    return Row(
      children: [
        for (final p in visiblePlatforms) ...[
          _Option(
            platform: p,
            isActive: p == selected,
            onTap: () => onChanged(p),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.platform,
    required this.isActive,
    required this.onTap,
  });

  final MeetingPlatform platform;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget logo;
    switch (platform) {
      case MeetingPlatform.meet:
        logo = SvgPicture.asset(
          AppAssets.icGoogleMeet,
          width: 20,
          height: 20,
          fit: BoxFit.contain,
        );
        break;
      case MeetingPlatform.zoom:
        logo = const _ZoomLogo();
        break;
      case MeetingPlatform.teams:
        logo = const _TeamsLogo(size: 20);
        break;
    }

    return Semantics(
      button: true,
      selected: isActive,
      label: platform.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.surfaceInput,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.dividerDark,
              width: isActive ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: logo,
        ),
      ),
    );
  }
}

class _ZoomLogo extends StatelessWidget {
  const _ZoomLogo();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'zoom',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.8,
        fontFamily: 'Outfit',
      ),
    );
  }
}

class _TeamsLogo extends StatelessWidget {
  const _TeamsLogo({this.size = 20.0});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _TeamsLogoPainter()),
    );
  }
}

class _TeamsLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.45;

    canvas.drawCircle(center, radius * 0.35, paint);

    const numRays = 8;
    for (int i = 0; i < numRays; i++) {
      final angle = (i * 2 * 3.14159) / numRays;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final rect = Rect.fromLTWH(-2, -radius, 4, radius * 0.5);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
      canvas.drawRRect(rrect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
